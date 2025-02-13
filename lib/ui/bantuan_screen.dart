import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BantuanScreen extends StatefulWidget {
  const BantuanScreen({super.key});

  @override
  _BantuanScreenState createState() => _BantuanScreenState();
}

class _BantuanScreenState extends State<BantuanScreen> {
  late Future<List<Map<String, String>>> _faqData;

  @override
  void initState() {
    super.initState();
    _faqData = _fetchFAQData();
  }

  // Fungsi untuk mengambil data FAQ dari backend
  Future<List<Map<String, String>>> _fetchFAQData() async {
    final response = await http.get(
      Uri.parse('https://api.deteksicampak.my.id/api/faq'),
      headers: {
        'Authorization':
            'Bearer kuncirahasiaku', // Token bisa diubah sesuai kebutuhan
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => Map<String, String>.from(item)).toList();
    } else {
      throw Exception('Failed to load FAQ data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bantuan'),
      ),
      body: FutureBuilder<List<Map<String, String>>>(
        future: _faqData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No FAQs available'));
          } else {
            final faqs = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: faqs.length,
              itemBuilder: (context, index) {
                final faq = faqs[index];
                return _buildFAQItem(
                  question: faq['question']!,
                  answer: faq['answer']!,
                );
              },
            );
          }
        },
      ),
    );
  }

  // Fungsi untuk membangun setiap item FAQ
  Widget _buildFAQItem({required String question, required String answer}) {
    return Card(
      child: ExpansionTile(
        title: Text(question),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(answer),
          ),
        ],
      ),
    );
  }
}
