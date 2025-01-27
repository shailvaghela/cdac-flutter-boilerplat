import 'dart:convert';

import 'package:flutter/cupertino.dart';
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
}

