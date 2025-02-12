import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PerawatanCampak extends StatefulWidget {
  const PerawatanCampak({super.key});

  @override
  State<PerawatanCampak> createState() => _PerawatanCampakState();
}

class _PerawatanCampakState extends State<PerawatanCampak> {
  List<Map<String, String>> perawatan = [];
  List<String> gejalaSerius = [];
  String disclaimer = "";

  @override
  void initState() {
    super.initState();
    _ambilSemuaDataDariServer();
  }

  Future<void> _ambilSemuaDataDariServer() async {
    try {
      final response = await http.get(
        Uri.parse('https://www.deteksicampak.my.id/api/perawatan'),
        headers: {
          'Authorization':
              'Bearer kuncirahasiaku', // Tambahkan jika perlu autentikasi
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Debug log untuk memeriksa struktur data dari server
        print('Data dari server: $data');

        // Validasi struktur data sebelum digunakan
        if (data is Map &&
            data.containsKey('perawatan') &&
            data.containsKey('gejalaSerius') &&
            data.containsKey('disclaimer')) {
          setState(() {
            perawatan = (data['perawatan'] as List)
                .map((item) => Map<String, String>.from(item as Map))
                .toList();
            gejalaSerius = List<String>.from(data['gejalaSerius']);
            disclaimer = data['disclaimer'] ?? '';
          });
        } else {
          print('Struktur data tidak valid: $data');
        }
      } else {
        print('Gagal mengambil data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error saat mengambil data dari server: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perawatan Awal Campak'),
      ),
      body: perawatan.isEmpty && gejalaSerius.isEmpty && disclaimer.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tips Perawatan Diri di Rumah:',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    if (perawatan.isNotEmpty)
                      ...perawatan.map((item) {
                        return ListTile(
                          leading: const Icon(Icons.health_and_safety),
                          title: Text(item['tip'] ?? 'Tip tidak tersedia'),
                          subtitle: Text(item['description'] ??
                              'Deskripsi tidak tersedia'),
                        );
                      }).toList(),
                    const SizedBox(height: 16),
                    const Text(
                      'Kapan Harus Segera Mencari Bantuan Medis:',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    if (gejalaSerius.isNotEmpty)
                      ...gejalaSerius.map((gejala) {
                        return ListTile(
                          leading: const Icon(Icons.warning_amber_rounded),
                          title: Text(gejala),
                        );
                      }).toList(),
                    const SizedBox(height: 32),
                    if (disclaimer.isNotEmpty)
                      Center(
                        child: Text(
                          disclaimer,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
