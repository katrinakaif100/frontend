import 'package:shared_preferences/shared_preferences.dart';

class PrivacyService {
  // Fungsi untuk menyimpan data privasi
  Future<void> savePrivacySetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  // Fungsi untuk memuat pengaturan privasi
  Future<bool> loadPrivacySetting(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? false; // Default false jika tidak ada
  }

  // Fungsi untuk menghapus pengaturan privasi
  Future<void> deletePrivacySetting(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  // Fungsi untuk memeriksa apakah data pengguna disimpan atau tidak
  Future<bool> isUserDataStored() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('user_data'); // Periksa apakah data pengguna ada
  }

  // Fungsi untuk menghapus seluruh data pengguna
  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Menghapus semua data di SharedPreferences
  }
}
