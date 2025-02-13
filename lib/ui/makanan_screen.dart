import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MakananCampak extends StatefulWidget {
  const MakananCampak({super.key});

  @override
  State<MakananCampak> createState() => _MakananCampakState();
}

class _MakananCampakState extends State<MakananCampak> {
  List<Map<String, String>> makananDisarankan = [];
  List<Map<String, String>> makananDihindari = [];

  @override
  void initState() {
    super.initState();
    _ambilDataMakananDariServer();
  }

  Future<void> _ambilDataMakananDariServer() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.deteksicampak.my.id/api/makanan'),
        headers: {
          'Authorization':
              'Bearer kuncirahasiaku', // Token bisa diubah sesuai kebutuhan
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Debug log untuk memeriksa struktur data dari server
        print('Data dari server: $data');

        // Validasi struktur data sebelum digunakan
        if (data is Map &&
            data.containsKey('disarankan') &&
            data.containsKey('dihindari')) {
          setState(() {
            makananDisarankan = (data['disarankan'] as List)
                .map((item) => Map<String, String>.from(item as Map))
                .toList();
            makananDihindari = (data['dihindari'] as List)
                .map((item) => Map<String, String>.from(item as Map))
                .toList();
          });
        } else {
          print('Struktur data tidak valid: $data');
        }
      } else {
        print('Gagal mengambil data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error saat mengambil data makanan dari server: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Makanan Saat Terkena Campak'),
      ),
      body: makananDisarankan.isEmpty && makananDihindari.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Makanan yang Disarankan:',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ...makananDisarankan.map((item) {
                      return ListTile(
                        leading: const Icon(Icons.restaurant),
                        title: Text(item['title'] ?? ''),
                        subtitle: Text(item['subtitle'] ?? ''),
                      );
                    }).toList(),
                    const SizedBox(height: 16),
                    const Text(
                      'Makanan yang Sebaiknya Dihindari:',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ...makananDihindari.map((item) {
                      return ListTile(
                        leading: const Icon(Icons.no_food),
                        title: Text(item['title'] ?? ''),
                        subtitle: Text(item['subtitle'] ?? ''),
                      );
                    }).toList(),
                    const SizedBox(height: 32),
                    const Center(
                      child: Text(
                        'Disclaimer: Informasi ini hanya untuk tujuan edukasi dan BUKAN pengganti saran medis profesional. Konsultasikan dengan dokter atau ahli gizi untuk mendapatkan panduan diet yang tepat.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
