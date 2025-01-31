

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../constants/app_strings.dart';
import '../../models/state_district/state_district.dart';
import '../../services/ApiService/api_service.dart';
import '../../services/DatabaseHelper/database_helper.dart';
import '../../services/EncryptionService/encryption_service_new.dart';
import '../../services/LocalStorageService/local_storage.dart';

class MasterDataViewModel extends ChangeNotifier {

  final ApiService _apiService = ApiService();
  final LocalStorage _localStorage = LocalStorage();

  // ignore: unused_field
  bool _isLoading = false;

  Future<String?> fetchMasterData() async {
    try {
      _setLoading(true);

      Map<String, dynamic>? userDetails = await DatabaseHelper().getUserLoginDetails();

      String unEncryptedUserName = userDetails!['username'];
      String encryptionKey = userDetails['encryptionKey'];
      String authToken = userDetails['accessToken'];


      final encryptedAuthToken = kDebugMode
          ? AESUtil().encryptDataV2(authToken, AppStrings.encryptDebug)
          : AESUtil().encryptDataV2(authToken, AppStrings.encryptkeyProd);

      final requestBody = json.encode({
        "username": unEncryptedUserName,
        "dtype": AppStrings.district,
      });

      final encryptedRequestBody = kDebugMode
          ? AESUtil().encryptDataV2(requestBody, AppStrings.encryptDebug)
          : AESUtil().encryptDataV2(requestBody, AppStrings.encryptkeyProd);

      if (kDebugMode) {
        log("sending http request to ");
        log(requestBody);
        log(encryptedRequestBody);
      }

      final headers = {
        "Content-Type": "text/plain",
        "Authorization": "Bearer $encryptedAuthToken"
      };

      if (kDebugMode) {
        print(headers);
        log('headers');
      }

      final response = await _apiService
          .postWithAuthToken(AppStrings.masterData, encryptedRequestBody, headers);

      if (kDebugMode) {
        log('response recieved ${response.statusCode}');
        log('response body ${response.body}');
      }

      bool isSuccessStatus = (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 203 ||
          response.statusCode == 204 ||
          response.statusCode == 205);

      String encryptedResponseBody = response.body;

      String decryptedResponse = isSuccessStatus
          ? AESUtil().decryptDataV2(
          encryptedResponseBody, encryptionKey)
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

      List<District> districtList = [];
      for (var item in districtMasterData) {
        districtList.add(District(
          state: item['state'] as String, // Cast 'state' to String
          district: item['district'] as String, // Cast 'district' to String
        ));
      }

      // Insert data into the database
      await DatabaseHelper().insertDistricts(districtList);
      fetchState();

    }
    catch (e) {
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

  String responseMessage(String decryptedResponseBody){
    final jsonResponse = json.decode(decryptedResponseBody);

    if (kDebugMode) {
      log('response not 200 ');
      log(jsonResponse.statusCode.toString());
      log(jsonResponse.body);
    }

    return jsonResponse["message"].toString();
  }

  List<String> allState = [];
  List<String> districts = [];

/*  // Insert the data into the SQLite database
  Future<void> insertData() async {
    final data = {
      "data": [
        {"id": 1, "state": "Maharashtra", "district": "Mumbai"},
        {"id": 2, "state": "Maharashtra", "district": "Pune"},
        {"id": 3, "state": "Maharashtra", "district": "Nagpur"},
        {"id": 4, "state": "Maharashtra", "district": "Nashik"},
        {"id": 5, "state": "Maharashtra", "district": "Thane"},
        {"id": 6, "state": "Karnataka", "district": "Bangalore"},
        {"id": 7, "state": "Karnataka", "district": "Mysore"},
        {"id": 8, "state": "Karnataka", "district": "Mangalore"},
        {"id": 9, "state": "Karnataka", "district": "Hubli"},
        {"id": 10, "state": "Karnataka", "district": "Belgaum"},
        {"id": 11, "state": "Tamil Nadu", "district": "Chennai"},
        {"id": 12, "state": "Tamil Nadu", "district": "Coimbatore"},
        {"id": 13, "state": "Tamil Nadu", "district": "Madurai"},
        {"id": 14, "state": "Tamil Nadu", "district": "Salem"},
        {"id": 15, "state": "Tamil Nadu", "district": "Tiruchirappalli"},
        {"id": 16, "state": "Uttar Pradesh", "district": "Lucknow"},
        {"id": 17, "state": "Uttar Pradesh", "district": "Kanpur"},
        {"id": 18, "state": "Uttar Pradesh", "district": "Varanasi"},
        {"id": 19, "state": "Uttar Pradesh", "district": "Agra"},
        {"id": 20, "state": "Uttar Pradesh", "district": "Allahabad"},
        {"id": 21, "state": "West Bengal", "district": "Kolkata"},
        {"id": 22, "state": "West Bengal", "district": "Darjeeling"},
        {"id": 23, "state": "West Bengal", "district": "Asansol"},
        {"id": 24, "state": "West Bengal", "district": "Siliguri"},
        {"id": 25, "state": "West Bengal", "district": "Durgapur"}
      ]
    };

    // Convert the JSON data to a list of District objects
    List<District> districtList = [];
    for (var item in data['data']!) {
      districtList.add(District(
        id: item['id'] as int, // Cast the 'id' to int
        state: item['state'] as String, // Cast 'state' to String
        district: item['district'] as String, // Cast 'district' to String
      ));
    }

    // Insert data into the database
    await DatabaseHelper().insertDistricts(districtList);
    fetchState();
  }*/

  // Fetch districts filtered by state
  Future<List<String>> fetchDistricts(String selectedState) async {
    List<String> districtss =
    await DatabaseHelper().getDistrictsByStateDB(selectedState);
      districts = districtss;
      return districts;
  }

  // Fetch districts filtered by state
  Future<List<String>> fetchState() async {
    List<String> states =
    await DatabaseHelper().getDistinctStates();
      states = states;
     return allState = states;
  }

}
