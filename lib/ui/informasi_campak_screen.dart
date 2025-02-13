import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class InformasiCampakScreen extends StatefulWidget {
  const InformasiCampakScreen({super.key});

  @override
  State<InformasiCampakScreen> createState() => _InformasiCampakScreenState();
}

class _InformasiCampakScreenState extends State<InformasiCampakScreen> {
  List<Map<String, String>> informasiCampak = [];

  @override
  void initState() {
    super.initState();
    _loadInformasiCampakFromBackend(); // Ambil data dari backend saat awal
  }

  // Fungsi untuk mengambil data informasi campak dari backend
  Future<void> _loadInformasiCampakFromBackend() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.deteksicampak.my.id/api/informasi_campak'),
        headers: {
          'Authorization': 'Bearer kuncirahasiaku',
        },
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          setState(() {
            informasiCampak = List<Map<String, String>>.from(data.map((e) => {
                  'judul': e['judul']?.toString() ?? 'Judul tidak ada',
                  'konten': e['konten']?.toString() ?? 'Konten tidak ada',
                }));
          });
        } else {
          print('Format data tidak valid: harus berupa list.');
        }
      } else {
        print('Gagal memuat data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error saat memuat data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informasi Campak'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: informasiCampak.length,
        itemBuilder: (context, index) {
          final info = informasiCampak[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Card(
              child: ListTile(
                title: Text(
                  info['judul']!,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(info['konten']!),
              ),
            ),
          );
        },
      ),
    );
  }
}
