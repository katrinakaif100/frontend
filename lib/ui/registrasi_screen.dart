import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:diagnosa_campak/services/encryption_keys.dart';

class RegistrasiScreen extends StatefulWidget {
  const RegistrasiScreen({super.key});

  @override
  State<RegistrasiScreen> createState() => _RegistrasiScreenState();
}

class _RegistrasiScreenState extends State<RegistrasiScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usiaController = TextEditingController();
  final _alamatController = TextEditingController();
  String _selectedGender = 'Laki-laki';
  final storage = const FlutterSecureStorage();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  late final encrypt.Encrypter encrypter;

  @override
  void initState() {
    super.initState();
    _initEncrypter();
  }

  Future<void> _initEncrypter() async {
    await EncryptionKeys.initKeys();
    setState(() {
      encrypter = encrypt.Encrypter(
          encrypt.AES(EncryptionKeys.key, mode: encrypt.AESMode.cbc));
    });
  }

  Future<void> _submitRegistration() async {
    if (encrypter == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Encrypter not initialized')));
      return;
    }
    setState(() => _isLoading = true);
    if (_formKey.currentState!.validate()) {
      String username = _usernameController.text;
      String password = _passwordController.text;
      int usia = int.tryParse(_usiaController.text) ?? 0;
      String alamat = _alamatController.text;

      try {
        final iv = encrypt.IV.fromSecureRandom(16);
        final encryptedPassword = encrypter.encrypt(password, iv: iv);
        final encryptedPasswordString = base64Encode(encryptedPassword.bytes);
        final userData = {
          'username': username,
          'password': encryptedPasswordString,
          'usia': usia,
          'gender': _selectedGender,
          'alamat': alamat,
          'iv': base64Encode(iv.bytes),
        };

        await storage.write(key: 'userData', value: jsonEncode(userData));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrasi berhasil !')),
        );
        Navigator.pushReplacementNamed(
            context, '/login'); // Pastikan route '/login' sudah didefinisikan
      } on FormatException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usia harus berupa angka')),
        );
      } on Exception catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error during registration: $e')));
      } finally {
        setState(() => _isLoading = false);
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrasi')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(labelText: 'Username'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan username';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
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
                      obscureText: _isPasswordVisible,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan password';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _usiaController,
                      decoration: const InputDecoration(labelText: 'Usia'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan usia';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Usia harus berupa angka';
                        }
                        return null;
                      },
                    ),
                    DropdownButtonFormField<String>(
                      value: _selectedGender,
                      decoration: const InputDecoration(labelText: 'Gender'),
                      items: <String>['Laki-laki', 'Perempuan']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedGender = newValue!;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Pilih gender';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _alamatController,
                      decoration: const InputDecoration(labelText: 'Alamat'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan alamat';
                        }
                        return null;
                      },
                    ),
                    ElevatedButton(
                      onPressed: _submitRegistration,
                      child: const Text('Daftar'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _usiaController.dispose();
    _alamatController.dispose();
    super.dispose();
  }
}
