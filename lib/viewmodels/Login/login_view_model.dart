import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_demo/services/LogService/log_service_new.dart';
import 'package:logger/logger.dart';
import 'dart:convert';
import 'dart:io';
import '../../constants/app_strings.dart';
import '../../models/LoginModel/login_response.dart';
import '../../services/ApiService/api_service.dart';
import '../../services/DatabaseHelper/database_helper.dart';
import '../../services/DatabaseHelper/database_helper_web.dart';
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

  // Future<String?> performLogin(String username, String password) async {
  //
  //   try {
  //     _setLoading(true);
  //   /*  LogServiceNew.logToFile(
  //       message: "Attempting login through API",
  //       screenName: "LoginViewModel",
  //       methodName: "performLogin",
  //       level: Level.debug,
  //     );*/
  //
  //     final requestBody = json.encode({
  //       "username": username,
  //       "password": password,
  //     });
  //
  //     if(kDebugMode){
  //       log("request body");
  //       log(requestBody);
  //     }
  //
  //     final encryptedRequestBody = kDebugMode
  //         ? AESUtil().encryptDataV2(requestBody, AppStrings.encryptDebug)
  //         : AESUtil().encryptDataV2(requestBody, AppStrings.encryptkeyProd);
  //
  //     if(kDebugMode){
  //       log("encrypted request body ");
  //       log(encryptedRequestBody);
  //     }
  //
  //     final response = await _apiService
  //         .postV1(AppStrings.loginEndpoint, encryptedRequestBody);
  //
  //     if(kDebugMode){
  //       log("response status code ${response.statusCode}");
  //       print(response.body);
  //     }
  //
  //     bool isSuccessStatus = (response.statusCode == 200 ||
  //         response.statusCode == 201 ||
  //         response.statusCode == 203 ||
  //         response.statusCode == 204 ||
  //         response.statusCode == 205);
  //
  //
  //     final decryptedResponseBody = kDebugMode
  //         ? AESUtil().decryptDataV2(response.body, AppStrings.encryptDebug)
  //
  //         : AESUtil().decryptDataV2(response.body, AppStrings.encryptkeyProd);
  //
  //     if(kDebugMode){
  //       log("is successful ? $isSuccessStatus");
  //       log(decryptedResponseBody);
  //     }
  //
  //     var deserializedResponse = jsonDecode(decryptedResponseBody);
  //     if (kDebugMode) {
  //       if (Platform.isWindows) {
  //         print("\x1B[2J\x1B[0;0H"); // Clear console on Windows
  //       } else {
  //         print("\x1B[2J\x1B[H"); // Clear console on macOS/Linux
  //       }
  //       print("deserialized Response is ");
  //       print(deserializedResponse);
  //       print(response.statusCode);
  //       print(
  //           "deserialized is map ${deserializedResponse.runtimeType} ${deserializedResponse is! Map}");
  //       print("is deserialized empty ${deserializedResponse.isEmpty}");
  //       print(
  //           "is deserialized status ${deserializedResponse is Map ? deserializedResponse.containsKey('status') : 'no'}");
  //       print(
  //           "is deserialized message ${deserializedResponse is Map ? deserializedResponse.containsKey('message') : 'no'}");
  //       print(
  //           "is deserialized data ${deserializedResponse is Map ? deserializedResponse.containsKey('data') : 'no'}");
  //       print(
  //           "is deserialized data runtimetype ${deserializedResponse is Map ? deserializedResponse.containsKey('data') ? deserializedResponse['data'].runtimeType : '' : 'no'}");
  //     }
  //
  //
  //     // Preliminary Response Validation
  //     if (deserializedResponse is! Map) {
  //       if (kDebugMode) {
  //         log("Invalid response body from server: Expected a Map");
  //       }
  //       throw Exception("The response body from server is of invalid format");
  //     }
  //
  //     // Ensure "status" exists
  //     if (!deserializedResponse.containsKey("status")) {
  //       if (kDebugMode) log("A valid response must contain 'status'");
  //       throw Exception("The response body from server is of invalid format");
  //     }
  //
  //     // "status" must be either "success" or "error"
  //     String status =
  //     deserializedResponse['status'].toString().trim().toLowerCase();
  //     if (status != "success" && status != "error") {
  //       if (kDebugMode) {
  //         log("A valid response 'status' must be either 'success' or 'error'");
  //       }
  //       throw Exception("The response body from server is of invalid format");
  //     }
  //
  //     // Ensure "message" exists
  //     if (!deserializedResponse.containsKey("message")) {
  //       if (kDebugMode) log("A valid response must contain 'message'");
  //       throw Exception("The response body from server is of invalid format");
  //     }
  //
  //     // "message" must be a non-empty String
  //     if (deserializedResponse["message"] is! String ||
  //         deserializedResponse["message"].toString().trim().isEmpty) {
  //       if (kDebugMode) {
  //         log("A valid response must contain a non-empty string 'message'");
  //       }
  //       throw Exception("The response body from server is of invalid format");
  //     }
  //
  //     // Ensure at least one of "data" or "error" exists
  //     bool hasData = deserializedResponse.containsKey("data");
  //     bool hasError = deserializedResponse.containsKey("error");
  //
  //     if (isSuccessStatus && hasError) {
  //       if (kDebugMode) {
  //         log("A valid success response status code should contain 'data' and not 'error'");
  //       }
  //       throw Exception("The response body from server is of invalid format");
  //     }
  //
  //     if (!isSuccessStatus && hasData) {
  //       if (kDebugMode) {
  //         log("A valid error response status code should contain 'error' and not 'data'");
  //       }
  //       throw Exception("The response body from server is of invalid format");
  //     }
  //
  //     if (!hasData && !hasError) {
  //       if (kDebugMode) {
  //         log("A valid response must contain either 'data' or 'error'");
  //       }
  //       throw Exception("The response body from server is of invalid format");
  //     }
  //
  //     // Ensure "data" or "error" is of valid type (String, List, or Map)
  //     if (hasData &&
  //         deserializedResponse["data"] is! String &&
  //         deserializedResponse["data"] is! List &&
  //         deserializedResponse["data"] is! Map) {
  //       if (kDebugMode) log("'data' must be of type String, List, or Map");
  //       throw Exception("Invalid 'data' type in response from server");
  //     }
  //
  //     if (hasError &&
  //         deserializedResponse["error"] is! String &&
  //         deserializedResponse["error"] is! List &&
  //         deserializedResponse["error"] is! Map) {
  //       if (kDebugMode) log("'error' must be of type String, List, or Map");
  //       throw Exception("Invalid 'error' type in response from server");
  //     }
  //
  //     if(hasError && !isSuccessStatus){
  //       if(kDebugMode){
  //         log("Ran into error at api level");
  //         print(deserializedResponse['status']);
  //         print(deserializedResponse['message']);
  //         print(deserializedResponse['error']);
  //       }
  //       throw Exception(deserializedResponse['error'].toString());
  //     }
  //
  //     if(kDebugMode){
  //       log("After all is done ");
  //       log(deserializedResponse.toString());
  //     }
  //
  //     String dbResult;
  //     // Add data to the database
  //     if(kIsWeb){
  //
  //          dbResult = await DbHelper().insertUserLoginDetails(username, deserializedResponse["data"][
  //         "accessToken"],
  //           // Decrypted access token // encrypted via encryptDebug/encryptProd
  //           deserializedResponse["data"][
  //           "refreshToken"],
  //           // Decrypted refresh token // encrypted via encryptDebug/encryptProd
  //           deserializedResponse["data"]["userEncryptionKey"]);
  //
  //         if (kDebugMode) {
  //           debugPrint("DB save result $dbResult");
  //         }
  //       }
  //     else{
  //       // Save login details to the database
  //        dbResult = await DatabaseHelper().insertUserLoginDetails(
  //         username,
  //         // Decrypted username // encrypted via encryptDebug/encryptProd
  //         deserializedResponse["data"][
  //         "accessToken"],
  //         // Decrypted access token // encrypted via encryptDebug/encryptProd
  //         deserializedResponse["data"][
  //         "refreshToken"],
  //         // Decrypted refresh token // encrypted via encryptDebug/encryptProd
  //         deserializedResponse["data"]["userEncryptionKey"], // Decrypted encryption key // encrypted via encryptDebug/encryptProd
  //       );
  //
  //
  //       if (kDebugMode) {
  //         debugPrint("DB save result $dbResult");
  //       }
  //     }
  //
  //        /*LogServiceNew.logToFile(
  //         message: "Got successful login response through API",
  //         screenName: "LoginViewModel",
  //         methodName: "performLogin",
  //         level: Level.debug,
  //       );*/
  //       //
  //       // _setLoading(false);
  //       await _localStorage.setLoggingState('true');
  //
  //
  //       if(kDebugMode){
  //         print("Local storage set logging");
  //       }
  //
  //       return "success";
  //   } catch (e, stackTrace) {
  //     if (kDebugMode) {
  //       log(e.toString());
  //       debugPrintStack();
  //     }
  //    /* LogServiceNew.logToFile(
  //       message: "Failed to login because $e",
  //       screenName: "LoginViewModel",
  //       methodName: "performLogin",
  //       level: Level.error,
  //       stackTrace: "$stackTrace",
  //     );*/
  //     return "Failed to login. Please check your credentials and try again.";
  //   }
  //   finally {
  //     _setLoading(false);
  //   }
  // }

  Future<String?> performLogin(String username, String password) async {
    try {
      _setLoading(true);

      final requestBody = json.encode({
        "username": username,
        "password": password,
      });

      if (kDebugMode) {
        log("Request body: $requestBody");
      }

      // Encrypt the request body
      final encryptedRequestBody = kDebugMode
          ? AESUtil().encryptDataV2(requestBody, AppStrings.encryptDebug)
          : AESUtil().encryptDataV2(requestBody, AppStrings.encryptkeyProd);

      if (kDebugMode) {
        log("Encrypted request body: $encryptedRequestBody");
      }

      // Make API call
      final response = await _apiService.postV1(AppStrings.loginEndpoint, encryptedRequestBody);

      if (kDebugMode) {
        log("Response status code: ${response.statusCode}");
        log("Response body: ${response.body}");
      }

      bool isSuccessStatus = [200, 201, 203, 204, 205].contains(response.statusCode);

      // Decrypt the response body
      final decryptedResponseBody = kDebugMode
          ? AESUtil().decryptDataV2(response.body, AppStrings.encryptDebug)
          : AESUtil().decryptDataV2(response.body, AppStrings.encryptkeyProd);

      if (kDebugMode) {
        log("Decrypted response body: $decryptedResponseBody");
      }

      var deserializedResponse = jsonDecode(decryptedResponseBody);

      // Preliminary Response Validation
      if (deserializedResponse is! Map) {
        log("Invalid response body: Expected a Map.");
        throw Exception("Invalid response format.");
      }

      // Validate necessary fields in the response
      if (!deserializedResponse.containsKey("status")) {
        log("Response must contain 'status'");
        throw Exception("Invalid response format.");
      }

      String status = deserializedResponse['status'].toString().trim().toLowerCase();
      if (status != "success" && status != "error") {
        log("Invalid 'status' in response");
        throw Exception("Invalid response format.");
      }

      if (!deserializedResponse.containsKey("message")) {
        log("Response must contain 'message'");
        throw Exception("Invalid response format.");
      }

      if (deserializedResponse["message"] is! String || deserializedResponse["message"].toString().trim().isEmpty) {
        log("Invalid 'message' in response");
        throw Exception("Invalid response format.");
      }

      bool hasData = deserializedResponse.containsKey("data");
      bool hasError = deserializedResponse.containsKey("error");

      // Additional validation checks
      if (isSuccessStatus && hasError) {
        log("Success response should not contain 'error'");
        throw Exception("Invalid response format.");
      }

      if (!isSuccessStatus && hasData) {
        log("Error response should not contain 'data'");
        throw Exception("Invalid response format.");
      }

      if (!hasData && !hasError) {
        log("Response must contain either 'data' or 'error'");
        throw Exception("Invalid response format.");
      }

      // Validate the type of 'data' and 'error'
      if (hasData && !(deserializedResponse["data"] is String || deserializedResponse["data"] is List || deserializedResponse["data"] is Map)) {
        log("Invalid 'data' type");
        throw Exception("Invalid data type.");
      }

      if (hasError && !(deserializedResponse["error"] is String || deserializedResponse["error"] is List || deserializedResponse["error"] is Map)) {
        log("Invalid 'error' type");
        throw Exception("Invalid error type.");
      }

      if (hasError && !isSuccessStatus) {
        log("API error: ${deserializedResponse['error']}");
        throw Exception(deserializedResponse['error'].toString());
      }

      if (kDebugMode) {
        log("Response validated successfully.");
      }

      // Handle the database insertion based on platform
      String dbResult;
      if (kIsWeb) {
        dbResult = await DbHelper().insertUserLoginDetails(
          username,
          deserializedResponse["data"]["accessToken"],
          deserializedResponse["data"]["refreshToken"],
          deserializedResponse["data"]["userEncryptionKey"],
        );
        log("Web DB save result: $dbResult");
      } else {
        dbResult = await DatabaseHelper().insertUserLoginDetails(
          username,
          deserializedResponse["data"]["accessToken"],
          deserializedResponse["data"]["refreshToken"],
          deserializedResponse["data"]["userEncryptionKey"],
        );
        log("Non-web DB save result: $dbResult");
      }

      // Set local storage logging state
      await _localStorage.setLoggingState('true');
      log("Local storage set to 'true'");

      return "success";
    } catch (e, stackTrace) {
      log("Error during login: $e");
      debugPrintStack(stackTrace: stackTrace);

      return "Failed to login. Please check your credentials and try again.";
    } finally {
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
