import 'package:shared_preferences/shared_preferences.dart';

/// Generates sequential per-day quote numbers in the format `YYYYMMDD-NNN`.
/// The counter is stored per-date in `SharedPreferences` so numbers remain
/// stable across app restarts and are unique within a day.
class QuoteMetaService {
  static const _counterPrefix = 'quote_counter_';

  /// Returns the next quote number for the given day (defaults to today).
  /// Each call increments the underlying counter, so callers should cache
  /// the returned value rather than calling repeatedly for the same quote.
  static Future<String> nextQuoteNumber([DateTime? now]) async {
    final date = now ?? DateTime.now();
    final datePart = _dateKey(date);
    final prefs = await SharedPreferences.getInstance();
    final key = '$_counterPrefix$datePart';
    final next = (prefs.getInt(key) ?? 0) + 1;
    await prefs.setInt(key, next);
    return '$datePart-${next.toString().padLeft(3, '0')}';
  }

  static String _dateKey(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y$m$d';
  }
}
