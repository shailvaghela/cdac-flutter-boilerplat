// ignore_for_file: unused_field, unused_element


import 'package:flutter/cupertino.dart';

import '../../services/ApiService/api_service.dart';
import '../../services/LocalStorageService/local_storage.dart';

class RegisterViewModel extends ChangeNotifier {

  final ApiService _apiService = ApiService();
  final LocalStorage _localStorage = LocalStorage();

  bool _isLoading = false;
  String? _errorMessage;
  String? _userName;
  final bool _isLoggedIn = false;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  String? get userName => _userName;

  bool get isLoggedIn => _isLoggedIn;

  // Future<RegisterResponse?> performRegister(String username, String password) async {
  //   try {
  //     _setLoading(true);
  //
  //     final response = await _apiService
  //         .post('auth/login', {'username': username, 'password': password});
  //
  //     //debugPrint("response--->$response");
  //
  //     if (response.statusCode == 200) {
  //       final json = jsonDecode(response.body);
  //       final registerResponse = RegisterResponse.fromJson(json);
  //
  //       debugPrint("responseRes--->${registerResponse.username}");
  //
  //       notifyListeners();
  //       return registerResponse;
  //       // return LoginResponse.fromJson(json);
  //     } else if (response.statusCode == 400 || response.statusCode == 401) {
  //       throw Exception('Invalid credentials');
  //     } else {
  //       throw Exception('Unexpected error: ${response.statusCode}');
  //     }
  //   } on SocketException {
  //     _setError('No internet connection. Please check your network.');
  //   } on HttpException {
  //     _setError('Unable to connect to the server. Please try again later.');
  //   } on FormatException {
  //     _setError('Bad response format. Please contact support.');
  //   } catch (e) {
  //     _setError('An unexpected error occurred: $e');
  //   } finally {
  //     _setLoading(false);
  //   }
  //   return null;
  // }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

}