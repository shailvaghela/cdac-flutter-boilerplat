// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_demo/models/LoginModel/login_response_new.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'dart:io';

import '../../services/ApiService/api_service.dart';
import '../../services/LocalStorageService/local_storage.dart';

class LoginViewModelNew extends ChangeNotifier {

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

  Future<LoginResponseNew?> performLogin(String username, String password) async {
    try {
      _setLoading(true);

      final response = await _apiService
          .post('login', {'username': username, 'password': password});

      //debugPrint("response--->$response");

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final loginResponse = LoginResponseNew.fromJson(json);

        debugPrint("responseRes--->$loginResponse");

        // Save login state securely
        await _localStorage.setAccessToken(loginResponse.accessToken);
        await _localStorage.setAccessToken(loginResponse.refreshToken);
        await _localStorage.setSecureKey(loginResponse.secureKey);

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
