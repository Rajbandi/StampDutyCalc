import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/tool.dart';
import '../../widgets/tool_scaffold.dart';
import '../../widgets/number_input.dart';
import '../../widgets/result_card.dart';

class FuelCostScreen extends StatefulWidget {
  const FuelCostScreen({super.key});

  @override
  State<FuelCostScreen> createState() => _FuelCostScreenState();
}

class _FuelCostScreenState extends State<FuelCostScreen> {
  final _consumptionCtrl = TextEditingController(text: '8.5');
  final _priceCtrl = TextEditingController(text: '1.95');
  final _kmYearCtrl = TextEditingController(text: '15,000');

  double _consumption = 8.5;
  double _price = 1.95;
  double _kmYear = 15000;

  @override
  void dispose() {
    _consumptionCtrl.dispose();
    _priceCtrl.dispose();
    _kmYearCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    // Litres per year, then cost
    final litresPerYear = _consumption / 100 * _kmYear;
    final yearlyCost = litresPerYear * _price;
    final monthlyCost = yearlyCost / 12;
    final weeklyCost = yearlyCost / 52;
    final dailyCost = yearlyCost / 365;

    return ToolScaffold(
      toolId: Tools.fuelCost.id,
      title: Tools.fuelCost.name,
      icon: Tools.fuelCost.icon,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            NumberInput(
              controller: _consumptionCtrl,
              label: 'Fuel Consumption',
              suffix: 'L/100km',
              helperText: 'Average L per 100 km (check vehicle specs)',
              onChanged: (v) => setState(() => _consumption = v ?? 0),
            ),
            const SizedBox(height: 16),
            NumberInput(
              controller: _priceCtrl,
              label: 'Fuel Price',
              prefix: '\$ ',
              suffix: '/L',
              onChanged: (v) => setState(() => _price = v ?? 0),
            ),
            const SizedBox(height: 16),
            NumberInput(
              controller: _kmYearCtrl,
              label: 'Annual Distance',
              suffix: 'km/year',
              currencyFormat: true,
              helperText: 'Average AU driver: ~13,000 km/year',
              onChanged: (v) => setState(() => _kmYear = v ?? 0),
            ),

            const SizedBox(height: 24),

            ResultCard(
              label: 'Yearly Fuel Cost',
              value: formatter.format(yearlyCost),
              subtitle: '${litresPerYear.toStringAsFixed(0)} litres per year',
              isPrimary: true,
            ),

            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    BreakdownRow(
                      label: 'Daily',
                      value: formatter.format(dailyCost),
                    ),
                    BreakdownRow(
                      label: 'Weekly',
                      value: formatter.format(weeklyCost),
                    ),
                    BreakdownRow(
                      label: 'Monthly',
                      value: formatter.format(monthlyCost),
                    ),
                    const Divider(),
                    BreakdownRow(
                      label: 'Yearly',
                      value: formatter.format(yearlyCost),
                      bold: true,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
