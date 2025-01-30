// ignore_for_file: unused_import

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_demo/constants/app_strings.dart';
import 'package:flutter_demo/services/DatabaseHelper/database_helper.dart';
import 'package:flutter_demo/services/EncryptionService/encryption_service_new.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_demo/constants/base_url_config.dart';

class MasterData {
  Future<void> fetchMasterData(String username, String dtype) async {
    try {
      String encryptedAuthToken = AppStrings.loginAuthToken;

      if (kDebugMode) {
        log('requesting district data');
        log("request Body is ");
        log(username);
        log(dtype);
      }

      final headers = {
        "Content-Type": "text/plain",
        "Authorization": "Bearer $encryptedAuthToken"
      };

      if (kDebugMode) {
        print(headers);
        log('headers');
      }

      // final encryptedUsername = kDebugMode
      //     ? AESUtil().encryptDataV2(username, AppStrings.encryptDebug)
      //     : AESUtil().encryptDataV2(username, AppStrings.encryptkeyProd);
      // final encryptedDtype = kDebugMode

      var requestBody = jsonEncode({
        "username": username,
        "dtype": dtype,
      });

      final encryptedRequestBody = kDebugMode
          ? AESUtil().encryptDataV2(requestBody, AppStrings.encryptDebug)
          : AESUtil().encryptDataV2(requestBody, AppStrings.encryptkeyProd);

      final url =
          Uri.parse("${BaseUrlConfig.baseUrlDemoDevelopment}/auth/master-data");

      if (kDebugMode) {
        log("sending http request to ");
        log(url.toString());
        log(requestBody);
        log(encryptedRequestBody);
      }

      final response =
          await http.post(url, headers: headers, body: encryptedRequestBody);

      if (kDebugMode) {
        log('response recieved ${response.statusCode}');
        log('response body ${response.body}');
      }

      String encryptedResponseBody = response.body;

      String decryptedResponse = response.statusCode == 200 ||
              response.statusCode == 201
          ? AESUtil().decryptDataV2(
              encryptedResponseBody, AppStrings.userDecryptionKeyDebug)
          : kDebugMode
              ? AESUtil()
                  .decryptDataV2(encryptedResponseBody, AppStrings.encryptDebug)
              : AESUtil().decryptDataV2(
                  encryptedResponseBody, AppStrings.encryptkeyProd);

      dynamic deserializedResponse;

      try {
        deserializedResponse = jsonDecode(decryptedResponse);
      } catch (e3) {
        if (kDebugMode) {
          debugPrintStack();
          debugPrint("Error while deserializing decrypted body");
          print(e3);
        }
      }

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

      bool isSuccessStatus = (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 203 ||
          response.statusCode == 204 ||
          response.statusCode == 205);

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

      List<dynamic> districtMasterData = deserializedResponse["data"];

      if(kDebugMode){
        log("finally got the deserialized district data");
        print(districtMasterData);
      }

      
    } catch (e) {
      if (kDebugMode) {
        log("Error while fetching master data");
        log(e.toString());
        debugPrintStack();
      }
    }
  }
}
