import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter_demo/constants/app_strings.dart';
import 'package:flutter_demo/constants/base_url_config.dart';
import 'package:flutter_demo/models/ResponseModel/base_response_model.dart';
import 'package:flutter_demo/models/ResponseModel/error_response_dart.dart';
import 'package:flutter_demo/models/ResponseModel/login_response_data.dart';
import 'package:flutter_demo/services/DatabaseHelper/database_helper.dart';
import 'package:flutter_demo/services/EncryptionService/encryption_service_new.dart';
import 'package:http/http.dart' as http;

class AuthService {
  Future<String> performLogin(String username, String password) async {
    try {
      final encryptedUsername = kDebugMode
          ? AESUtil().encryptData(username, AppStrings.encryptDebug)
          : AESUtil().encryptData(username, AppStrings.encryptkeyProd);
      final encryptedPassword = kDebugMode
          ? AESUtil().encryptData(password, AppStrings.encryptDebug)
          : AESUtil().encryptData(password, AppStrings.encryptDebug);

      final requestBody = json.encode({
        "username": encryptedUsername,
        "password": encryptedPassword,
      });

      final headers = {
        "Content-Type": "application/json",
      };

      final url = Uri.parse(
          "${BaseUrlConfig.baseUrlDemoDevelopment}/${AppStrings.loginEndpoint}");

      final response =
          await http.post(url, headers: headers, body: requestBody);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (kDebugMode) {
          debugPrint("Login response body ");
          debugPrint(jsonResponse);
        }

        // Parse the response and handle the login data
        final baseResponse = BaseResponse<LoginResponseData>.fromJson(
          jsonResponse,
          (data) => LoginResponseData.fromJson(data as Map<String, dynamic>),
        );

        // Check if login was successful
        if (baseResponse.status == "success") {
          // Decrypt the encryption key
          final decryptedEncryptionKey = AESUtil().decryptData(
              baseResponse.content!.encryptionKey, AppStrings.encryptDebug);

          // Save login details to the database
          String dbResult = await DatabaseHelper().insertUserLoginDetails(
            encryptedUsername, // Encrypted username // encrypted via encryptDebug/encryptProd
            baseResponse.content!
                .accessToken, // Encrypted access token // encrypted via encryptDebug/encryptProd
            baseResponse.content!
                .refreshToken, // Encrypted refresh token // encrypted via encryptDebug/encryptProd
            decryptedEncryptionKey, // Decrypted encryption key // encrypted via encryptDebug/encryptProd
          );

          if (kDebugMode) {
            debugPrint("DB save result $dbResult");
          }

          // Return appropriate message based on DB save result
          if (dbResult == "success") {
            return baseResponse.message; // Return success message
          } else {
            return "Login successful, but failed to store credentials."; // Handle DB save failure
          }
        } else {
          return baseResponse.message; // Return error message from the response
        }
      } else if (response.statusCode == 400) {
        final jsonResponse = json.decode(response.body);
        final baseResponse = BaseResponse<ErrorResponseData>.fromJson(
          jsonResponse,
          ((error) => ErrorResponseData.fromJson(error as Map<String, String>)),
        );
        return baseResponse.message; // Return error message if login failed
      } else {
        throw Exception("Unexpected error occurred");
      }
    } catch (e) {
      if (kDebugMode) {
        log(e.toString());
        debugPrintStack();
      }

      return "Failed to login. Please check your credentials and try again.";
    }
  }

  Future<String> performRegistration(
      String username,
      String password,
      String email,
      String firstName,
      String middleName,
      String lastName,
      String mobile) async {
    try {
      // Encrypt all fields using the app's security key
      final encryptedUsername = kDebugMode
          ? AESUtil().encryptData(username, AppStrings.encryptDebug)
          : AESUtil().encryptData(username, AppStrings.encryptkeyProd);

      final encryptedPassword = kDebugMode
          ? AESUtil().encryptData(password, AppStrings.encryptDebug)
          : AESUtil().encryptData(password, AppStrings.encryptkeyProd);

      final encryptedEmail = kDebugMode
          ? AESUtil().encryptData(email, AppStrings.encryptDebug)
          : AESUtil().encryptData(email, AppStrings.encryptkeyProd);

      final encryptedFirstName = kDebugMode
          ? AESUtil().encryptData(firstName, AppStrings.encryptDebug)
          : AESUtil().encryptData(firstName, AppStrings.encryptkeyProd);

      final encryptedMiddleName = kDebugMode
          ? AESUtil().encryptData(middleName, AppStrings.encryptDebug)
          : AESUtil().encryptData(middleName, AppStrings.encryptkeyProd);

      final encryptedLastName = kDebugMode
          ? AESUtil().encryptData(lastName, AppStrings.encryptDebug)
          : AESUtil().encryptData(lastName, AppStrings.encryptkeyProd);

      final encryptedMobile = kDebugMode
          ? AESUtil().encryptData(mobile, AppStrings.encryptDebug)
          : AESUtil().encryptData(mobile, AppStrings.encryptkeyProd);

      // Prepare the request body with encrypted data
      final requestBody = json.encode({
        "username": encryptedUsername,
        "password": encryptedPassword,
        "email": encryptedEmail,
        "firstName": encryptedFirstName,
        "middleName": encryptedMiddleName,
        "lastName": encryptedLastName,
        "mobile": encryptedMobile,
      });

      final headers = {
        "Content-Type": "application/json",
      };

      final url = Uri.parse(
          "${BaseUrlConfig.baseUrlDemoDevelopment}/${AppStrings.registerEndpoint}");

      // Make the POST request to the registration endpoint
      final response =
          await http.post(url, headers: headers, body: requestBody);

      if (response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);

        // Parse the response and handle the registration data
        final baseResponse = BaseResponse<Map<String, String>>.fromJson(
          jsonResponse,
          (data) => data as Map<String,
              String>, // This expects a map of encrypted user details
        );

        // Check if registration was successful
        if (baseResponse.status == "success") {
          return baseResponse.message; // Return success message
        } else {
          return baseResponse.message; // Return error message from the response
        }
      } else if (response.statusCode == 400) {
        final jsonResponse = json.decode(response.body);
        final baseResponse = BaseResponse<ErrorResponseData>.fromJson(
          jsonResponse,
          ((error) => ErrorResponseData.fromJson(error as Map<String, String>)),
        );
        return baseResponse
            .message; // Return error message if registration failed
      } else {
        throw Exception("Unexpected error occurred");
      }
    } catch (e) {
      if (kDebugMode) {
        log(e.toString());
        debugPrintStack();
      }

      return "Failed to register. Please check the details and try again.";
    }
  }

  Future<String> performLogout() async {
    try {
      // Get the encrypted username and access token
      final userDetails = await DatabaseHelper()
          .runDynamicReadQuery('user_login', ['username', 'accessToken']);
      if (userDetails == null) {
        if (kDebugMode) {
          log("No user data found. Unable to log out.");
        }
        return "error";
      }

      final encryptedUsername = userDetails['encryptedUsername']!;
      final encryptedAccessToken = userDetails['encryptedAccessToken']!;

      // Prepare the logout request headers and body
      final headers = {
        'Authorization': 'Bearer $encryptedAccessToken',
        'Content-Type': 'application/json',
      };

      final body = json.encode({
        'username': encryptedUsername, // Encrypted username sent in the body
      });

      // Send the logout request
      final url = Uri.parse(
          '${BaseUrlConfig.baseUrlDemoDevelopment}/${AppStrings.logoutEndpoint}');
      final response = await http.post(url, headers: headers, body: body);

      // Handle the response
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['status'] == 'success') {
        if (kDebugMode) {
          log("Logout successful.");
        }

        return "re-login";
        // Handle successful logout, e.g., clearing user data, redirecting to login screen, etc.
      } else {
        if (kDebugMode) {
          log("Logout failed: ${jsonResponse['message']}");
        }

        return "re-login";
        // Handle failure (e.g., invalid token, error message)
      }
    } else {
      if (kDebugMode) {
        log("Logout request failed with status code: ${response.statusCode}");
      }
      throw Exception("Logout request failed with status code: ${response.statusCode}");
    }
    } catch (e) {
      if (kDebugMode) {
        log("Logout request failed");
        log(e.toString());
      }

      return "error";
    }
  }
}
