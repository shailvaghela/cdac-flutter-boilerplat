import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_demo/services/LogService/log_service_new.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../../constants/base_url_config.dart';

class ApiService {
  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    // String url = '${BaseUrlConfig.baseUrlDemoDevelopment}/$endpoint';
    String url = '${BaseUrlConfig.baseUrlDevelopment}/$endpoint';

    try {
      LogServiceNew.logToFile(
        message: "Sending http request to url $endpoint",
        screenName: "API service",
        methodName: "post",
        level: Level.debug,
      );

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      LogServiceNew.logToFile(
        message: "Sent http request to url $endpoint",
        screenName: "API service",
        methodName: "post",
        level: Level.debug,
      );

      if (kDebugMode) {
        debugPrint("Response: ${response.body}");
      }
      LogServiceNew.logToFile(
        message: "Sent post requst success",
        screenName: "API service",
        methodName: "post",
        level: Level.debug,
      );

      return response;
    } catch (e, stackTrace) {
      LogServiceNew.logToFile(
          message: "Error making http request to url $endpoint $e",
          screenName: "API service",
          methodName: "post",
          level: Level.error,
          stackTrace: "$stackTrace");

      throw Exception('Error making request: $e');
    }
  }

  Future<http.Response> get(String endpoint, Map<String, String> auth) async {
    // String url = '${BaseUrlConfig.baseUrlDemoDevelopment}/$endpoint';
    String url = '${BaseUrlConfig.baseUrlDevelopment}/$endpoint';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: auth,
      );
      debugPrint("GetResponse: ${response.body}");
      return response;
    } catch (e) {
      throw Exception('Error making request: $e');
    }
  }

  Future<http.Response> postV1(String endpoint, String body) async {
    // String url = '${BaseUrlConfig.baseUrlDemoDevelopment}/$endpoint';
    String url = '${BaseUrlConfig.baseUrlDemoDevelopment}$endpoint';
    if (kDebugMode) {
      print("sending post request to $endpoint");
    }
    LogServiceNew.logToFile(
      message: "Sending post request to url $endpoint",
      screenName: "API Service",
      methodName: "postV1",
      level: Level.debug,
    );
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'text/plain'},
        body: body,
      );
      if (kDebugMode) {
        print("Post v1 response ${response.statusCode}");
      }
      LogServiceNew.logToFile(
        message: "Sent post request to url $endpoint successfully",
        screenName: "API Service",
        methodName: "postV1",
        level: Level.debug,
      );
      return response;
    } catch (e, stackTrace) {
      LogServiceNew.logToFile(
        message: "Error while sending post request to url $endpoint",
        screenName: "API Service",
        methodName: "postV1",
        level: Level.error,
        stackTrace: "$stackTrace",
      );
      throw Exception('Error making request: $e');
    }
  }

  Future<http.Response> postWithAuthToken(
      String endpoint, String body, Map<String, String> headers) async {
    // String url = '${BaseUrlConfig.baseUrlDemoDevelopment}/$endpoint';
    String url = '${BaseUrlConfig.baseUrlDemoDevelopment}$endpoint';
    if (kDebugMode) {
      print("sending post request to $endpoint");
    }

    LogServiceNew.logToFile(
      message: "Sending post request to $endpoint",
      screenName: "API service",
      methodName: "Authenticated request",
      level: Level.debug,
    );
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );
      if (kDebugMode) {
        print("Post v1 response ${response.statusCode}");
      }
      LogServiceNew.logToFile(
        message: "Sent post request to $endpoint successfully",
        screenName: "API service",
        methodName: "Authenticated request",
        level: Level.debug,
      );
      return response;
    } catch (e, stackTrace) {
      LogServiceNew.logToFile(
        message: "Error in sending post request to $endpoint: $e",
        screenName: "API service",
        methodName: "Authenticated request",
        level: Level.error,
        stackTrace: "$stackTrace",
      );
      throw Exception('Error making request: $e');
    }
  }

  Future<http.Response> getV1(String endpoint, Map<String, String> auth) async {
    // String url = '${BaseUrlConfig.baseUrlDemoDevelopment}/$endpoint';
    String url = '${BaseUrlConfig.baseUrlDemoDevelopment}/$endpoint';
    LogServiceNew.logToFile(
      message: "Sending post request to $endpoint",
      screenName: "API service",
      methodName: "Authenticated request",
      level: Level.debug,
    );
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: auth,
      );
      LogServiceNew.logToFile(
        message: "Sent post request to $endpoint successfully",
        screenName: "API service",
        methodName: "Authenticated request",
        level: Level.debug,
      );
      if (kDebugMode) {
        debugPrint("GetResponse: ${response.body}");
      }
      LogServiceNew.logToFile(
        message: "Sent post request to $endpoint successfully",
        screenName: "API service",
        methodName: "Authenticated request",
        level: Level.debug,
      );
      return response;
    } catch (e) {
      LogServiceNew.logToFile(
        message: "Error in sending post request to $endpoint : $e",
        screenName: "API service",
        methodName: "Authenticated request",
        level: Level.error,
      );
      throw Exception('Error making request: $e');
    }
  }
}
