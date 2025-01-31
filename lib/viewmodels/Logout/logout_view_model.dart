import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/models/LoginModel/login_response_new.dart';
import 'package:flutter_demo/models/LogoutModel/logout_response.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'dart:io';

import '../../constants/app_strings.dart';
import '../../services/ApiService/api_service.dart';
import '../../services/EncryptionService/encryption_service_new.dart';
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

  Future<String> performLogout(String username) async {
    try {

      _setLoading(true);

      final requestBody = json.encode({"username": username});

      final encryptedRequestBody =  kDebugMode
          ? AESUtil().encryptDataV2(requestBody, AppStrings.encryptDebug)
          : AESUtil().encryptDataV2(requestBody, AppStrings.encryptkeyProd);

      final response = await _apiService
          .postV1(AppStrings.logoutEndpoint, encryptedRequestBody);

      final decryptedResponseBody =  kDebugMode
          ? AESUtil().decryptDataV2(response.body, AppStrings.encryptDebug)
          : AESUtil().decryptDataV2(response.body, AppStrings.encryptkeyProd);

      if (response.statusCode == 200) {
        await _localStorage.clearAllStoredData();
        final jsonResponse = json.decode(decryptedResponseBody);
        return jsonResponse["message"].toString();
      }
      else if (response.statusCode == 400 || response.statusCode == 404 || response.statusCode == 500) {
        final jsonResponse = json.decode(decryptedResponseBody);

        if (kDebugMode) {
          log('response not 200 ');
          // log(jsonResponse.statusCode.toString());
          log(jsonResponse.body);
        }

        return jsonResponse["message"].toString();
      }
      else {
        throw Exception("Unexpected error occurred");
      }
    }catch (e) {
      if (kDebugMode) {
        log(e.toString());
        debugPrintStack();
      }
      return "Failed to login. Please check your credentials and try again.";
    }
    finally {
      _setLoading(false);
    }
  }

/*
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
*/

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> logout() async {
    await _localStorage.clearAllStoredData(); // Clear all stored data securely
    _isLoggedIn = false;
    notifyListeners();
  }

}
