import 'package:flutter/material.dart';
import 'package:diagnosa_campak/ui/home_screen.dart';
import 'package:diagnosa_campak/ui/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:diagnosa_campak/theme_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeNotifier(), // Inisialisasi ThemeNotifier
      child: MyApp(isLoggedIn: isLoggedIn),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    // Ambil themeMode dari provider
    final themeMode = Provider.of<ThemeNotifier>(context).themeMode;

    return MaterialApp(
      title: 'Diagnosa Campak',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      darkTheme: ThemeData.dark(),
      themeMode: themeMode, // Terapkan themeMode dari provider
      home: isLoggedIn ? const HomeScreen() : const LoginScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}
