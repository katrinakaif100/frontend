import 'package:flutter/material.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme(bool newValue) {
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
    }
    notifyListeners();
  }

  // Simpan tema yang dipilih di SharedPreferences atau local storage
  Future<void> saveTheme() async {
    // Simpan tema yang dipilih ke storage jika diperlukan
  }

  Future<void> loadTheme() async {
    // Muat tema yang sudah disimpan sebelumnya jika ada
  }
}
