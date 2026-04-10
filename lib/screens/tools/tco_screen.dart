import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../models/tool.dart';
import '../../services/finance_calculator.dart';
import '../../widgets/tool_scaffold.dart';
import '../../widgets/number_input.dart';
import '../../widgets/result_card.dart';

class TcoScreen extends StatefulWidget {
  const TcoScreen({super.key});

  @override
  State<TcoScreen> createState() => _TcoScreenState();
}

class _TcoScreenState extends State<TcoScreen> {
  final _priceCtrl = TextEditingController(text: '40,000');
  final _kmCtrl = TextEditingController(text: '15,000');
  final _consumptionCtrl = TextEditingController(text: '8.0');
  final _fuelPriceCtrl = TextEditingController(text: '1.95');

  double _price = 40000;
  double _kmYear = 15000;
  double _consumption = 8.0;
  double _fuelPrice = 1.95;
  int _years = 5;

  @override
  void dispose() {
    _priceCtrl.dispose();
    _kmCtrl.dispose();
    _consumptionCtrl.dispose();
    _fuelPriceCtrl.dispose();
    super.dispose();
  }

  Map<String, double> _calculate() {
    final stampDuty = _price * 0.04; // ~4% rough average
    final yearlyFuel = (_consumption / 100) * _kmYear * _fuelPrice;
    final yearlyRego = 800.0;
    final yearlyInsurance = _price * 0.035 + 620;
    final yearlyService = 700.0;

    final totalFuel = yearlyFuel * _years;
    final totalRego = yearlyRego * _years;
    final totalInsurance = yearlyInsurance * _years;
    final totalService = yearlyService * _years;

    final residualValue = FinanceCalculator.depreciatedValue(
      initial: _price,
      annualRate: 0.15,
      years: _years,
    );
    final depreciation = _price - residualValue;

    return {
      'purchasePrice': _price,
      'stampDuty': stampDuty,
      'fuel': totalFuel,
      'rego': totalRego,
      'insurance': totalInsurance,
      'service': totalService,
      'depreciation': depreciation,
      'residualValue': residualValue,
      'total': stampDuty +
          totalFuel +
          totalRego +
          totalInsurance +
          totalService +
          depreciation,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    final result = _calculate();

    return ToolScaffold(
      toolId: Tools.tco.id,
      title: Tools.tco.name,
      icon: Tools.tco.icon,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            NumberInput(
              controller: _priceCtrl,
              label: 'Vehicle Price',
              prefix: '\$ ',
              currencyFormat: true,
              onChanged: (v) => setState(() => _price = v ?? 0),
            ),
            const SizedBox(height: 12),
            NumberInput(
              controller: _kmCtrl,
              label: 'Annual km',
              suffix: 'km',
              currencyFormat: true,
              onChanged: (v) => setState(() => _kmYear = v ?? 0),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: NumberInput(
                    controller: _consumptionCtrl,
                    label: 'Fuel L/100km',
                    onChanged: (v) => setState(() => _consumption = v ?? 0),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: NumberInput(
                    controller: _fuelPriceCtrl,
                    label: 'Fuel \$/L',
                    onChanged: (v) => setState(() => _fuelPrice = v ?? 0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Period',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      )),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [3, 5, 7, 10].map((y) {
                      return ChoiceChip(
                        label: Text('$y years'),
                        selected: _years == y,
                        onSelected: (_) => setState(() => _years = y),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            ResultCard(
              label: '$_years-Year Total Cost',
              value: formatter.format(result['total']),
              isPrimary: true,
            ),

            const SizedBox(height: 16),

            // Pie chart of cost breakdown
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cost Breakdown',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        )),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                          sections: [
                            _section(result['depreciation']!,
                                theme.colorScheme.error, 'Depr'),
                            _section(result['fuel']!,
                                theme.colorScheme.tertiary, 'Fuel'),
                            _section(result['insurance']!,
                                theme.colorScheme.primary, 'Ins'),
                            _section(result['service']!,
                                theme.colorScheme.secondary, 'Svc'),
                            _section(result['rego']!,
                                Colors.amber, 'Rego'),
                            _section(result['stampDuty']!,
                                Colors.purple, 'Duty'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    BreakdownRow(
                      label: 'Depreciation',
                      value: formatter.format(result['depreciation']),
                    ),
                    BreakdownRow(
                      label: 'Fuel',
                      value: formatter.format(result['fuel']),
                    ),
                    BreakdownRow(
                      label: 'Insurance',
                      value: formatter.format(result['insurance']),
                    ),
                    BreakdownRow(
                      label: 'Service',
                      value: formatter.format(result['service']),
                    ),
                    BreakdownRow(
                      label: 'Registration',
                      value: formatter.format(result['rego']),
                    ),
                    BreakdownRow(
                      label: 'Stamp Duty',
                      value: formatter.format(result['stampDuty']),
                    ),
                    const Divider(),
                    BreakdownRow(
                      label: 'Total',
                      value: formatter.format(result['total']),
                      bold: true,
                    ),
                    BreakdownRow(
                      label: 'Cost per km',
                      value: formatter.format(
                          result['total']! / (_kmYear * _years)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PieChartSectionData _section(double value, Color color, String label) {
    return PieChartSectionData(
      value: value,
      color: color,
      title: label,
      radius: 60,
      titleStyle: const TextStyle(
        color: Colors.white,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
