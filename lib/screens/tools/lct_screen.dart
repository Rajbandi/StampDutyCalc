import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/tool.dart';
import '../../providers/calculator_provider.dart';
import '../../widgets/tool_scaffold.dart';
import '../../widgets/number_input.dart';
import '../../widgets/result_card.dart';

class LctScreen extends StatefulWidget {
  const LctScreen({super.key});

  @override
  State<LctScreen> createState() => _LctScreenState();
}

class _LctScreenState extends State<LctScreen> {
  final _priceCtrl = TextEditingController(text: '100,000');
  double _price = 100000;
  bool _fuelEfficient = false;

  @override
  void dispose() {
    _priceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final lct = context.watch<CalculatorProvider>().rateData?.luxuryCarTax;

    if (lct == null) {
      return ToolScaffold(
        toolId: Tools.lct.id,
        title: Tools.lct.name,
        icon: Tools.lct.icon,
        body: const Center(child: Text('LCT data not available')),
      );
    }

    final tax = lct.calculate(_price, fuelEfficient: _fuelEfficient);
    final threshold =
        _fuelEfficient ? lct.fuelEfficientThreshold : lct.standardThreshold;
    final aboveThreshold = _price > threshold ? _price - threshold : 0;

    return ToolScaffold(
      toolId: Tools.lct.id,
      title: Tools.lct.name,
      icon: Tools.lct.icon,
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
              onChanged: (v) => setState(() => _price = v ?? 0),
            ),
            const SizedBox(height: 16),
            Card(
              child: SwitchListTile(
                title: const Text('Fuel-efficient vehicle'),
                subtitle: Text(
                  'Under 3.5 L/100km - higher LCT threshold (${formatter.format(lct.fuelEfficientThreshold)})',
                  style: theme.textTheme.bodySmall,
                ),
                value: _fuelEfficient,
                onChanged: (v) => setState(() => _fuelEfficient = v),
              ),
            ),

            const SizedBox(height: 24),

            ResultCard(
              label: 'Luxury Car Tax',
              value: formatter.format(tax),
              subtitle: tax > 0
                  ? '33% on the GST-exclusive value above threshold'
                  : 'Below LCT threshold - no tax payable',
              isPrimary: true,
            ),

            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    BreakdownRow(
                      label: 'Vehicle Price',
                      value: formatter.format(_price),
                    ),
                    BreakdownRow(
                      label: 'LCT Threshold',
                      value: formatter.format(threshold),
                    ),
                    BreakdownRow(
                      label: 'Above Threshold',
                      value: formatter.format(aboveThreshold),
                    ),
                    BreakdownRow(
                      label: 'GST-exclusive Excess',
                      value: formatter.format(aboveThreshold * 10 / 11),
                    ),
                    const Divider(),
                    BreakdownRow(
                      label: 'LCT (33%)',
                      value: formatter.format(tax),
                      bold: true,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Card(
              color: theme.colorScheme.surfaceContainerLow,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'LCT is paid on top of GST and stamp duty for vehicles above the threshold.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
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
