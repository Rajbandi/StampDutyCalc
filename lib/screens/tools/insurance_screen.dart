import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/tool.dart';
import '../../widgets/tool_scaffold.dart';
import '../../widgets/number_input.dart';
import '../../widgets/result_card.dart';

class InsuranceScreen extends StatefulWidget {
  const InsuranceScreen({super.key});

  @override
  State<InsuranceScreen> createState() => _InsuranceScreenState();
}

class _InsuranceScreenState extends State<InsuranceScreen> {
  final _valueCtrl = TextEditingController(text: '40,000');
  double _vehicleValue = 40000;
  String _ageGroup = '30-49';
  String _ratingClass = '1';

  @override
  void dispose() {
    _valueCtrl.dispose();
    super.dispose();
  }

  Map<String, double> _calculate() {
    // Rough estimates - actual depends on insurer, location, history
    final ageMultiplier = switch (_ageGroup) {
      '<25' => 1.5,
      '25-29' => 1.2,
      '30-49' => 1.0,
      '50+' => 0.85,
      _ => 1.0,
    };
    final ratingMultiplier = switch (_ratingClass) {
      '1' => 0.7,
      '2-3' => 1.0,
      '4-5' => 1.4,
      '6+' => 1.8,
      _ => 1.0,
    };

    // Comprehensive: ~3% of vehicle value, adjusted
    final comprehensive =
        _vehicleValue * 0.035 * ageMultiplier * ratingMultiplier;

    // CTP: roughly $600 (varies by state)
    final ctp = 620.0 * ageMultiplier;

    return {
      'comprehensive': comprehensive,
      'ctp': ctp,
      'total': comprehensive + ctp,
    };
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    final result = _calculate();

    return ToolScaffold(
      toolId: Tools.insurance.id,
      title: Tools.insurance.name,
      icon: Tools.insurance.icon,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            NumberInput(
              controller: _valueCtrl,
              label: 'Vehicle Value',
              prefix: '\$ ',
              currencyFormat: true,
              onChanged: (v) => setState(() => _vehicleValue = v ?? 0),
            ),
            const SizedBox(height: 16),
            _ChipGroup(
              label: 'Driver Age',
              options: const ['<25', '25-29', '30-49', '50+'],
              selected: _ageGroup,
              onChanged: (v) => setState(() => _ageGroup = v),
            ),
            const SizedBox(height: 16),
            _ChipGroup(
              label: 'Rating Class',
              options: const ['1', '2-3', '4-5', '6+'],
              selected: _ratingClass,
              onChanged: (v) => setState(() => _ratingClass = v),
            ),

            const SizedBox(height: 24),

            ResultCard(
              label: 'Estimated Annual Insurance',
              value: formatter.format(result['total']!),
              isPrimary: true,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    BreakdownRow(
                      label: 'Comprehensive',
                      value: formatter.format(result['comprehensive']),
                    ),
                    BreakdownRow(
                      label: 'CTP / Green Slip',
                      value: formatter.format(result['ctp']),
                    ),
                    const Divider(),
                    BreakdownRow(
                      label: 'Total Annual',
                      value: formatter.format(result['total']),
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
                  'Rough estimate only. Actual premiums depend on location, claims history, vehicle make/model, security, and excess. Get quotes from multiple insurers.',
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

class _ChipGroup extends StatelessWidget {
  final String label;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onChanged;

  const _ChipGroup({
    required this.label,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: options.map((opt) {
              return ChoiceChip(
                label: Text(opt),
                selected: selected == opt,
                onSelected: (_) => onChanged(opt),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
