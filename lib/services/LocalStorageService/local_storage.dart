import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalStorage {
  final _storage = const FlutterSecureStorage();

  Future<void> setLoggingState(String isLoggedIn) async {
    await _storage.write(
        key: 'isLoggedIn', value: isLoggedIn); // Save login state
  }

  Future<String?> getLoggingState() async {
    String? isLoggedIn = await _storage.read(key: 'isLoggedIn');
    return isLoggedIn; // Return the login state
  }

  Future<void> setUserName(String username) async {
    await _storage.write(key: 'username', value: username); // Save username
  }

  Future<String?> getUserName() async {
    String? loggedInValue = await _storage.read(key: 'username');
    return loggedInValue; // Return the username
  }

  Future<void> setAccessToken(String accessToken) async {
    await _storage.write(
        key: 'accessToken', value: accessToken); // Save accessToken
  }

  Future<String?> getAccessToken() async {
    String? accessToken = await _storage.read(key: 'accessToken');
    return accessToken; // Return the accessToken
  }

  Future<void> clearAllStoredData() async {
    await _storage.deleteAll(); // Clear all stored data securely
  }

  Future<void> setSecureKey(String secureKey) async {
    await _storage.write(
        key: 'SecureKey',value: secureKey); // Save accessToken
  }

}
