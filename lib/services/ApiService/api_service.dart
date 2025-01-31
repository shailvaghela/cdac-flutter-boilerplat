import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../constants/base_url_config.dart';
class ApiService {
  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    // String url = '${BaseUrlConfig.baseUrlDemoDevelopment}/$endpoint';
    String url = '${BaseUrlConfig.baseUrlDevelopment}/$endpoint';


    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      debugPrint("Response: ${response.body}");
      return response;
    } catch (e) {
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
    if(kDebugMode){
      print("sending post request to $url");
    }
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'text/plain'},
        body: body,
      );
      if(kDebugMode){
        print("Post v1 response ${response.statusCode}");
      }
      return response;
    } catch (e) {
      throw Exception('Error making request: $e');
    }
  }

  Future<http.Response> postWithAuthToken(String endpoint, String body, Map<String, String> headers) async {
    // String url = '${BaseUrlConfig.baseUrlDemoDevelopment}/$endpoint';
    String url = '${BaseUrlConfig.baseUrlDemoDevelopment}$endpoint';
    if(kDebugMode){
      print("sending post request to $url");
    }
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );
      if(kDebugMode){
        print("Post v1 response ${response.statusCode}");
      }
      return response;
    } catch (e) {
      throw Exception('Error making request: $e');
    }
  }

  Future<http.Response> getV1(String endpoint, Map<String, String> auth) async {
    // String url = '${BaseUrlConfig.baseUrlDemoDevelopment}/$endpoint';
    String url = '${BaseUrlConfig.baseUrlDemoDevelopment}/$endpoint';
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
}

