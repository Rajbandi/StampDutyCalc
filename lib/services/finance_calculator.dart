import 'dart:math';

/// Pure financial math utilities
class FinanceCalculator {
  /// Monthly loan repayment using the standard PMT formula
  /// principal: loan amount
  /// annualRate: e.g. 0.075 for 7.5%
  /// termMonths: e.g. 60 for 5 years
  /// balloon: optional balloon/residual at end
  static double monthlyPayment({
    required double principal,
    required double annualRate,
    required int termMonths,
    double balloon = 0,
  }) {
    if (annualRate == 0) {
      return (principal - balloon) / termMonths;
    }
    final r = annualRate / 12;
    final n = termMonths;
    // P = (PV - FV * (1+r)^-n) * r / (1 - (1+r)^-n)
    final factor = pow(1 + r, -n).toDouble();
    final numerator = (principal - balloon * factor) * r;
    final denominator = 1 - factor;
    return numerator / denominator;
  }

  /// Total interest paid over the life of a loan
  static double totalInterest({
    required double principal,
    required double annualRate,
    required int termMonths,
    double balloon = 0,
  }) {
    final monthly = monthlyPayment(
      principal: principal,
      annualRate: annualRate,
      termMonths: termMonths,
      balloon: balloon,
    );
    final totalPaid = monthly * termMonths + balloon;
    return totalPaid - principal;
  }

  /// Compound depreciation: value after n years given annual rate
  static double depreciatedValue({
    required double initial,
    required double annualRate,
    required int years,
  }) {
    return initial * pow(1 - annualRate, years);
  }

  /// LCT calculation: (price - threshold) * 10/11 * 33%
  static double luxuryCarTax({
    required double price,
    required double threshold,
    double rate = 0.33,
  }) {
    if (price <= threshold) return 0;
    return (price - threshold) * 10 / 11 * rate;
  }

  /// GST inclusive → exclusive (e.g., $110 → $100 + $10)
  static ({double net, double gst}) gstFromInclusive(
      double inclusive, double rate) {
    final net = inclusive / (1 + rate);
    return (net: net, gst: inclusive - net);
  }

  /// GST exclusive → inclusive
  static ({double gross, double gst}) gstFromExclusive(
      double exclusive, double rate) {
    final gst = exclusive * rate;
    return (gross: exclusive + gst, gst: gst);
  }
}
