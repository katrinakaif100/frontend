import 'package:shared_preferences/shared_preferences.dart';

class EmergencyContactService {
  // Fungsi untuk menyimpan kontak darurat
  Future<void> saveEmergencyContact(String name, String phoneNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('emergency_contact_name', name);
    await prefs.setString('emergency_contact_phone', phoneNumber);
  }

  // Fungsi untuk memuat kontak darurat
  Future<Map<String, String?>> loadEmergencyContact() async {
    final prefs = await SharedPreferences.getInstance();
    String? name = prefs.getString('emergency_contact_name');
    String? phone = prefs.getString('emergency_contact_phone');
    return {
      'name': name,
      'phone': phone,
    };
  }

  // Fungsi untuk menghapus kontak darurat
  Future<void> deleteEmergencyContact() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('emergency_contact_name');
    await prefs.remove('emergency_contact_phone');
  }

  // Fungsi untuk memeriksa apakah kontak darurat ada
  Future<bool> isEmergencyContactSet() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('emergency_contact_name') &&
        prefs.containsKey('emergency_contact_phone');
  }
}
