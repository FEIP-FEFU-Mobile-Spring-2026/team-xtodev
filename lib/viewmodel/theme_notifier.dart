import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeMode _mode;

  ThemeNotifier({ThemeMode initialMode = ThemeMode.system}) : _mode = initialMode;

  ThemeMode get mode => _mode;

  Future<void> toggle(Brightness currentBrightness) async {
    _mode = currentBrightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', _mode == ThemeMode.dark ? 'dark' : 'light');
  }
}
