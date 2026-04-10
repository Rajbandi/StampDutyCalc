import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/rate_models.dart';

class RateService {
  static const String _cacheKey = 'cached_rates';
  static const String _cacheVersionKey = 'cached_rates_version';
  static const String _lastCheckKey = 'last_rate_check';

  // ================================================================
  // CONFIGURE THIS: Point to your GitHub raw file URL.
  // After pushing rates.json to your repo, this URL will be:
  // https://raw.githubusercontent.com/Rajbandi/VehicleStampDutyCalc/main/rates/rates.json
  //
  // You can also use GitHub Pages, Firebase Hosting, or any static host.
  // ================================================================
  static const String remoteRatesUrl =
      'https://raw.githubusercontent.com/Rajbandi/VehicleStampDutyCalc/main/rates/rates.json';

  // Only check for updates once every 6 hours
  static const Duration _checkInterval = Duration(hours: 6);

  RateData? _rateData;
  bool _hasRemoteUpdate = false;

  RateData? get rateData => _rateData;
  bool get hasRemoteUpdate => _hasRemoteUpdate;

  /// Load rates with this priority:
  /// 1. Cached remote rates (from last successful fetch)
  /// 2. Bundled asset rates (shipped with app)
  /// Then try to fetch latest from remote in background.
  Future<RateData> loadRates() async {
    // Try cached remote rates first
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_cacheKey);
      if (cached != null) {
        _rateData = RateData.fromJson(json.decode(cached));
        // Try to update in background (non-blocking)
        _tryRemoteUpdate();
        return _rateData!;
      }
    } catch (_) {}

    // Fall back to bundled asset
    final jsonString = await rootBundle.loadString('assets/rates/rates.json');
    _rateData = RateData.fromJson(json.decode(jsonString));

    // Try remote in background
    _tryRemoteUpdate();

    return _rateData!;
  }

  /// Check remote for newer rates. Returns true if rates were updated.
  Future<bool> _tryRemoteUpdate() async {
    if (remoteRatesUrl.isEmpty) return false;

    // Throttle: don't check more than once per interval
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastCheck = prefs.getInt(_lastCheckKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - lastCheck < _checkInterval.inMilliseconds) return false;
      await prefs.setInt(_lastCheckKey, now);
    } catch (_) {}

    try {
      final response = await http
          .get(Uri.parse(remoteRatesUrl))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final remoteData = RateData.fromJson(json.decode(response.body));

        // Only update if version is different (newer)
        if (remoteData.version != _rateData?.version) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_cacheKey, response.body);
          await prefs.setString(_cacheVersionKey, remoteData.version);
          _rateData = remoteData;
          _hasRemoteUpdate = true;
          return true;
        }
      }
    } catch (_) {
      // Silently fail - user still has bundled/cached rates
    }
    return false;
  }

  /// Force check remote for updates (e.g., pull-to-refresh)
  Future<bool> forceRefresh() async {
    // Clear throttle
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastCheckKey);
    } catch (_) {}
    return _tryRemoteUpdate();
  }

  /// Clear cached rates (for debugging)
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    await prefs.remove(_cacheVersionKey);
    await prefs.remove(_lastCheckKey);
  }
}
