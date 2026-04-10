import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/currency_input_formatter.dart';

class NumberInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? prefix;
  final String? suffix;
  final String? helperText;
  final bool currencyFormat;
  final ValueChanged<double?>? onChanged;

  const NumberInput({
    super.key,
    required this.controller,
    required this.label,
    this.prefix,
    this.suffix,
    this.helperText,
    this.currencyFormat = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: currencyFormat
          ? [
              FilteringTextInputFormatter.digitsOnly,
              CurrencyInputFormatter(),
            ]
          : [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefix,
        suffixText: suffix,
        helperText: helperText,
        helperMaxLines: 2,
      ),
      onChanged: (value) {
        if (onChanged == null) return;
        final parsed = currencyFormat
            ? CurrencyInputFormatter.parse(value)
            : double.tryParse(value);
        onChanged!(parsed);
      },
    );
  }
}
