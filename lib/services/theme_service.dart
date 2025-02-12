import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String _key = 'isDarkTheme';

  // Fungsi untuk memuat tema yang telah disimpan
  Future<ThemeMode> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    bool isDark = prefs.getBool(_key) ?? false;
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }

  // Fungsi untuk menyimpan tema yang dipilih
  Future<void> saveTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, isDark);
  }
}
