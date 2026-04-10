import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../models/tool.dart';
import '../../services/finance_calculator.dart';
import '../../widgets/tool_scaffold.dart';
import '../../widgets/number_input.dart';
import '../../widgets/result_card.dart';

class DepreciationScreen extends StatefulWidget {
  const DepreciationScreen({super.key});

  @override
  State<DepreciationScreen> createState() => _DepreciationScreenState();
}

class _DepreciationScreenState extends State<DepreciationScreen> {
  final _priceCtrl = TextEditingController(text: '50,000');
  double _price = 50000;
  double _annualRate = 15; // % per year
  int _years = 5;

  @override
  void dispose() {
    _priceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    final values = List.generate(
      _years + 1,
      (i) => FinanceCalculator.depreciatedValue(
        initial: _price,
        annualRate: _annualRate / 100,
        years: i,
      ),
    );
    final finalValue = values.last;
    final totalLoss = _price - finalValue;

    return ToolScaffold(
      toolId: Tools.depreciation.id,
      title: Tools.depreciation.name,
      icon: Tools.depreciation.icon,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            NumberInput(
              controller: _priceCtrl,
              label: 'Purchase Price',
              prefix: '\$ ',
              currencyFormat: true,
              onChanged: (v) => setState(() => _price = v ?? 0),
            ),
            const SizedBox(height: 16),

            _SliderField(
              label: 'Annual Depreciation',
              value: _annualRate,
              min: 5,
              max: 30,
              divisions: 25,
              suffix: '%',
              decimals: 0,
              onChanged: (v) => setState(() => _annualRate = v),
            ),
            const SizedBox(height: 16),
            _SliderField(
              label: 'Years',
              value: _years.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              suffix: ' yrs',
              decimals: 0,
              onChanged: (v) => setState(() => _years = v.round()),
            ),

            const SizedBox(height: 24),

            ResultCard(
              label: 'Estimated Value After $_years years',
              value: formatter.format(finalValue),
              subtitle: '${(finalValue / _price * 100).toStringAsFixed(0)}% of original value',
              isPrimary: true,
            ),

            const SizedBox(height: 16),

            // Line chart showing depreciation curve
            if (_price > 0)
              Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 16, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          'Value Over Time',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(
                              drawVerticalLine: false,
                              horizontalInterval: _price / 4,
                            ),
                            titlesData: FlTitlesData(
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 24,
                                  interval: 1,
                                  getTitlesWidget: (v, _) => Text(
                                    'Y${v.toInt()}',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 50,
                                  interval: _price / 4,
                                  getTitlesWidget: (v, _) => Text(
                                    '\$${(v / 1000).toStringAsFixed(0)}k',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            minX: 0,
                            maxX: _years.toDouble(),
                            minY: 0,
                            maxY: _price * 1.05,
                            lineBarsData: [
                              LineChartBarData(
                                spots: List.generate(
                                  values.length,
                                  (i) => FlSpot(i.toDouble(), values[i]),
                                ),
                                isCurved: true,
                                color: theme.colorScheme.primary,
                                barWidth: 3,
                                dotData: const FlDotData(show: true),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: theme.colorScheme.primary
                                      .withValues(alpha: 0.15),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    BreakdownRow(
                      label: 'Original Price',
                      value: formatter.format(_price),
                    ),
                    BreakdownRow(
                      label: 'Value After $_years years',
                      value: formatter.format(finalValue),
                    ),
                    const Divider(),
                    BreakdownRow(
                      label: 'Total Depreciation',
                      value: formatter.format(totalLoss),
                      bold: true,
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
}

class _SliderField extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String suffix;
  final int decimals;
  final ValueChanged<double> onChanged;

  const _SliderField({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.suffix,
    required this.decimals,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${value.toStringAsFixed(decimals)}$suffix',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
