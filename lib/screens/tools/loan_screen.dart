import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../models/tool.dart';
import '../../services/finance_calculator.dart';
import '../../widgets/tool_scaffold.dart';
import '../../widgets/number_input.dart';
import '../../widgets/result_card.dart';

class LoanScreen extends StatefulWidget {
  const LoanScreen({super.key});

  @override
  State<LoanScreen> createState() => _LoanScreenState();
}

class _LoanScreenState extends State<LoanScreen> {
  final _principalCtrl = TextEditingController(text: '40,000');
  final _balloonCtrl = TextEditingController();
  double _principal = 40000;
  double _rate = 7.5;
  int _termYears = 5;
  double _balloon = 0;

  @override
  void dispose() {
    _principalCtrl.dispose();
    _balloonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    final monthly = _principal > 0
        ? FinanceCalculator.monthlyPayment(
            principal: _principal,
            annualRate: _rate / 100,
            termMonths: _termYears * 12,
            balloon: _balloon,
          )
        : 0.0;
    final totalInterest = _principal > 0
        ? FinanceCalculator.totalInterest(
            principal: _principal,
            annualRate: _rate / 100,
            termMonths: _termYears * 12,
            balloon: _balloon,
          )
        : 0.0;
    final totalPaid = _principal + totalInterest;

    return ToolScaffold(
      toolId: Tools.loan.id,
      title: Tools.loan.name,
      icon: Tools.loan.icon,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            NumberInput(
              controller: _principalCtrl,
              label: 'Loan Amount',
              prefix: '\$ ',
              currencyFormat: true,
              onChanged: (v) => setState(() => _principal = v ?? 0),
            ),
            const SizedBox(height: 16),
            _SliderField(
              label: 'Interest Rate',
              value: _rate,
              min: 0,
              max: 20,
              divisions: 200,
              suffix: '%',
              decimals: 2,
              onChanged: (v) => setState(() => _rate = v),
            ),
            const SizedBox(height: 16),
            _SliderField(
              label: 'Loan Term',
              value: _termYears.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              suffix: ' years',
              decimals: 0,
              onChanged: (v) => setState(() => _termYears = v.round()),
            ),
            const SizedBox(height: 16),
            NumberInput(
              controller: _balloonCtrl,
              label: 'Balloon / Residual (optional)',
              prefix: '\$ ',
              currencyFormat: true,
              helperText: 'Lump sum payable at end of loan',
              onChanged: (v) => setState(() => _balloon = v ?? 0),
            ),

            const SizedBox(height: 24),

            // Primary result
            ResultCard(
              label: 'Monthly Repayment',
              value: formatter.format(monthly),
              subtitle: '$_termYears years at $_rate% p.a.',
              isPrimary: true,
            ),

            const SizedBox(height: 16),

            // Pie chart: principal vs interest
            if (_principal > 0) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cost Breakdown',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 180,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                            sections: [
                              PieChartSectionData(
                                value: _principal,
                                color: theme.colorScheme.primary,
                                title:
                                    '${(_principal / totalPaid * 100).toStringAsFixed(0)}%',
                                radius: 50,
                                titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              PieChartSectionData(
                                value: totalInterest,
                                color:
                                    theme.colorScheme.tertiary,
                                title:
                                    '${(totalInterest / totalPaid * 100).toStringAsFixed(0)}%',
                                radius: 50,
                                titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _LegendItem(
                            color: theme.colorScheme.primary,
                            label: 'Principal',
                          ),
                          _LegendItem(
                            color: theme.colorScheme.tertiary,
                            label: 'Interest',
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                      BreakdownRow(
                        label: 'Loan Amount',
                        value: formatter.format(_principal),
                      ),
                      BreakdownRow(
                        label: 'Total Interest',
                        value: formatter.format(totalInterest),
                      ),
                      if (_balloon > 0)
                        BreakdownRow(
                          label: 'Balloon Payment',
                          value: formatter.format(_balloon),
                        ),
                      const Divider(),
                      BreakdownRow(
                        label: 'Total Cost',
                        value: formatter.format(totalPaid),
                        bold: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
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
        crossAxisAlignment: CrossAxisAlignment.start,
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

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
