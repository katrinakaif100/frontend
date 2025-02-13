import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class RiwayatDiagnosaScreen extends StatefulWidget {
  const RiwayatDiagnosaScreen({super.key});

  @override
  State<RiwayatDiagnosaScreen> createState() => _RiwayatDiagnosaScreenState();
}

class _RiwayatDiagnosaScreenState extends State<RiwayatDiagnosaScreen> {
  List<Map<String, dynamic>> riwayat = [];

  @override
  void initState() {
    super.initState();
    _loadRiwayat();
  }

  Future<void> _loadRiwayat() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedRiwayat = prefs.getString('riwayatDiagnosa');
    if (encodedRiwayat != null) {
      try {
        setState(() {
          riwayat = (jsonDecode(encodedRiwayat) as List)
              .map((e) => e as Map<String, dynamic>)
              .toList();
        });
      } catch (e) {
        debugPrint('Error decoding riwayat JSON: $e');
      }
    } else {
      setState(() {
        riwayat = [];
      });
    }
  }

  Future<void> _tambahDiagnosaBaru(Map<String, dynamic> diagnosaBaru) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      riwayat.add(diagnosaBaru);
    });
    final encodedRiwayat = jsonEncode(riwayat);
    await prefs.setString('riwayatDiagnosa', encodedRiwayat);
    await _kirimDataRiwayat();
  }

  Future<void> _hapusRiwayat(int index) async {
    final removedEntry = riwayat[index];
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      riwayat.removeAt(index);
    });
    final encodedRiwayat = jsonEncode(riwayat);
    await prefs.setString('riwayatDiagnosa', encodedRiwayat);
    await _kirimDataRiwayat();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Riwayat dihapus'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              riwayat.insert(index, removedEntry);
            });
            prefs.setString('riwayatDiagnosa', jsonEncode(riwayat));
          },
        ),
      ),
    );
  }

  Future<void> _hapusSemuaRiwayat() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda yakin ingin menghapus semua riwayat?'),
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

    if (confirm ?? false) {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        riwayat = [];
      });
      await prefs.remove('riwayatDiagnosa');
      await _kirimDataRiwayat();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua riwayat dihapus')),
      );
    }
  }

  Future<void> _kirimDataRiwayat() async {
    try {
      // Ambil data riwayat dari backend untuk mendapatkan ID terakhir
      final getResponse = await http.get(
        Uri.parse('http://192.168.0.140:8080/api/riwayat_diagnosa'),
        headers: {
          'Authorization': 'Bearer kuncirahasiaku',
        },
      );

      int nextId = 1; // ID dimulai dari 1 jika tidak ada data sebelumnya
      if (getResponse.statusCode == 200) {
        final existingData = jsonDecode(getResponse.body) as List<dynamic>;
        if (existingData.isNotEmpty) {
          // Cari ID terakhir dan tambahkan 1
          final lastId = existingData.last['id'] as int? ?? 0;
          nextId = lastId + 1;
        }
      } else {
        debugPrint(
            'Gagal mengambil data dari server: ${getResponse.statusCode}');
      }

      // Tambahkan ID baru ke setiap item dalam riwayat yang belum memiliki ID
      final riwayatDenganId = riwayat.map((entry) {
        if (entry['id'] == null) {
          entry['id'] = nextId++;
        }
        return entry;
      }).toList();

      // Kirim data riwayat ke backend
      final encodedRiwayat = jsonEncode(riwayatDenganId);
      final postResponse = await http.post(
        Uri.parse('https://api.deteksicampak.my.id/api/riwayat_diagnosa'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer kuncirahasiaku',
        },
        body: encodedRiwayat,
      );

      if (postResponse.statusCode == 200) {
        debugPrint('Data riwayat berhasil dikirim ke server.');
      } else {
        debugPrint(
            'Gagal mengirim data riwayat ke server: ${postResponse.statusCode}');
      }
    } catch (e) {
      debugPrint('Error saat mengirim data riwayat ke server: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Diagnosa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _hapusSemuaRiwayat,
          ),
        ],
      ),
      body: riwayat.isEmpty
          ? const Center(child: Text('Tidak ada riwayat diagnosa.'))
          : ListView.builder(
              itemCount: riwayat.length,
              itemBuilder: (context, index) {
                final entry = riwayat[index];
                final tanggal = entry['tanggal'] ?? 'Tidak diketahui';
                final gejala = entry['gejala'] != null
                    ? (entry['gejala'] as List).join(', ')
                    : 'Tidak diketahui';
                final diagnosa = entry['diagnosa'] ?? 'Tidak diketahui';

                return Dismissible(
                  key: UniqueKey(),
                  onDismissed: (direction) {
                    _hapusRiwayat(index);
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Card(
                    child: ListTile(
                      title: Text('Tanggal: $tanggal'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Gejala: $gejala'),
                          Text('Diagnosa: $diagnosa'),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
