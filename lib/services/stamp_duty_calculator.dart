import '../models/rate_models.dart';
import '../models/calculation_result.dart';

class StampDutyCalculator {
  static CalculationResult? calculate({
    required Country country,
    required StateRegion state,
    required double vehiclePrice,
    required Map<String, String> selections,
    DateTime? registrationDate,
  }) {
    // Find matching rate rule
    final matchingRule = _findMatchingRule(state, selections, registrationDate);
    if (matchingRule == null) return null;

    // Find matching slab
    final slab = _findMatchingSlab(matchingRule.slabs, vehiclePrice);
    if (slab == null) return null;

    // Calculate stamp duty
    final duty = _calculateSlab(slab, vehiclePrice);

    // Build breakdown
    final breakdown = <SlabBreakdown>[
      SlabBreakdown(
        description:
            'Stamp duty on ${country.currencySymbol}${_formatNumber(vehiclePrice)}',
        amount: duty,
      ),
    ];

    // Add additional fees (NZ)
    double totalFees = 0;
    final additionalFees = <String, double>{};
    if (matchingRule.additionalFees != null) {
      for (final entry in matchingRule.additionalFees!.entries) {
        additionalFees[entry.key] = entry.value;
        totalFees += entry.value;
        breakdown.add(SlabBreakdown(
          description: _formatFeeLabel(entry.key),
          amount: entry.value,
        ));
      }
    }

    final totalPayable = duty + totalFees;

    return CalculationResult(
      stampDuty: duty,
      vehiclePrice: vehiclePrice,
      currency: country.currency,
      currencySymbol: country.currencySymbol,
      stateName: state.name,
      countryName: country.name,
      additionalFees: additionalFees,
      breakdown: breakdown,
      totalPayable: totalPayable,
    );
  }

  static RateRule? _findMatchingRule(
    StateRegion state,
    Map<String, String> selections,
    DateTime? date,
  ) {
    for (final rule in state.rates) {
      if (!rule.matches(selections)) continue;

      if (date != null) {
        if (rule.dateFrom != null) {
          final from = DateTime.parse(rule.dateFrom!);
          if (date.isBefore(from)) continue;
        }
        if (rule.dateTo != null) {
          final to = DateTime.parse(rule.dateTo!);
          if (date.isAfter(to)) continue;
        }
      }

      return rule;
    }
    return null;
  }

  static RateSlab? _findMatchingSlab(List<RateSlab> slabs, double price) {
    for (final slab in slabs) {
      final inMin = price >= slab.min;
      final inMax = slab.max == null || price <= slab.max!;
      if (inMin && inMax) return slab;
    }
    return null;
  }

  static double _calculateSlab(RateSlab slab, double price) {
    double amount = price;

    if (slab.chargeFrom != null) {
      amount = price - slab.chargeFrom!;
    }

    double effectiveRate = slab.rate;

    // WA graduated rate
    if (slab.graduated && slab.divisor != null && slab.chargeFrom != null) {
      final extra = price - slab.chargeFrom!;
      effectiveRate = slab.rate + (extra / slab.divisor!);
      amount = price; // WA charges on full amount with graduated rate
    }

    final unit = slab.per;
    final units = (amount / unit).floor() + (amount % unit != 0 ? 1 : 0);
    final duty = (slab.base ?? 0) + (units * effectiveRate);

    return _roundCents(duty);
  }

  static double _roundCents(double value) {
    return (value * 100).round() / 100;
  }

  static String _formatNumber(double value) {
    if (value == value.truncateToDouble()) {
      return value.toInt().toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]},',
          );
    }
    return value.toStringAsFixed(2);
  }

  static String _formatFeeLabel(String key) {
    return key
        .replaceAllMapped(
          RegExp(r'([A-Z])'),
          (m) => ' ${m[1]}',
        )
        .replaceAll(RegExp(r'([a-z])([A-Z])'), r'$1 $2')
        .split(RegExp(r'(?=[A-Z])'))
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ')
        .replaceAll('  ', ' ')
        .trim();
  }
}
