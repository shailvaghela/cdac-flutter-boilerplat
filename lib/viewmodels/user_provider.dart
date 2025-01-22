import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/ApiService/api_service.dart';
import '../views/screens/Login/login_screen.dart';

class UserProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _userData;
  String? _errorMessage;
  bool _isLoading = false;

  Map<String, dynamic>? get userData => _userData;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  // Fetch current authenticated user
  Future<void> fetchAuthenticatedUser(String accessToken,BuildContext context) async {
    _setLoading(true);

    try {
      final response = await _apiService
          .get('user/me', {'Authorization': 'Bearer $accessToken', 'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        _userData = jsonDecode(response.body);
        _errorMessage = null;
      }else if (response.statusCode == 401) {
        _errorMessage = 'Your session has expired, please login.';
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const LoginScreen()),
        );
      }

      else {
        _errorMessage =
        'Failed to fetch user. Status code: ${response.statusCode}';
        _userData = null;
      }
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
      _userData = null;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
