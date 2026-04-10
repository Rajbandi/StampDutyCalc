import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/tool.dart';
import '../../widgets/tool_scaffold.dart';
import '../../widgets/number_input.dart';
import '../../widgets/result_card.dart';

class NovatedLeaseScreen extends StatefulWidget {
  const NovatedLeaseScreen({super.key});

  @override
  State<NovatedLeaseScreen> createState() => _NovatedLeaseScreenState();
}

class _NovatedLeaseScreenState extends State<NovatedLeaseScreen> {
  final _priceCtrl = TextEditingController(text: '50,000');
  final _salaryCtrl = TextEditingController(text: '100,000');
  double _vehiclePrice = 50000;
  double _salary = 100000;
  int _termYears = 5;
  bool _isEv = false;

  @override
  void dispose() {
    _priceCtrl.dispose();
    _salaryCtrl.dispose();
    super.dispose();
  }

  /// Simplified novated lease calculation
  /// Assumes Employee Contribution Method (ECM)
  /// EVs under FBT exemption threshold get 100% pre-tax
  Map<String, double> _calculate() {
    // Estimated annual lease cost (rough: 25% of price/year for 5y term)
    final annualLeaseCost = _vehiclePrice / _termYears * 1.25;

    // FBT-exempt EVs (under $91,387 threshold) - 100% pre-tax
    if (_isEv && _vehiclePrice < 91387) {
      final marginalRate = _marginalTaxRate(_salary);
      final taxSaving = annualLeaseCost * marginalRate;
      return {
        'annualLeaseCost': annualLeaseCost,
        'taxSaving': taxSaving,
        'netCost': annualLeaseCost - taxSaving,
        'savingsVsCash': taxSaving * _termYears,
      };
    }

    // Regular novated lease using ECM:
    // ~50% of lease is post-tax (employee contribution to offset FBT)
    final preTaxPortion = annualLeaseCost * 0.5;
    final marginalRate = _marginalTaxRate(_salary);
    final taxSaving = preTaxPortion * marginalRate;
    return {
      'annualLeaseCost': annualLeaseCost,
      'taxSaving': taxSaving,
      'netCost': annualLeaseCost - taxSaving,
      'savingsVsCash': taxSaving * _termYears,
    };
  }

  double _marginalTaxRate(double salary) {
    // 2024-25 AU resident tax rates
    if (salary <= 18200) return 0.0;
    if (salary <= 45000) return 0.16;
    if (salary <= 135000) return 0.30;
    if (salary <= 190000) return 0.37;
    return 0.45;
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    final result = _calculate();

    return ToolScaffold(
      toolId: Tools.novatedLease.id,
      title: Tools.novatedLease.name,
      icon: Tools.novatedLease.icon,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            NumberInput(
              controller: _priceCtrl,
              label: 'Vehicle Price (incl. GST)',
              prefix: '\$ ',
              currencyFormat: true,
              onChanged: (v) => setState(() => _vehiclePrice = v ?? 0),
            ),
            const SizedBox(height: 16),
            NumberInput(
              controller: _salaryCtrl,
              label: 'Annual Salary (gross)',
              prefix: '\$ ',
              currencyFormat: true,
              helperText: 'Used to calculate marginal tax rate',
              onChanged: (v) => setState(() => _salary = v ?? 0),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lease Term',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [2, 3, 4, 5].map((years) {
                      return ChoiceChip(
                        label: Text('$years years'),
                        selected: _termYears == years,
                        onSelected: (_) => setState(() => _termYears = years),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: SwitchListTile(
                title: const Text('Electric Vehicle'),
                subtitle: const Text(
                    'EVs under \$91,387 are FBT-exempt (huge savings)'),
                value: _isEv,
                onChanged: (v) => setState(() => _isEv = v),
              ),
            ),

            const SizedBox(height: 24),

            ResultCard(
              label: 'Total Tax Savings',
              value: formatter.format(result['savingsVsCash']!),
              subtitle: 'Over $_termYears years vs paying cash',
              isPrimary: true,
            ),

            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    BreakdownRow(
                      label: 'Annual Lease Cost',
                      value: formatter.format(result['annualLeaseCost']),
                    ),
                    BreakdownRow(
                      label: 'Annual Tax Saving',
                      value: formatter.format(result['taxSaving']),
                    ),
                    BreakdownRow(
                      label: 'Net Annual Cost',
                      value: formatter.format(result['netCost']),
                    ),
                    const Divider(),
                    BreakdownRow(
                      label: 'Marginal Tax Rate',
                      value: '${(_marginalTaxRate(_salary) * 100).toStringAsFixed(0)}%',
                      bold: true,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            Card(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'This is a simplified estimate. Actual savings depend on lease provider, residual value, FBT method (ECM vs Statutory), and your employer\'s salary packaging arrangement. Consult a salary packaging specialist.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
