

import 'dart:convert';
import 'dart:developer';

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

      String username = userDetails!['username'];
      String encryptionKey = userDetails['encryptionKey'];

      final requestBody = json.encode({
        "username": username,
        "dtype": AppStrings.district,
      });

      final encryptedRequestBody = kDebugMode
          ? AESUtil().encryptDataV2(requestBody, AppStrings.encryptDebug)
          : AESUtil().encryptDataV2(requestBody, AppStrings.encryptkeyProd);

      final response = await _apiService
          .postV1(AppStrings.masterData, encryptedRequestBody);

      final decryptedResponseBody = AESUtil().decryptDataV2(response.body, encryptionKey);

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

/*        if (kDebugMode) {
          print("showing base response after map check");

          log("${jsonResponse["data"] is! Map}");
          log("----");

          log("${!jsonResponse["data"].keys.toList().contains("accessToken")}");
          log("----");

          log("${!jsonResponse["data"].keys.toList().contains(
              "refreshToken")}");
          log("----");

          log("${!jsonResponse["data"].keys.toList().contains(
              'encryptionKey')}");
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
        }*/

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


        _setLoading(false);
        await _localStorage.setLoggingState('true');

        return jsonResponse["message"].toString();
      } else if (response.statusCode == 400 || response.statusCode == 404 || response.statusCode == 500) {
        responseMessage(decryptedResponseBody);
      }
      else {
        throw Exception("Unexpected error occurred");
      }

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

  // Insert the data into the SQLite database
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
  }

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
