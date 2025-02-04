import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:path_provider/path_provider.dart';

class FileEncryptionService {

  // Method to generate a 16-byte random IV
  static List<int> generateRandomIV() {
    final random = Random.secure();
    final iv = List<int>.generate(16, (_) => random.nextInt(256)); // Generate 16 random bytes
    return iv;
  }

  // Encrypt File Before Upload
  static Future<Map<String, dynamic>> encryptFile(File file, String encryptionKey) async {
    final key = encrypt.Key.fromUtf8(encryptionKey);
    final iv = encrypt.IV.fromLength(16); // 16-byte IV (you can also use `generateRandomIV()`)

    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));

    final fileBytes = await file.readAsBytes();
    final encryptedBytes = encrypter.encryptBytes(fileBytes, iv: iv).bytes;

    // Create new encrypted file
    final Directory directory = await getApplicationDocumentsDirectory();
    final encryptedFile = File('${directory.path}/encrypted_${file.uri.pathSegments.last}');
    await encryptedFile.writeAsBytes(encryptedBytes);
    
    return {
      "encryptedFile": encryptedFile,
      "iv": base64.encode(iv.bytes),
    };
  }  
}
