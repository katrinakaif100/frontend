import 'package:diagnosa_campak/ui/pengaturan_screen.dart';
import 'package:diagnosa_campak/ui/riwayat_diagnosa_screen.dart';
import 'package:flutter/material.dart';
import 'package:diagnosa_campak/ui/login_screen.dart';
import 'package:diagnosa_campak/ui/makanan_screen.dart';
import 'package:diagnosa_campak/ui/gejala_screen.dart';
import 'package:diagnosa_campak/ui/perawatan_screen.dart';
import 'package:diagnosa_campak/ui/bantuan_screen.dart';
import 'package:diagnosa_campak/ui/artikel_screen.dart';
import 'package:diagnosa_campak/ui/informasi_campak_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  Future<void> _logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('username');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error during logout: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Diagnosa Campak'),
          backgroundColor: Colors.pink[400],
          actions: <Widget>[
            PopupMenuButton<String>(
              onSelected: (String item) {
                switch (item) {
                  case 'logout':
                    _logout();
                    break;
                }
              },
              itemBuilder: (BuildContext context) {
                return <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Text('Logout'),
                  ),
                ];
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            // Gambar sebagai background
            SizedBox.expand(
              child: Image.asset(
                'assets/images/campak_ilustrasi.jpg',
                fit: BoxFit.cover, // Menyesuaikan gambar ke seluruh layar
              ),
            ),
            // Ikon-ikon di atas background
            Positioned.fill(
              // Isi seluruh layar
              child: Padding(
                padding: const EdgeInsets.all(20.0), // Tambahkan padding
                child: GridView.count(
                  padding: EdgeInsets.zero, // Hapus padding di GridView
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1.5,
                  children: [
                    _buildIconItem(context, Icons.history, 'Riwayat', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const RiwayatDiagnosaScreen()),
                      );
                    }),
                    _buildIconItem(context, Icons.medical_services, 'Diagnosa',
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const GejalaScreen()),
                      );
                    }),
                    _buildIconItem(context, Icons.settings, 'Pengaturan', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PengaturanScreen()),
                      );
                    }),
                    _buildIconItem(context, Icons.info, 'Informasi', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const InformasiCampakScreen()),
                      );
                    }),
                    _buildIconItem(
                        context, Icons.health_and_safety, 'Perawatan', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PerawatanCampak()),
                      );
                    }),
                    _buildIconItem(context, Icons.local_dining, 'Makanan', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MakananCampak()),
                      );
                    }),
                    _buildIconItem(context, Icons.article, 'Artikel', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ArtikelScreen()),
                      );
                    }),
                    _buildIconItem(context, Icons.help, 'Bantuan', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const BantuanScreen()),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  Widget _buildIconItem(BuildContext context, IconData icon, String label,
      VoidCallback onPressed) {
    return InkWell(
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
            color:
                Colors.brown.withOpacity(0.4), // Warna latar belakang lingkaran
            shape: BoxShape.circle, // Bentuk lingkaran
          ),
          padding: const EdgeInsets.all(16), // Padding untuk memberi jarak
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color: Colors.pink, size: 30), // Ukuran ikon disesuaikan
              const SizedBox(height: 4),
              Text(label,
                  style: const TextStyle(color: Colors.white, fontSize: 12))
            ],
          ),
        ));
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
