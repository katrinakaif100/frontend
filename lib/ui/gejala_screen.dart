import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:diagnosa_campak/ui/hasil_diagnosa_screen.dart';

class GejalaScreen extends StatefulWidget {
  const GejalaScreen({super.key});

  @override
  GejalaScreenState createState() => GejalaScreenState();
}

class GejalaScreenState extends State<GejalaScreen> {
  final Map<String, int> gejalaPersentase = {
    'Demam': 7,
    'Batuk': 6,
    'Pilek': 5,
    'Ruam Merah': 8,
    'Mata Merah': 6,
    'Diare': 4,
    'Lemas': 5,
    'Kehilangan Nafsu Makan': 4,
    'Sakit Kepala': 6,
    'Radang Tenggorokan': 5,
    'Bintik Koplik': 9,
  };

  Map<String, bool> gejalaDipilih = {};

  @override
  void initState() {
    super.initState();
    _initializeGejala();
  }

  void _initializeGejala() {
    // Inisialisasi semua gejala sebagai tidak dipilih
    setState(() {
      gejalaDipilih = {for (var key in gejalaPersentase.keys) key: false};
    });
  }

  void _toggleGejala(String gejala, bool value) {
    setState(() {
      gejalaDipilih[gejala] = value;
    });
  }

  void _resetGejala() {
    setState(() {
      gejalaDipilih = {for (var key in gejalaPersentase.keys) key: false};
    });
  }

  @override
  Widget build(BuildContext context) {
    final gejalaList = gejalaPersentase.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Gejala'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: gejalaList.length,
                itemBuilder: (context, index) {
                  final gejala = gejalaList[index];
                  return CheckboxListTile(
                    title: Text(gejala),
                    value: gejalaDipilih[gejala] ?? false,
                    onChanged: (value) => _toggleGejala(gejala, value!),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigasi ke layar hasil diagnosa dan reset gejala
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        HasilDiagnosaScreen(gejalaTerpilih: gejalaDipilih),
                  ),
                ).then((_) {
                  // Reset gejala setelah kembali dari HasilDiagnosaScreen
                  _resetGejala();
                });
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              child: const Text('Mulai Diagnosa'),
            ),
          ],
        ),
      ),
    );
  }
}
