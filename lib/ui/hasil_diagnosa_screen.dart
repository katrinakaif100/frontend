import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:diagnosa_campak/ui/home_screen.dart';

class HasilDiagnosaScreen extends StatefulWidget {
  final Map<String, bool> gejalaTerpilih;

  const HasilDiagnosaScreen({super.key, required this.gejalaTerpilih});

  @override
  HasilDiagnosaScreenState createState() => HasilDiagnosaScreenState();
}

class HasilDiagnosaScreenState extends State<HasilDiagnosaScreen> {
  final Map<String, Map<String, int>> penyakitGejala = {
    'Campak': {
      'Demam': 7,
      'Ruam Merah': 8,
      'Mata Merah': 6,
      'Bintik Koplik': 9,
    },
    'Flu': {
      'Demam': 5,
      'Batuk': 6,
      'Pilek': 7,
      'Sakit Kepala': 4,
    },
    'Demam Berdarah': {
      'Demam': 8,
      'Lemas': 7,
      'Sakit Kepala': 6,
      'Kehilangan Nafsu Makan': 5,
      'Ruam Merah': 6,
    },
    'ISPA': {
      'Demam': 6,
      'Batuk': 7,
      'Pilek': 6,
      'Radang Tenggorokan': 8,
      'Sakit Kepala': 5,
    },
    'Rubella': {
      'Demam': 6,
      'Ruam Merah': 8,
      'Mata Merah': 7,
      'Lemas': 5,
    },
    'Gastroenteritis': {
      'Diare': 8,
      'Demam': 5,
      'Lemas': 7,
      'Kehilangan Nafsu Makan': 6,
    },
    'Alergi': {
      'Ruam Merah': 7,
      'Mata Merah': 6,
      'Pilek': 5,
    },
  };

  late List<Map<String, dynamic>> hasilDiagnosa;
  List<Map<String, dynamic>> riwayatDiagnosa = [];

  @override
  void initState() {
    super.initState();
    _tentukanHasilDiagnosa();
    _loadRiwayat();
  }

  void _tentukanHasilDiagnosa() {
    Map<String, bool> gejalaDipilih = widget.gejalaTerpilih;
    Map<String, double> kemungkinanPenyakit = {};

    penyakitGejala.forEach((penyakit, gejala) {
      int totalBobot = gejala.values.reduce((a, b) => a + b);
      int bobotCocok = 0;

      gejala.forEach((namaGejala, bobot) {
        if (gejalaDipilih[namaGejala] == true) {
          bobotCocok += bobot;
        }
      });

      if (bobotCocok > 0) {
        kemungkinanPenyakit[penyakit] = (bobotCocok / totalBobot) * 100;
      }
    });

    hasilDiagnosa = kemungkinanPenyakit.entries.map((entry) {
      return {
        'penyakit': entry.key,
        'kemungkinan': entry.value,
      };
    }).toList()
      ..sort((a, b) =>
          (b['kemungkinan'] as double).compareTo(a['kemungkinan'] as double));

    _simpanRiwayat(gejalaDipilih, hasilDiagnosa);
  }

  Future<void> _simpanRiwayat(Map<String, bool> gejalaDipilih,
      List<Map<String, dynamic>> diagnosa) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final formattedDate = '${now.year}-${now.month}-${now.day}';
    final gejalaTerpilihList =
        gejalaDipilih.keys.where((key) => gejalaDipilih[key] == true).toList();

    // Buat riwayat baru
    final newRiwayat = {
      'tanggal': formattedDate,
      'gejala': gejalaTerpilihList,
      'diagnosa': diagnosa.map((e) => e['penyakit']).toList(),
    };

    // Ambil riwayat lama dari SharedPreferences
    final encodedRiwayat = prefs.getString('riwayatDiagnosa');
    List<Map<String, dynamic>> riwayatLama = [];
    if (encodedRiwayat != null) {
      try {
        riwayatLama = (jsonDecode(encodedRiwayat) as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();
      } catch (e) {
        debugPrint('Error decoding riwayat lama JSON: $e');
      }
    }

    // Tambahkan riwayat baru ke daftar riwayat lama
    riwayatLama.add(newRiwayat);

    // Simpan kembali ke SharedPreferences
    final updatedEncodedRiwayat = jsonEncode(riwayatLama);
    await prefs.setString('riwayatDiagnosa', updatedEncodedRiwayat);

    // Kirim data riwayat baru ke server
    await _kirimDataRiwayat(newRiwayat);
  }

  Future<void> _loadRiwayat() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedRiwayat = prefs.getString('riwayatDiagnosa');
    if (encodedRiwayat != null) {
      try {
        setState(() {
          riwayatDiagnosa = (jsonDecode(encodedRiwayat) as List)
              .map((e) => e as Map<String, dynamic>)
              .toList();
        });
      } catch (e) {
        debugPrint('Error decoding riwayat JSON: $e');
      }
    }
  }

  Future<void> _kirimDataRiwayat(Map<String, dynamic> dataRiwayat) async {
    try {
      final response = await http.post(
        Uri.parse('https://www.deteksicampak.my.id/api/riwayat_diagnosa'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer kuncirahasiaku',
        },
        body: jsonEncode(dataRiwayat),
      );

      if (response.statusCode == 200) {
        debugPrint('Data riwayat berhasil dikirim ke server.');
      } else {
        debugPrint('Gagal mengirim data riwayat: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error saat mengirim data riwayat ke server: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Diagnosa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hasil Diagnosa:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            if (hasilDiagnosa.isNotEmpty)
              ...hasilDiagnosa.map(
                (diagnosa) => Text(
                  '${diagnosa['penyakit']}: ${diagnosa['kemungkinan'].toStringAsFixed(2)}%',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            if (hasilDiagnosa.isEmpty)
              const Text(
                'Diagnosa tidak ditemukan.',
                style: TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 20),
            const Text(
              'Catatan: Segera konsultasikan ke dokter untuk pemeriksaan lebih lanjut.',
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
