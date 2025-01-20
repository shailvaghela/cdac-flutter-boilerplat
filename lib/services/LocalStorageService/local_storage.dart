import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalStorage {
  final _storage = const FlutterSecureStorage();

  Future<String?> getUserName() async {
    String? loggedInValue = await _storage.read(key: 'username');
    return loggedInValue; // Return the username
  }

  Future<void> setUserName(String username) async {
    await _storage.write(key: 'username', value: username); // Save username
  }
}
