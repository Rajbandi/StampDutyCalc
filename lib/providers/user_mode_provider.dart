import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum UserMode {
  simple(
    label: 'Simple',
    description: 'Just calculate, get results',
    icon: Icons.person_outline,
  ),
  buyer(
    label: 'Buyer',
    description: 'Compare and save quotes',
    icon: Icons.shopping_cart_outlined,
  ),
  dealer(
    label: 'Dealer',
    description: 'Generate customer quotes',
    icon: Icons.business_center_outlined,
  ),
  seller(
    label: 'Seller',
    description: 'Trade-in and resale',
    icon: Icons.sell_outlined,
  );

  final String label;
  final String description;
  final IconData icon;

  const UserMode({
    required this.label,
    required this.description,
    required this.icon,
  });
}

class UserModeProvider extends ChangeNotifier {
  static const _modeKey = 'user_mode';
  static const _businessNameKey = 'business_name';
  static const _salespersonKey = 'salesperson_name';
  static const _abnKey = 'dealer_abn';
  static const _phoneKey = 'dealer_phone';
  static const _emailKey = 'dealer_email';
  static const _addressKey = 'dealer_address';
  static const _validityKey = 'quote_validity_days';
  static const _footerKey = 'quote_footer_text';

  UserMode _mode = UserMode.simple;
  String _businessName = '';
  String _salespersonName = '';
  String _abn = '';
  String _dealerPhone = '';
  String _dealerEmail = '';
  String _dealerAddress = '';
  int _quoteValidityDays = 7;
  String _quoteFooterText = '';

  UserMode get mode => _mode;
  String get businessName => _businessName;
  String get salespersonName => _salespersonName;
  String get abn => _abn;
  String get dealerPhone => _dealerPhone;
  String get dealerEmail => _dealerEmail;
  String get dealerAddress => _dealerAddress;
  int get quoteValidityDays => _quoteValidityDays;
  String get quoteFooterText => _quoteFooterText;

  // Visibility flags driven by mode
  bool get showSearchBar => _mode == UserMode.dealer;
  bool get showBookmarks => _mode != UserMode.simple;
  bool get showRecentlyUsed =>
      _mode == UserMode.dealer || _mode == UserMode.buyer;
  bool get showBusinessName => _mode == UserMode.dealer;
  bool get autoResetAfterShare => _mode == UserMode.dealer;
  bool get showAdvancedSettings => _mode != UserMode.simple;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final modeStr = prefs.getString(_modeKey);
    if (modeStr != null) {
      _mode = UserMode.values.firstWhere(
        (m) => m.name == modeStr,
        orElse: () => UserMode.simple,
      );
    }
    _businessName = prefs.getString(_businessNameKey) ?? '';
    _salespersonName = prefs.getString(_salespersonKey) ?? '';
    _abn = prefs.getString(_abnKey) ?? '';
    _dealerPhone = prefs.getString(_phoneKey) ?? '';
    _dealerEmail = prefs.getString(_emailKey) ?? '';
    _dealerAddress = prefs.getString(_addressKey) ?? '';
    _quoteValidityDays = prefs.getInt(_validityKey) ?? 7;
    _quoteFooterText = prefs.getString(_footerKey) ?? '';
    notifyListeners();
  }

  Future<void> setMode(UserMode mode) async {
    _mode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_modeKey, mode.name);
  }

  Future<void> setBusinessName(String name) async {
    _businessName = name;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_businessNameKey, name);
  }

  Future<void> setSalespersonName(String name) async {
    _salespersonName = name;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_salespersonKey, name);
  }

  Future<void> setAbn(String value) async {
    _abn = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_abnKey, value);
  }

  Future<void> setDealerPhone(String value) async {
    _dealerPhone = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_phoneKey, value);
  }

  Future<void> setDealerEmail(String value) async {
    _dealerEmail = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, value);
  }

  Future<void> setDealerAddress(String value) async {
    _dealerAddress = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_addressKey, value);
  }

  Future<void> setQuoteValidityDays(int days) async {
    _quoteValidityDays = days;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_validityKey, days);
  }

  Future<void> setQuoteFooterText(String value) async {
    _quoteFooterText = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_footerKey, value);
  }
}
