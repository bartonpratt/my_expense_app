import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
class AppProvider extends ChangeNotifier {
  String? _username;
  Color? _color;
  String? _currency;
  SharedPreferences? _preferences;

  String? get username => _username;
  Color? get color => _color;
  String? get currency => _currency;

  static Future<AppProvider> getInstance() async {
    AppProvider provider = AppProvider();
    provider._preferences = await SharedPreferences.getInstance();
    try {
      int? color = provider._preferences?.getInt("color");
      String? username = provider._preferences?.getString("username");
      String? currency = provider._preferences?.getString("currency");

      provider._color = color != null ? Color(color) : Colors.red;
      provider._username = username;
      provider._currency = currency;
    } catch (err) {
      debugPrint("Error loading preferences: $err");
    }
    provider.notifyListeners();
    return provider;
  }

  Future<void> sync() async {
    if (_username != null) await _preferences!.setString("username", _username!);
    if (_currency != null) await _preferences!.setString("currency", _currency!);
    if (_color != null) await _preferences!.setInt("color", _color!.value);
  }

  Future<void> update({String? username, String? currency, Color? color}) async {
    _username = username ?? _username;
    _currency = currency ?? _currency;
    _color = color ?? _color;
    await sync();
    notifyListeners();
  }

  Future<void> updateUsername(String username) async {
    _username = username;
    await sync();
    notifyListeners();
  }

  Future<void> updateCurrency(String currency) async {
    _currency = currency;
    await sync();
    notifyListeners();
  }

  Future<void> updateThemeColor(Color color) async {
    _color = color;
    await sync();
    notifyListeners();
  }

  Future<void> reset() async {
    await _preferences!.remove("currency");
    await _preferences!.remove("color");
    await _preferences!.remove("username");

    _username = null;
    _currency = null;
    _color = null;

    notifyListeners();
  }
}
