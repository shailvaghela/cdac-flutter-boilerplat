import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:io';
import '../../constants/app_strings.dart';
import '../../models/LoginModel/login_response.dart';
import '../../services/ApiService/api_service.dart';
import '../../services/DatabaseHelper/database_helper.dart';
import '../../services/EncryptionService/encryption_service_new.dart';
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

  Future<LoginResponse?> performLogins(String username, String password) async {
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

  Future<String?> performLogin(String username, String password) async {
    try {
      _setLoading(true);

      final encryptedUsername = kDebugMode
          ? AESUtil().encryptDataV2(username, AppStrings.encryptDebug)
          : AESUtil().encryptDataV2(username, AppStrings.encryptkeyProd);

      final requestBody = json.encode({
        "username": username,
        "password": password,
      });

      final encryptedRequestBody = kDebugMode
          ? AESUtil().encryptDataV2(requestBody, AppStrings.encryptDebug)
          : AESUtil().encryptDataV2(requestBody, AppStrings.encryptkeyProd);

      final response = await _apiService
          .postV1(AppStrings.loginEndpoint, encryptedRequestBody);

      if (kDebugMode) {
        log(response.statusCode.toString());
        log(response.body);
        // log(response.request!.headers.toString());
      }

      final decryptedResponseBody = kDebugMode
          ? AESUtil().decryptDataV2(response.body, AppStrings.encryptDebug)

          : AESUtil().decryptDataV2(response.body, AppStrings.encryptkeyProd);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(decryptedResponseBody);

        if (kDebugMode) {
          debugPrint("Login response body ");
        }

        if (kDebugMode) {
          print("showing base response after login attempt");
          print(jsonResponse);
        }

        if (jsonResponse is! Map) {
          return "Server Error. Please try again";
        }

        if (kDebugMode) {
          print("showing base response after map check");

          log("${jsonResponse["data"] is! Map}");
          log("----");

          log("${!jsonResponse["data"].keys.toList().contains("accessToken")}");
          log("----");

          log("${!jsonResponse["data"].keys.toList().contains(
              "refreshToken")}");
          log("----");

          log("${!jsonResponse["data"].keys.toList().contains(
              'userEncryptionKey')}");
          log("----");
        }

        if (!jsonResponse.keys.toList().contains("status") ||
            !jsonResponse.keys.toList().contains("message") ||
            !jsonResponse.keys.toList().contains("data") ||
            jsonResponse["data"] is! Map ||
            !jsonResponse["data"].keys.toList().contains("accessToken") ||
            !jsonResponse["data"].keys.toList().contains("refreshToken") ||
            !jsonResponse["data"].keys.toList().contains('userEncryptionKey')) {
          return "Server Error. Please try again";
        }
        if (kDebugMode) {
          log("showing base response after more checks");
          // print(jsonResponse);
          log("${!jsonResponse["status"].toString().toLowerCase().contains(
              "success")}");
        }

        if (!jsonResponse["status"]
            .toString()
            .toLowerCase()
            .contains("success")) {
          return jsonResponse["message"];
        }

        if (kDebugMode) {
          print("showing base response after far more check");
          // print(jsonResponse);
        }

        // Save login details to the database
        String dbResult = await DatabaseHelper().insertUserLoginDetails(
          encryptedUsername,
          // Encrypted username // encrypted via encryptDebug/encryptProd
          jsonResponse["data"][
          "accessToken"],
          // Encrypted access token // encrypted via encryptDebug/encryptProd
          jsonResponse["data"][
          "refreshToken"],
          // Encrypted refresh token // encrypted via encryptDebug/encryptProd
          jsonResponse["data"]["userEncryptionKey"], // Decrypted encryption key // encrypted via encryptDebug/encryptProd
        );

        if (kDebugMode) {
          debugPrint("DB save result $dbResult");
        }

        _setLoading(false);
        await _localStorage.setLoggingState('true');

        return jsonResponse["message"].toString();
      } else if (response.statusCode == 400 || response.statusCode == 404 || response.statusCode == 500) {
        responseMessage(decryptedResponseBody);
      }
      else {
        throw Exception("Unexpected error occurred");
      }
    } catch (e) {
      if (kDebugMode) {
        log(e.toString());
        debugPrintStack();
      }
      return "Failed to login. Please check your credentials and try again.";
    }
    finally {
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

  String responseMessage(String decryptedResponseBody){
    final jsonResponse = json.decode(decryptedResponseBody);

    if (kDebugMode) {
      log('response not 200 ');
      log(jsonResponse.statusCode.toString());
      log(jsonResponse.body);
    }

    return jsonResponse["message"].toString();
  }

}
