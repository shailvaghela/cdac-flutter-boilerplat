import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter_demo/constants/app_strings.dart';
import 'package:flutter_demo/constants/base_url_config.dart';
import 'package:flutter_demo/models/ResponseModel/base_response_model.dart';
import 'package:flutter_demo/models/ResponseModel/error_response_dart.dart';
// import 'package:flutter_demo/models/ResponseModel/login_response_data.dart';
import 'package:flutter_demo/services/DatabaseHelper/database_helper.dart';
import 'package:flutter_demo/services/EncryptionService/encryption_service_new.dart';
import 'package:http/http.dart' as http;

class AuthService {
  Future<String> performLogin(String username, String password) async {
    try {
      final encryptedUsername = kDebugMode
          ? AESUtil().encryptDataV2(username, AppStrings.encryptDebug)
          : AESUtil().encryptDataV2(username, AppStrings.encryptkeyProd);

      final requestBody = json.encode({
        "username": username,
        "password": password,
      });

      final encryptedRequestBody =  kDebugMode
          ? AESUtil().encryptDataV2(requestBody, AppStrings.encryptDebug)
          : AESUtil().encryptDataV2(requestBody, AppStrings.encryptkeyProd);

      final headers = {
        "Content-Type": "text/plain",
      };

      if (kDebugMode) {
        log("request body");
        debugPrint(requestBody);

        log(AESUtil().encryptDataV2(username, AppStrings.encryptDebug));
        log(AESUtil().encryptDataV2(username, AppStrings.encryptkeyProd));
      }
      final url = Uri.parse(
          "${BaseUrlConfig.baseUrlDemoDevelopment}${AppStrings.loginEndpoint}");

      final response =
          await http.post(url, headers: headers, body: encryptedRequestBody);

      if (kDebugMode) {
        log(response.statusCode.toString());
        log(response.body);
        // log(response.request!.headers.toString());
      }

      final decryptedResponseBody =  kDebugMode
          ? AESUtil().decryptDataV2(response.body, AppStrings.encryptDebug)

          : AESUtil().decryptDataV2(response.body, AppStrings.encryptkeyProd);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(decryptedResponseBody);

        if (kDebugMode) {
          debugPrint("Login response body ");
          // debugPrint(response.body);
        }

        if (kDebugMode) {
          print("showing base response after login attempt");
          print(jsonResponse);
        }
        // final baseResponse = BaseResponse<LoginResponseData>.fromJson(
        //   jsonResponse,
        //   (data) => LoginResponseData.fromJson(data as Map<String, dynamic>),
        // );

        if (jsonResponse is! Map) {
          return "Server Error. Please try again";
        }

        if (kDebugMode) {
          print("showing base response after map check");
          // print(jsonResponse);
          // log("${!jsonResponse.keys.toList().contains("status")}");
          // log("----");
          // log("${!jsonResponse.keys.toList().contains("message")}");
          // log("----");

          // log("${!jsonResponse.keys.toList().contains("data")}");
          // log("----");

          log("${jsonResponse["data"] is! Map}");
          log("----");

          log("${!jsonResponse["data"].keys.toList().contains("accessToken")}");
          log("----");

          log("${!jsonResponse["data"].keys.toList().contains("refreshToken")}");
          log("----");

          log("${!jsonResponse["data"].keys.toList().contains('encryptionKey')}");
          log("----");
        }

        if (!jsonResponse.keys.toList().contains("status") ||
            !jsonResponse.keys.toList().contains("message") ||
            !jsonResponse.keys.toList().contains("data") ||
            jsonResponse["data"] is! Map ||
            !jsonResponse["data"].keys.toList().contains("accessToken") ||
            !jsonResponse["data"].keys.toList().contains("refreshToken") ||
            !jsonResponse["data"].keys.toList().contains('encryptionKey')) {
          return "Server Error. Please try again";
        }
        if (kDebugMode) {
          log("showing base response after more checks");
          // print(jsonResponse);
          log("${!jsonResponse["status"].toString().toLowerCase().contains("success")}");
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
          encryptedUsername, // Encrypted username // encrypted via encryptDebug/encryptProd
          jsonResponse["data"][
              "accessToken"], // Encrypted access token // encrypted via encryptDebug/encryptProd
          jsonResponse["data"][
              "refreshToken"], // Encrypted refresh token // encrypted via encryptDebug/encryptProd
          jsonResponse["data"]["userEncryptionKey"], // Decrypted encryption key // encrypted via encryptDebug/encryptProd
        );

        if (kDebugMode) {
          debugPrint("DB save result $dbResult");
        }

        return jsonResponse["message"].toString();

        // Check if login was successful
        // if (baseResponse['status'].toString().toLowerCase() == "success") {
        //   // Decrypt the encryption key
        //   final decryptedEncryptionKey = AESUtil().decryptData(
        //       baseResponse["content"]!["encryptionKey"], AppStrings.encryptDebug);

        //   // Save login details to the database
        //   String dbResult = await DatabaseHelper().insertUserLoginDetails(
        //     encryptedUsername, // Encrypted username // encrypted via encryptDebug/encryptProd
        //     baseResponse["content"]!
        //         ["accessToken"], // Encrypted access token // encrypted via encryptDebug/encryptProd
        //     baseResponse["content"]!
        //         ["refreshToken"], // Encrypted refresh token // encrypted via encryptDebug/encryptProd
        //     decryptedEncryptionKey, // Decrypted encryption key // encrypted via encryptDebug/encryptProd
        //   );

        //   if (kDebugMode) {
        //     debugPrint("DB save result $dbResult");
        //   }

        //   // Return appropriate message based on DB save result
        //   if (dbResult == "success") {
        //     return baseResponse.message; // Return success message
        //   } else {
        //     return "Login successful, but failed to store credentials."; // Handle DB save failure
        //   }
        // } else {
        //   return baseResponse.message; // Return error message from the response
        // }
      } else if (response.statusCode == 400) {
        // ignore: unused_local_variable
        final jsonResponse = json.decode(response.body);

        if (kDebugMode) {
          log('response not 200 ');
          log(response.statusCode.toString());
          log(response.body);
        }
        // final baseResponse = BaseResponse<ErrorResponseData>.fromJson(
        //   jsonResponse,
        //   ((error) => ErrorResponseData.fromJson(error as Map<String, String>)),
        // );
        // return baseResponse.message; // Return error message if login failed

        return "Error";
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
          ? AESUtil().encryptDataV2(username, AppStrings.encryptDebug)
          : AESUtil().encryptDataV2(username, AppStrings.encryptkeyProd);

      final encryptedPassword = kDebugMode
          ? AESUtil().encryptDataV2(password, AppStrings.encryptDebug)
          : AESUtil().encryptDataV2(password, AppStrings.encryptkeyProd);

      final encryptedEmail = kDebugMode
          ? AESUtil().encryptDataV2(email, AppStrings.encryptDebug)
          : AESUtil().encryptDataV2(email, AppStrings.encryptkeyProd);

      final encryptedFirstName = kDebugMode
          ? AESUtil().encryptDataV2(firstName, AppStrings.encryptDebug)
          : AESUtil().encryptDataV2(firstName, AppStrings.encryptkeyProd);

      final encryptedMiddleName = kDebugMode
          ? AESUtil().encryptDataV2(middleName, AppStrings.encryptDebug)
          : AESUtil().encryptDataV2(middleName, AppStrings.encryptkeyProd);

      final encryptedLastName = kDebugMode
          ? AESUtil().encryptDataV2(lastName, AppStrings.encryptDebug)
          : AESUtil().encryptDataV2(lastName, AppStrings.encryptkeyProd);

      final encryptedMobile = kDebugMode
          ? AESUtil().encryptDataV2(mobile, AppStrings.encryptDebug)
          : AESUtil().encryptDataV2(mobile, AppStrings.encryptkeyProd);

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
          "${BaseUrlConfig.baseUrlDemoDevelopment}${AppStrings.registerEndpoint}");

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
          '${BaseUrlConfig.baseUrlDemoDevelopment}${AppStrings.logoutEndpoint}');
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
        throw Exception(
            "Logout request failed with status code: ${response.statusCode}");
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
