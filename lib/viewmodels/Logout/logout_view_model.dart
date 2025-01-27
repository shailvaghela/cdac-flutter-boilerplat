import 'package:flutter/material.dart';
import 'package:flutter_demo/models/LoginModel/login_response_new.dart';
import 'package:flutter_demo/models/LogoutModel/logout_response.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'dart:io';

import '../../services/ApiService/api_service.dart';
import '../../services/LocalStorageService/local_storage.dart';

class LogoutViewModel extends ChangeNotifier {

  final ApiService _apiService = ApiService();
  final LocalStorage _localStorage = LocalStorage();
  final FlutterSecureStorage _flutterSecureStorage = FlutterSecureStorage();

  bool _isLoading = false;
  String? _errorMessage;
  String? _userName;
  bool _isLoggedIn = false;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  String? get userName => _userName;

  bool get isLoggedIn => _isLoggedIn;

  Future<LogoutResponse?> performLogout(String username) async {
    try {
      _setLoading(true);

      final response = await _apiService
          .post('api/auth/login', {'username': username});

      //debugPrint("response--->$response");

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final logoutResponse = LogoutResponse.fromJson(json);

        await _localStorage.clearAllStoredData();
        _isLoggedIn = false;
        notifyListeners();
        return logoutResponse;
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

}
