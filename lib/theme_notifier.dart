import 'package:flutter/material.dart';

import 'data/settings.dart';
import 'main.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light; // Default theme
  final settings = getIt<Settings>();

  ThemeMode get themeMode {
    var isDarkMode = settings.isReady ? settings.isDarkMode : false;
    return isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // Method to toggle the theme
  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); // Notify listeners (like MaterialApp) to rebuild
  }

  // Optionally, a method to set a specific ThemeMode
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}
