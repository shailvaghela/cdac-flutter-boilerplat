import 'package:encrypt/encrypt.dart' as encrypt;

class AESUtil {
  String encryptData(String plainText, String existingKey) {
    // Check the length of the existing key to match AES requirements (16 bytes for AES-128 or 32 bytes for AES-256)
    final key = encrypt.Key.fromUtf8(existingKey); // Ensure this key is 16 or 32 bytes in length
    final iv = encrypt.IV.fromLength(16); // Generate a 16-byte IV (same as encryption)
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return encrypted.base64; // Return the encrypted data as a base64 string
  }

  // Function to decrypt data using an existing key
  String decryptData(String encryptedText, String existingKey) {
    final key = encrypt.Key.fromUtf8(existingKey); // Use the existing key
    final iv = encrypt.IV.fromLength(16); // The same IV used for encryption
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final decrypted = encrypter.decrypt64(encryptedText, iv: iv);
    return decrypted; // Return the decrypted plain text
  }

  // Decrypt method using a fixed key
  String decryptDataV2(String encryptedData, String securityKey) {
    final key = encrypt.Key.fromUtf8(securityKey.padRight(32, ' '));  // 32-byte key for AES-192
    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.ecb));  // ECB mode (no IV)

    final decrypted = encrypter.decrypt64(encryptedData);
    return decrypted;
  }

  // Encrypt method using a fixed key
  String encryptDataV2(String data, String securityKey) {
    final key = encrypt.Key.fromUtf8(securityKey.padRight(32, ' '));  // 32-byte key for AES-192
    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.ecb));  // ECB mode (no IV)

    final encrypted = encrypter.encrypt(data);
    return encrypted.base64;  // Return Base64 encoded result
  }
}
