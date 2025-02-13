import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_demo/services/DatabaseHelper/database_helper_web.dart';
import 'package:flutter_demo/services/LogService/log_service_new.dart';
import 'package:logger/logger.dart';

import '../../constants/app_strings.dart';
import '../../models/state_district/state_district.dart';
import '../../services/ApiService/api_service.dart';
import '../../services/DatabaseHelper/database_helper.dart';
import '../../services/EncryptionService/encryption_service_new.dart';
import '../../services/LocalStorageService/local_storage.dart';

class MasterDataViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  // ignore: unused_field
  final LocalStorage _localStorage = LocalStorage();

  // ignore: unused_field
  bool _isLoading = false;

  Future<String?> fetchMasterData({bool refreshDB = false}) async {
    try {
      _setLoading(true);

      var states = await fetchState();

      if (states.isNotEmpty && !refreshDB) {
        return "success";
      }

    /*  LogServiceNew.logToFile(
        message:
            "Fetching Master Data for states with refresh option $refreshDB",
        screenName: "Master Data ViewModel",
        methodName: "fetchMasterData",
        level: Level.debug,
        // stackTrace: "$stackTrace",
      );*/

      Map<String, dynamic>? userDetails;

      if(kIsWeb){
        userDetails = await DbHelper().getUserLoginDetails();
      }
      else{
        userDetails = await DatabaseHelper().getUserLoginDetails();
      }

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

     /* LogServiceNew.logToFile(
        message: "Sending http request to endpoint",
        screenName: "Master Data ViewModel",
        methodName: "fetchMasterData",
        level: Level.debug,
        // stackTrace: "$stackTrace",
      );*/
      final headers = {
        "Content-Type": "text/plain",
        "Authorization": "Bearer $encryptedAuthToken",
        "Accept":'*/*'
      };

      if (kDebugMode) {
        print(headers);
        log('headers');
      }

      final response = await _apiService.postWithAuthToken(
          AppStrings.masterData, encryptedRequestBody, headers);

      if (kDebugMode) {
        log('response recieved ${response.statusCode}');
        log('response body ${response.body}');
      }

      bool isSuccessStatus = (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 203 ||
          response.statusCode == 204 ||
          response.statusCode == 205);

      /*LogServiceNew.logToFile(
        message:
            "Received response http request to endpoint with response status ${response.statusCode}",
        screenName: "Master Data ViewModel",
        methodName: "fetchMasterData",
        level: isSuccessStatus ? Level.info : Level.error,
        // stackTrace: "$stackTrace",
      );*/

      String encryptedResponseBody = response.body;

      String decryptedResponse = isSuccessStatus
          ? AESUtil().decryptDataV2(encryptedResponseBody, encryptionKey)
          : kDebugMode
              ? AESUtil()
                  .decryptDataV2(encryptedResponseBody, AppStrings.encryptDebug)
              : AESUtil().decryptDataV2(
                  encryptedResponseBody, AppStrings.encryptkeyProd);

     /* LogServiceNew.logToFile(
        message: "Decrypted response body",
        screenName: "Master Data ViewModel",
        methodName: "fetchMasterData",
        level: isSuccessStatus ? Level.info : Level.error,
        // stackTrace: "$stackTrace",
      );*/

      var deserializedResponse = jsonDecode(decryptedResponse);

/*
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
*/

     /* LogServiceNew.logToFile(
        message: "Validating the deserialized response body",
        screenName: "Master Data ViewModel",
        methodName: "fetchMasterData",
        level: isSuccessStatus ? Level.info : Level.error,
        // stackTrace: "$stackTrace",
      );
*/
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

      if (hasError && !isSuccessStatus) {
        if (kDebugMode) {
          log("Ran into error at api level");
          print(deserializedResponse['status']);
          print(deserializedResponse['message']);
          print(deserializedResponse['error']);
        }
        throw Exception(deserializedResponse['error'].toString());
      }

      List<dynamic> districtMasterData = deserializedResponse["data"];

      if (kDebugMode) {
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

     /* LogServiceNew.logToFile(
        message: "District Master Data Ready for DB insert",
        screenName: "Master Data ViewModel",
        methodName: "fetchMasterData",
        level: Level.info,
        // stackTrace: "$stackTrace",
      );*/

      // Insert data into the database
      if(kIsWeb){
        await DbHelper().insertDistricts(districtList);
      }
      else{
        await DatabaseHelper().insertDistricts(districtList);
      }

     /* LogServiceNew.logToFile(
        message: "District Master Data DB insert complete",
        screenName: "Master Data ViewModel",
        methodName: "fetchMasterData",
        level: Level.info,
        // stackTrace: "$stackTrace",
      );*/
      fetchState();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        log(e.toString());
        print(stackTrace);
      }
     /* LogServiceNew.logToFile(
        message: "Error in fetching Master Data : $e",
        screenName: "Master Data ViewModel",
        methodName: "fetchMasterData",
        level: Level.error,
        stackTrace: "$stackTrace",
      );*/
      return "Failed to login. Please check your credentials and try again.";
    } finally {
      _setLoading(false);
    }
    return null;
  }

  void _setLoading(bool value) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isLoading = value;
      notifyListeners();
    });
  }

  String responseMessage(String decryptedResponseBody) {
    final jsonResponse = json.decode(decryptedResponseBody);

    if (kDebugMode) {
      log('response not 200 ');
      log(jsonResponse.statusCode.toString());
      log(jsonResponse.body);
    }

    return jsonResponse["message"].toString();
  }

  List<String> allState = [];
  List<String> allDistrict = [];

  // Fetch districts filtered by state
  Future<List<String>> fetchDistricts(String selectedState) async {
    List<String> districts;
    if(kIsWeb){
      districts= await DbHelper().getDistrictsByStateDB(selectedState);
    }
    else{
      districts= await DatabaseHelper().getDistrictsByStateDB(selectedState);
    }
    return allDistrict = districts;
  }

  // Fetch districts filtered by state
  Future<List<String>> fetchState() async {
    List<String> states;
    if(kIsWeb){
      states = await DbHelper().getDistrictStates();
    }
    else{
      states = await DatabaseHelper().getDistinctStates();
    }
    return allState = states;
  }
}
