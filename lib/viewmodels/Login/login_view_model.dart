import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

      if(kDebugMode){
        log("request body");
        log(requestBody);
      }

      final encryptedRequestBody = kDebugMode
          ? AESUtil().encryptDataV2(requestBody, AppStrings.encryptDebug)
          : AESUtil().encryptDataV2(requestBody, AppStrings.encryptkeyProd);

      if(kDebugMode){
        log("encrypted request body ");
        log(encryptedRequestBody);
      }

      final response = await _apiService
          .postV1(AppStrings.loginEndpoint, encryptedRequestBody);

      if(kDebugMode){
        log("response status code ${response.statusCode}");
        print(response.body);
      }

      bool isSuccessStatus = (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 203 ||
          response.statusCode == 204 ||
          response.statusCode == 205);


      final decryptedResponseBody = kDebugMode
          ? AESUtil().decryptDataV2(response.body, AppStrings.encryptDebug)

          : AESUtil().decryptDataV2(response.body, AppStrings.encryptkeyProd);

      if(kDebugMode){
        log("is successful ? $isSuccessStatus");
        log(decryptedResponseBody);
      }

      var deserializedResponse = jsonDecode(decryptedResponseBody);
      if (kDebugMode) {
        if (Platform.isWindows) {
          print("\x1B[2J\x1B[0;0H"); // Clear console on Windows
        } else {
          print("\x1B[2J\x1B[H"); // Clear console on macOS/Linux
        }
        print("deserialized Response is ");
        print(deserializedResponse);
        print(response.statusCode);
        print(
            "deserialized is map ${deserializedResponse.runtimeType} ${deserializedResponse is! Map}");
        print("is deserialized empty ${deserializedResponse.isEmpty}");
        print(
            "is deserialized status ${deserializedResponse is Map ? deserializedResponse.containsKey('status') : 'no'}");
        print(
            "is deserialized message ${deserializedResponse is Map ? deserializedResponse.containsKey('message') : 'no'}");
        print(
            "is deserialized data ${deserializedResponse is Map ? deserializedResponse.containsKey('data') : 'no'}");
        print(
            "is deserialized data runtimetype ${deserializedResponse is Map ? deserializedResponse.containsKey('data') ? deserializedResponse['data'].runtimeType : '' : 'no'}");
      }


      // Preliminary Response Validation
      if (deserializedResponse is! Map) {
        if (kDebugMode) {
          log("Invalid response body from server: Expected a Map");
        }
        throw Exception("The response body from server is of invalid format");
      }

      // Ensure "status" exists
      if (!deserializedResponse.containsKey("status")) {
        if (kDebugMode) log("A valid response must contain 'status'");
        throw Exception("The response body from server is of invalid format");
      }

      // "status" must be either "success" or "error"
      String status =
      deserializedResponse['status'].toString().trim().toLowerCase();
      if (status != "success" && status != "error") {
        if (kDebugMode) {
          log("A valid response 'status' must be either 'success' or 'error'");
        }
        throw Exception("The response body from server is of invalid format");
      }

      // Ensure "message" exists
      if (!deserializedResponse.containsKey("message")) {
        if (kDebugMode) log("A valid response must contain 'message'");
        throw Exception("The response body from server is of invalid format");
      }

      // "message" must be a non-empty String
      if (deserializedResponse["message"] is! String ||
          deserializedResponse["message"].toString().trim().isEmpty) {
        if (kDebugMode) {
          log("A valid response must contain a non-empty string 'message'");
        }
        throw Exception("The response body from server is of invalid format");
      }

      // Ensure at least one of "data" or "error" exists
      bool hasData = deserializedResponse.containsKey("data");
      bool hasError = deserializedResponse.containsKey("error");

      if (isSuccessStatus && hasError) {
        if (kDebugMode) {
          log("A valid success response status code should contain 'data' and not 'error'");
        }
        throw Exception("The response body from server is of invalid format");
      }

      if (!isSuccessStatus && hasData) {
        if (kDebugMode) {
          log("A valid error response status code should contain 'error' and not 'data'");
        }
        throw Exception("The response body from server is of invalid format");
      }

      if (!hasData && !hasError) {
        if (kDebugMode) {
          log("A valid response must contain either 'data' or 'error'");
        }
        throw Exception("The response body from server is of invalid format");
      }

      // Ensure "data" or "error" is of valid type (String, List, or Map)
      if (hasData &&
          deserializedResponse["data"] is! String &&
          deserializedResponse["data"] is! List &&
          deserializedResponse["data"] is! Map) {
        if (kDebugMode) log("'data' must be of type String, List, or Map");
        throw Exception("Invalid 'data' type in response from server");
      }

      if (hasError &&
          deserializedResponse["error"] is! String &&
          deserializedResponse["error"] is! List &&
          deserializedResponse["error"] is! Map) {
        if (kDebugMode) log("'error' must be of type String, List, or Map");
        throw Exception("Invalid 'error' type in response from server");
      }

      if(hasError && !isSuccessStatus){
        if(kDebugMode){
          log("Ran into error at api level");
          print(deserializedResponse['status']);
          print(deserializedResponse['message']);
          print(deserializedResponse['error']);
        }
        throw Exception(deserializedResponse['error'].toString());
      }

      if(kDebugMode){
        log("After all is done ");
        log(deserializedResponse.toString());
      }
        // Save login details to the database
        String dbResult = await DatabaseHelper().insertUserLoginDetails(
          username,
          // Decrypted username // encrypted via encryptDebug/encryptProd
          deserializedResponse["data"][
          "accessToken"],
          // Decrypted access token // encrypted via encryptDebug/encryptProd
          deserializedResponse["data"][
          "refreshToken"],
          // Decrypted refresh token // encrypted via encryptDebug/encryptProd
          deserializedResponse["data"]["userEncryptionKey"], // Decrypted encryption key // encrypted via encryptDebug/encryptProd
        );

        if (kDebugMode) {
          debugPrint("DB save result $dbResult");
        }
        //
        // _setLoading(false);
        await _localStorage.setLoggingState('true');

        if(kDebugMode){
          print("Local storage set logging");
        }

        return "success";
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
