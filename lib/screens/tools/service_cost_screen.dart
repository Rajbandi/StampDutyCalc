import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/tool.dart';
import '../../widgets/tool_scaffold.dart';
import '../../widgets/number_input.dart';
import '../../widgets/result_card.dart';

class ServiceCostScreen extends StatefulWidget {
  const ServiceCostScreen({super.key});

  @override
  State<ServiceCostScreen> createState() => _ServiceCostScreenState();
}

class _ServiceCostScreenState extends State<ServiceCostScreen> {
  final _kmCtrl = TextEditingController(text: '15,000');
  double _kmYear = 15000;
  String _vehicleType = 'sedan';

  static const _baseCosts = {
    'sedan': 600.0,
    'suv': 750.0,
    '4wd': 950.0,
    'ute': 800.0,
    'european': 1200.0,
    'electric': 350.0,
  };

  @override
  void dispose() {
    _kmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    final base = _baseCosts[_vehicleType]!;
    // Scale by km/year (15k baseline)
    final yearlyCost = base * (_kmYear / 15000);
    final fiveYearCost = yearlyCost * 5;

    return ToolScaffold(
      toolId: Tools.service.id,
      title: Tools.service.name,
      icon: Tools.service.icon,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vehicle Type',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _baseCosts.keys.map((type) {
                      return ChoiceChip(
                        label: Text(_label(type)),
                        selected: _vehicleType == type,
                        onSelected: (_) =>
                            setState(() => _vehicleType = type),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            NumberInput(
              controller: _kmCtrl,
              label: 'Annual Distance',
              suffix: 'km/year',
              currencyFormat: true,
              onChanged: (v) => setState(() => _kmYear = v ?? 0),
            ),

            const SizedBox(height: 24),

            ResultCard(
              label: 'Estimated Yearly Service',
              value: formatter.format(yearlyCost),
              subtitle: 'Average for $_vehicleType',
              isPrimary: true,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    BreakdownRow(
                      label: 'Yearly',
                      value: formatter.format(yearlyCost),
                    ),
                    BreakdownRow(
                      label: 'Per 10,000 km',
                      value: formatter.format(yearlyCost / (_kmYear / 10000)),
                    ),
                    const Divider(),
                    BreakdownRow(
                      label: '5-Year Total',
                      value: formatter.format(fiveYearCost),
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
                  'Estimates based on industry averages. Actual costs vary by make, model, age, and dealer. Includes routine servicing only - not unscheduled repairs.',
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

  String _label(String type) {
    switch (type) {
      case 'sedan':
        return 'Sedan / Hatch';
      case 'suv':
        return 'SUV';
      case '4wd':
        return '4WD';
      case 'ute':
        return 'Ute';
      case 'european':
        return 'European Lux';
      case 'electric':
        return 'Electric';
      default:
        return type;
    }
  }
}
