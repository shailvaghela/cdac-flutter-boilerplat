import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_demo/constants/app_strings.dart';
import 'package:flutter_demo/services/DatabaseHelper/database_helper.dart';
import 'package:flutter_demo/services/EncryptionService/encryption_service_new.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_demo/constants/base_url_config.dart';

class MasterData {
  
  Future<void> fetchMasterData(String username, String dtype) async {
    try {
      if (kDebugMode) {
        log('requesting district data');
      }

      final headers = {"Content-Type": "application/json"};

      final encryptedUsername = kDebugMode
          ? AESUtil().encryptDataV2(username, AppStrings.encryptDebug)
          : AESUtil().encryptDataV2(username, AppStrings.encryptkeyProd);
      final encryptedDtype = kDebugMode
          ? AESUtil().encryptDataV2(dtype, AppStrings.encryptDebug)
          : AESUtil().encryptDataV2(dtype, AppStrings.encryptDebug);

      final requestBody = jsonEncode({
        "username": encryptedUsername,
        "dtype": encryptedDtype,
      });

      final url =
          Uri.parse("${BaseUrlConfig.baseUrlDemoDevelopment}/api/master-data");

      if (kDebugMode) {
        log("sending http request to ");
      }

      final response =
          await http.post(url, headers: headers, body: requestBody);

      if (kDebugMode) {
        log('response recieved ${response.statusCode}');
        log('response body ${response.body.length > 10}');
      }

      if (response.statusCode != 200) {
        throw Exception("Could not fetch master data");
      }

      if (response.body.trim().isEmpty) {
        throw Exception("Master data reverted was invalid");
      }

      final jsonResponse = jsonDecode(response.body);

      if (kDebugMode) {
        print("showing jsonResponse");
        print(jsonResponse);
      }

      if (!jsonResponse.keys.toList().contains("status") ||
          !jsonResponse.keys.toList().contains("message") ||
          !jsonResponse.keys.toList().contains("data") ||
          jsonResponse["data"] is! List ||
          jsonResponse["data"].isEmpty ||
          jsonResponse["data"][0] is! Map<String, dynamic>) {
        throw Exception("Invalid data format from server");
      }

      if (!jsonResponse["status"]
          .toString()
          .toLowerCase()
          .contains("success")) {
        throw Exception(jsonResponse["message"]);
      }

      final masterData = jsonResponse["data"];

      if (kDebugMode) {
        print("master data");
        print(masterData);
      }

      if(dtype=='district'){
        for(var stateData in masterData){
          if(kDebugMode){
            debugPrint("Inserting $stateData to db");
          }

          
          
        }
      }else{
        if(kDebugMode){
          log("TODO implement the msater data saveto db");
        }
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
