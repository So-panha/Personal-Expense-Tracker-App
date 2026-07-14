import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  ThemeMode _themeMode = ThemeMode.dark; // Default to dark

  ThemeProvider() {
    loadTheme();
  }

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey);
    if (themeIndex != null) {
      _themeMode = ThemeMode.values[themeIndex];
    } else {
      _themeMode = ThemeMode.dark; // Default fallback
    }
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.dark) {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.dark;
    }
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, _themeMode.index);
  }
}
