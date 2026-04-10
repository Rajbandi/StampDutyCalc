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

  UserMode _mode = UserMode.simple;
  String _businessName = '';
  String _salespersonName = '';

  UserMode get mode => _mode;
  String get businessName => _businessName;
  String get salespersonName => _salespersonName;

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
}
