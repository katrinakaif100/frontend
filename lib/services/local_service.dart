import 'package:shared_preferences/shared_preferences.dart';

class LocalService {
  // Memuat data dari SharedPreferences berdasarkan key
  Future<String?> loadData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key); // Mengambil string dari SharedPreferences
  }

  // Menyimpan data ke SharedPreferences
  Future<void> saveData(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value); // Menyimpan string ke SharedPreferences
  }

  // Menghapus data dari SharedPreferences
  Future<void> removeData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key); // Menghapus data berdasarkan key
  }

  // Menyimpan nilai boolean
  Future<void> saveBoolean(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value); // Menyimpan boolean ke SharedPreferences
  }

  // Mengambil nilai boolean
  Future<bool?> loadBoolean(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key); // Mengambil nilai boolean dari SharedPreferences
  }

  // Menyimpan nilai integer
  Future<void> saveInteger(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value); // Menyimpan integer ke SharedPreferences
  }

  // Mengambil nilai integer
  Future<int?> loadInteger(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key); // Mengambil integer dari SharedPreferences
  }
}
