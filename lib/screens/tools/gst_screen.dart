import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/tool.dart';
import '../../services/finance_calculator.dart';
import '../../widgets/tool_scaffold.dart';
import '../../widgets/number_input.dart';
import '../../widgets/result_card.dart';

class GstScreen extends StatefulWidget {
  const GstScreen({super.key});

  @override
  State<GstScreen> createState() => _GstScreenState();
}

class _GstScreenState extends State<GstScreen> {
  final _amountCtrl = TextEditingController(text: '110');
  double _amount = 110;
  bool _isInclusive = true;
  double _rate = 0.10; // AU default

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    final gstAmount = _isInclusive
        ? FinanceCalculator.gstFromInclusive(_amount, _rate)
        : null;
    final excAmount = !_isInclusive
        ? FinanceCalculator.gstFromExclusive(_amount, _rate)
        : null;

    final net = _isInclusive ? gstAmount!.net : _amount;
    final gst = _isInclusive ? gstAmount!.gst : excAmount!.gst;
    final gross = _isInclusive ? _amount : excAmount!.gross;

    return ToolScaffold(
      toolId: Tools.gst.id,
      title: Tools.gst.name,
      icon: Tools.gst.icon,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // GST rate selector
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
                    'GST Rate',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Australia (10%)'),
                        selected: _rate == 0.10,
                        onSelected: (_) => setState(() => _rate = 0.10),
                      ),
                      ChoiceChip(
                        label: const Text('New Zealand (15%)'),
                        selected: _rate == 0.15,
                        onSelected: (_) => setState(() => _rate = 0.15),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Inclusive/Exclusive toggle
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('Includes GST')),
                ButtonSegment(value: false, label: Text('Plus GST')),
              ],
              selected: {_isInclusive},
              onSelectionChanged: (s) =>
                  setState(() => _isInclusive = s.first),
            ),
            const SizedBox(height: 16),

            NumberInput(
              controller: _amountCtrl,
              label: _isInclusive ? 'Amount (incl. GST)' : 'Amount (excl. GST)',
              prefix: '\$ ',
              currencyFormat: true,
              onChanged: (v) => setState(() => _amount = v ?? 0),
            ),

            const SizedBox(height: 24),

            ResultCard(
              label: 'GST Amount',
              value: formatter.format(gst),
              isPrimary: true,
            ),

            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    BreakdownRow(label: 'Net (excl. GST)', value: formatter.format(net)),
                    BreakdownRow(label: 'GST', value: formatter.format(gst)),
                    const Divider(),
                    BreakdownRow(
                      label: 'Total (incl. GST)',
                      value: formatter.format(gross),
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
