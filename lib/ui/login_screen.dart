import 'package:flutter/material.dart';
import 'package:diagnosa_campak/ui/home_screen.dart';
import 'package:diagnosa_campak/ui/registrasi_screen.dart';
import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:diagnosa_campak/services/encryption_keys.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  final storage = const FlutterSecureStorage();
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _initEncryptionKeys();
  }

  Future<void> _initEncryptionKeys() async {
    await EncryptionKeys.initKeys();
    setState(() {});
  }

  Future<void> _submitLogin() async {
    setState(() => _isLoading = true);
    if (_formKey.currentState!.validate()) {
      String username = _usernameController.text;
      String password = _passwordController.text;

      bool loginSuccess = await _authenticateUser(username, password);

      if (loginSuccess) {
        prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', username);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nama pengguna atau kata sandi salah.')),
        );
      }
    }
    setState(() => _isLoading = false);
  }

  Future<bool> _authenticateUser(String username, String password) async {
    try {
      final encryptedPassword = encrypt.Encrypter(
              encrypt.AES(EncryptionKeys.key, mode: encrypt.AESMode.cbc))
          .encrypt(password, iv: EncryptionKeys.iv);
      final storedData = await storage.read(key: 'userData');

      if (storedData != null) {
        final Map<String, dynamic> data = jsonDecode(storedData);
        final storedUsername = data['username'];
        final storedEncryptedPasswordBytes = base64Decode(data['password']);
        final storedIv = base64Decode(data['iv']);
        final encrypter = encrypt.Encrypter(
            encrypt.AES(EncryptionKeys.key, mode: encrypt.AESMode.cbc));
        final decryptedPassword = encrypter.decrypt(
            encrypt.Encrypted(storedEncryptedPasswordBytes),
            iv: encrypt.IV(storedIv));

        if (storedUsername == username && decryptedPassword == password) {
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } on FormatException catch (e) {
      print('Error decoding data: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Terjadi kesalahan saat login. Pastikan data tersimpan dengan benar.')));
      return false;
    } on Exception catch (e) {
      print('Error during authentication: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Terjadi kesalahan saat login,coba lagi nanti.')));
    } catch (e) {
      print('Unecpected error during authentication: $e');
      return false;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Image.asset(
                  'assets/images/Login.jpeg',
                  fit: BoxFit.cover,
                  height: double.infinity,
                  width: double.infinity,
                ),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: _usernameController,
                            decoration: const InputDecoration(
                                labelText: 'Nama Pengguna'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Masukkan nama pengguna';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Kata Sandi',
                              suffixIcon: IconButton(
                                icon: _isPasswordVisible
                                    ? const Icon(Icons.visibility)
                                    : const Icon(Icons.visibility_off),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                            obscureText: !_isPasswordVisible,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Masukkan kata sandi';
                              }
                              return null;
                            },
                          ),
                          ElevatedButton(
                              onPressed: _submitLogin,
                              child: const Text('Login')),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const RegistrasiScreen()));
                            },
                            child: const Text(
                                'Belum punya akun? Registrasi di sini'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
