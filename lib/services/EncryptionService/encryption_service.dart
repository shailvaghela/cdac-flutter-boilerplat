import 'package:encrypt/encrypt.dart';

class EncryptionService {
  final Key key;
  final IV iv;

  // Use demo key and IV
  EncryptionService()
      : key = Key.fromUtf8('my32lengthsupersecretnooneknows1'),
        // 32 bytes for AES-256
        iv = IV.fromUtf8('1234567890123456'); // 16 bytes for AES

  String encrypt(String plainText) {
    final encrypter = Encrypter(AES(key));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return encrypted.base64; // Return base64 encoded string
  }

  String decrypt(String encryptedText) {
    final encrypter = Encrypter(AES(key));
    final decrypted = encrypter.decrypt64(encryptedText, iv: iv);
    return decrypted; // Return decrypted plain text
  }
}
