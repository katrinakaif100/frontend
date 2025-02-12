import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;

class ArtikelScreen extends StatefulWidget {
  const ArtikelScreen({super.key});

  @override
  State<ArtikelScreen> createState() => _ArtikelScreenState();
}

class _ArtikelScreenState extends State<ArtikelScreen> {
  // Fungsi untuk mengambil data artikel dari server
  Future<List<Map<String, String>>> _ambilDataArtikel() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.0.140:8080/api/artikel'),
        headers: {
          'Authorization':
              'Bearer kuncirahasiaku', // Token bisa diubah sesuai kebutuhan
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        return data.map((item) => Map<String, String>.from(item)).toList();
      } else {
        throw Exception('Gagal mengambil data artikel: ${response.statusCode}');
      }
    } catch (e) {
      print('Error saat mengambil data artikel: $e');
      return [];
    }
  }

  void _launchURL(String url) {
    launchUrl(Uri.parse(url)); // Membuka URL saat artikel diklik
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Artikel dan Video Edukasi Campak')),
      body: FutureBuilder<List<Map<String, String>>>(
        future:
            _ambilDataArtikel(), // Memanggil fungsi untuk mengambil data artikel
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final articles = snapshot.data!;
            return ListView.builder(
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                return ListTile(
                  title: Text(article['title']!),
                  subtitle: Html(
                      data: article['url']!), // Menampilkan URL sebagai HTML
                  onTap: () {
                    _launchURL(
                        article['url']!); // Membuka URL artikel saat diklik
                  },
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
