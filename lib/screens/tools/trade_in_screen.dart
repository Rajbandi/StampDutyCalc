import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/tool.dart';
import '../../widgets/tool_scaffold.dart';
import '../../widgets/number_input.dart';
import '../../widgets/result_card.dart';

class TradeInScreen extends StatefulWidget {
  const TradeInScreen({super.key});

  @override
  State<TradeInScreen> createState() => _TradeInScreenState();
}

class _TradeInScreenState extends State<TradeInScreen> {
  final _newCarCtrl = TextEditingController(text: '60,000');
  final _tradeInCtrl = TextEditingController(text: '20,000');
  double _newCarPrice = 60000;
  double _tradeInValue = 20000;

  @override
  void dispose() {
    _newCarCtrl.dispose();
    _tradeInCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final netPrice = (_newCarPrice - _tradeInValue).clamp(0, double.infinity);
    final saving = _tradeInValue;

    return ToolScaffold(
      toolId: Tools.tradeIn.id,
      title: Tools.tradeIn.name,
      icon: Tools.tradeIn.icon,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            NumberInput(
              controller: _newCarCtrl,
              label: 'New Vehicle Price',
              prefix: '\$ ',
              currencyFormat: true,
              onChanged: (v) => setState(() => _newCarPrice = v ?? 0),
            ),
            const SizedBox(height: 16),
            NumberInput(
              controller: _tradeInCtrl,
              label: 'Trade-in Value',
              prefix: '\$ ',
              currencyFormat: true,
              helperText: 'Get an independent valuation for best results',
              onChanged: (v) => setState(() => _tradeInValue = v ?? 0),
            ),
            const SizedBox(height: 24),
            ResultCard(
              label: 'Net Price (after trade-in)',
              value: formatter.format(netPrice),
              subtitle: 'You pay this amount out of pocket',
              isPrimary: true,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    BreakdownRow(
                      label: 'New Vehicle',
                      value: formatter.format(_newCarPrice),
                    ),
                    BreakdownRow(
                      label: 'Trade-in Value',
                      value: '- ${formatter.format(_tradeInValue)}',
                    ),
                    const Divider(),
                    BreakdownRow(
                      label: 'Net Cash Outlay',
                      value: formatter.format(netPrice),
                      bold: true,
                    ),
                    const SizedBox(height: 12),
                    BreakdownRow(
                      label: 'Effective Discount',
                      value:
                          '${(saving / _newCarPrice * 100).toStringAsFixed(1)}%',
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
                  'Note: In most Australian states, stamp duty is calculated on the FULL purchase price, not the trade-in offset amount. Use the Stamp Duty calculator with the full vehicle price.',
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
