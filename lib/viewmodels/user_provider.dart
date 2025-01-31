import 'dart:convert';
import 'package:flutter/material.dart';

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
  Future<void> fetchAuthenticatedUser(
      String accessToken, BuildContext context) async {
    _setLoading(true);

    try {
      if (accessToken.trim().isEmpty) {
        throw Exception("Invalid Access Token");
      }
      _errorMessage = null;
      _userData = {
        "firstName": "Naman",
        "lastName": "Mishra",
        "maidenName": "",
        "age": "28",
        "gender": "Male",
        "email": "namanmishra@example.com",
      };

      // final response = await _apiService.get('user/me', {
      //   'Authorization': 'Bearer $accessToken',
      //   'Content-Type': 'application/json'
      // });

      // if (response.statusCode == 200) {
      //   _userData = jsonDecode(response.body);
      //   _errorMessage = null;
      // } else if (response.statusCode == 401) {
      //   _errorMessage = 'Your session has expired, please login.';
      // } else {
      //   _errorMessage =
      //       'Failed to fetch user. Status code: ${response.statusCode}';
      //   _userData = null;
      // }
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
      _userData = null;
      _setLoading(false);
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
