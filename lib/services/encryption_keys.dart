import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptionKeys {
  static final storage = const FlutterSecureStorage();
  static late final encrypt.Key key;
  static late final encrypt.IV iv;

  static Future<void> initKeys() async {
    try {
      final keyString = await storage.read(key: 'encryptionKey');
      final ivString = await storage.read(key: 'encryptionIV');

      if (keyString == null || ivString == null) {
        key = encrypt.Key.fromSecureRandom(32);
        iv = encrypt.IV.fromSecureRandom(16);
        await storage.write(key: 'encryptionKey', value: key.base64);
        await storage.write(key: 'encryptionIV', value: iv.base64);
      } else {
        key = encrypt.Key.fromBase64(keyString);
        iv = encrypt.IV.fromBase64(ivString);
      }
    } catch (e) {
      // Handle exceptions appropriately, e.g., log the error or show a user-friendly message
      print("Error initializing encryption keys: $e");
      // You might want to throw an exception here or handle it differently based on your app's needs.
      // For example: throw Exception('Failed to initialize encryption keys: $e');
    }
  }
}
