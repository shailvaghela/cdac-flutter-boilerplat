// ignore_for_file: unused_import

import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_demo/models/LoginModel/login_response_new.dart';
import 'package:flutter_demo/models/LogoutModel/logout_response.dart';
import 'package:flutter_demo/services/LogService/log_service_new.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'dart:convert';
import 'dart:io';

import '../../constants/app_strings.dart';
import '../../services/ApiService/api_service.dart';
import '../../services/EncryptionService/encryption_service_new.dart';
import '../../services/LocalStorageService/local_storage.dart';

class LogoutViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final LocalStorage _localStorage = LocalStorage();
  // ignore: unused_field
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

      LogServiceNew.logToFile(
        message: "Attempting logout through API",
        screenName: "LogoutViewModelNew",
        methodName: "performLogout",
        level: Level.debug,
      );

      final requestBody = json.encode({"username": username});

      final encryptedRequestBody = kDebugMode
          ? AESUtil().encryptDataV2(requestBody, AppStrings.encryptDebug)
          : AESUtil().encryptDataV2(requestBody, AppStrings.encryptkeyProd);

      final response = await _apiService.postV1(
          AppStrings.logoutEndpoint, encryptedRequestBody);

      final decryptedResponseBody = kDebugMode
          ? AESUtil().decryptDataV2(response.body, AppStrings.encryptDebug)
          : AESUtil().decryptDataV2(response.body, AppStrings.encryptkeyProd);

      if (response.statusCode == 200) {
        LogServiceNew.logToFile(
          message: "Successfully logged out through API",
          screenName: "LogoutViewModelNew",
          methodName: "performLogout",
          level: Level.debug,
        );
        await _localStorage.clearAllStoredData();
        final jsonResponse = json.decode(decryptedResponseBody);

        if (jsonResponse is! Map ||
            !jsonResponse.containsKey("status") ||
            !jsonResponse.containsKey("message") ||
            jsonResponse['status'].toString().trim().isEmpty) {
          LogServiceNew.logToFile(
            message: "Logout Error. Invalid response from API",
            screenName: "LogoutViewMode",
            methodName: "performLogout",
            level: Level.warning,
          );
          throw Exception("Invalid Response from API");
        }
        if (jsonResponse['status'] != 'succcess') {
          LogServiceNew.logToFile(
            message: "Failed to logout through API",
            screenName: "LogoutViewMode",
            methodName: "performLogout",
            level: Level.warning,
          );
        }
        return jsonResponse["message"].toString();
      } else if (response.statusCode == 400 ||
          response.statusCode == 404 ||
          response.statusCode == 500) {
        final jsonResponse = json.decode(decryptedResponseBody);

        if (kDebugMode) {
          log('response not 200 ');
          log(jsonResponse.body);
        }
        LogServiceNew.logToFile(
          message: "Could not log out through API",
          screenName: "LogoutViewModelNew",
          methodName: "performLogout",
          level: Level.debug,
          stackTrace: "$jsonResponse",
        );

        return jsonResponse["message"].toString();
      } else {
        LogServiceNew.logToFile(
          message: "Could not log out through API",
          screenName: "LogoutViewModelNew",
          methodName: "performLogout",
          level: Level.debug,
          stackTrace: "Invalid response content on non 200 API status",
        );
        throw Exception("Unexpected error occurred");
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        log(e.toString());
        debugPrintStack();
      }
      LogServiceNew.logToFile(
          message: "Failed to logout through API: $e",
          screenName: "LogoutViewModelNew",
          methodName: "performLogout",
          level: Level.error,
          stackTrace: "$stackTrace",
        );
      return "Failed to logout. Please check your credentials and try again.";
    } finally {
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
