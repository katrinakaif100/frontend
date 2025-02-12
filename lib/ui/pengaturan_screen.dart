import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:diagnosa_campak/services/theme_service.dart';
import 'package:diagnosa_campak/services/emergency_contact_service.dart';
import 'package:diagnosa_campak/services/privacy_service.dart';
import 'package:provider/provider.dart';
import 'package:diagnosa_campak/theme_notifier.dart';

class PengaturanScreen extends StatefulWidget {
  const PengaturanScreen({super.key});

  @override
  State<PengaturanScreen> createState() => _PengaturanScreenState();
}

class _PengaturanScreenState extends State<PengaturanScreen> {
  bool _isDarkTheme = false;
  bool _isLoading = true;
  final ThemeService _themeService = ThemeService();
  final EmergencyContactService _emergencyContactService =
      EmergencyContactService();
  final PrivacyService _privacyService = PrivacyService();

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  // Memuat tema yang sudah disimpan
  Future<void> _loadTheme() async {
    final themeMode = await _themeService.loadTheme();
    setState(() {
      _isDarkTheme = themeMode == ThemeMode.dark;
      _isLoading = false;
    });
  }

  // Fungsi untuk menyimpan tema yang dipilih
  void _toggleTheme(bool newValue) async {
    setState(() {
      _isDarkTheme = newValue;
    });
    await _themeService.saveTheme(_isDarkTheme);
    Provider.of<ThemeNotifier>(context, listen: false).toggleTheme(newValue);
  }

  Future<void> _hapusSemuaRiwayat() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('riwayatDiagnosa');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Riwayat berhasil dihapus')),
    );
  }

  Future<void> _manageEmergencyContact() async {
    final contact = await _emergencyContactService.loadEmergencyContact();
    // Logika untuk menampilkan atau mengubah kontak darurat di UI
    print(contact);
  }

  Future<void> _managePrivacySettings() async {
    final isDataStored = await _privacyService.isUserDataStored();
    if (isDataStored) {
      await _privacyService.clearUserData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data pengguna berhasil dihapus')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada data pengguna yang disimpan')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Tema Gelap'),
            value: _isDarkTheme,
            onChanged: _toggleTheme,
          ),
          ListTile(
            leading: const Icon(Icons.contact_phone),
            title: const Text('Kontak Darurat'),
            onTap: _manageEmergencyContact,
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Pengaturan Privasi'),
            onTap: _managePrivacySettings,
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Hapus Riwayat Diagnosa'),
            onTap: () async {
              final shouldDelete = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Hapus Riwayat?'),
                  content:
                      const Text('Apakah Anda yakin ingin menghapus riwayat?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Hapus'),
                    ),
                  ],
                ),
              );
              if (shouldDelete ?? false) {
                _hapusSemuaRiwayat();
              }
            },
          ),
        ],
      ),
    );
  }
}
