import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  // -------------------------------
  // THEME MODE
  // -------------------------------
  static const String _kThemeKey = 'quanta_theme_mode_v1';
  ThemeMode _themeMode = ThemeMode.dark; // Quanta boots dark by default.

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Load the persisted theme choice. Call once from main() before runApp().
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_kThemeKey);
      if (stored == 'light') _themeMode = ThemeMode.light;
      notifyListeners();
    } catch (_) {
      // Ignore — defaults stay in place.
    }
  }

  Future<void> toggleTheme(bool enableDarkMode) async {
    _themeMode = enableDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kThemeKey, enableDarkMode ? 'dark' : 'light');
    } catch (_) {
      // Persist failures are non-fatal.
    }
  }

  // -------------------------------
  // NOTIFICATIONS TOGGLE
  // -------------------------------
  bool _notifications = true;
  bool get notifications => _notifications;

  void toggleNotifications(bool value) {
    _notifications = value;
    notifyListeners();
  }

  // -------------------------------
  // WI-FI ONLY MODE
  // -------------------------------
  bool _wifiOnly = false;
  bool get wifiOnly => _wifiOnly;

  void toggleWifiOnly(bool value) {
    _wifiOnly = value;
    notifyListeners();
  }
}
