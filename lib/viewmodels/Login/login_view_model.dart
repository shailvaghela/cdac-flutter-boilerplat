import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../../models/LoginModel/login_response.dart';
import '../../services/ApiService/api_service.dart';
import '../../services/LocalStorageService/local_storage.dart';

class LoginViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final LocalStorage _localStorage = LocalStorage();

  bool _isLoading = false;
  String? _errorMessage;
  String? _userName;
  bool _isLoggedIn = false;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  String? get userName => _userName;

  bool get isLoggedIn => _isLoggedIn;

  Future<LoginResponse?> performLogin(String username, String password) async {
    try {
      _setLoading(true);

      final response = await _apiService
          .post('auth/login', {'username': username, 'password': password});

      //debugPrint("response--->$response");

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final loginResponse = LoginResponse.fromJson(json);

        //debugPrint("responseRes--->${loginResponse.accessToken}");

        // Save login state securely
        await _localStorage.setLoggingState('true');
        await _localStorage.setUserName(username);
        await _localStorage.setAccessToken(loginResponse.accessToken);

        _isLoggedIn = true;
        notifyListeners();
        return loginResponse;
        // return LoginResponse.fromJson(json);
      } else if (response.statusCode == 400 || response.statusCode == 401) {
        throw Exception('Invalid credentials');
      } else {
        throw Exception('Unexpected error: ${response.statusCode}');
      }
    } on SocketException {
      _setError('No internet connection. Please check your network.');
    } on HttpException {
      _setError('Unable to connect to the server. Please try again later.');
    } on FormatException {
      _setError('Bad response format. Please contact support.');
    } catch (e) {
      _setError('An unexpected error occurred: $e');
    } finally {
      _setLoading(false);
    }
    return null;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> checkLoginStatus() async {
    String? loggedInValue = await _localStorage.getLoggingState();
    _isLoggedIn = loggedInValue == 'true'; // Convert string to boolean
    notifyListeners();
  }

  Future<void> logout() async {
    await _localStorage.clearAllStoredData(); // Clear all stored data securely
    _isLoggedIn = false;
    notifyListeners();
  }
}
