
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../helper/constant.dart';

class GoogleAuthService {
  /// Calls backend Google login API
  /// [idToken] is obtained from Google Sign-In
  Future<http.Response> googleLogin(String idToken) async {
    debugPrint("📌 Sending Google ID Token: $idToken");

    final data = jsonEncode({"idToken": idToken});

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/google-login'),
        headers: {'Content-Type': 'application/json'},
        body: data,
      );

      if (response.statusCode == 200) {
        debugPrint("✅ Google login success");
        debugPrint("Response: ${response.body}");
        return response;
      } else if (response.statusCode == 400) {
        debugPrint("⚠️ Already registered");
        debugPrint("Response: ${response.body}");
        return response;
      } else {
        debugPrint("❌ Error Body: ${response.body}");
        debugPrint("❌ Error Code: ${response.statusCode}");
        throw HttpException('Please try again');
      }
    } catch (e) {
      debugPrint("⚠️ Exception: $e");
      throw HttpException(e.toString().substring(11));
    }
  }
}

class HttpException implements Exception {
  final String message;
  HttpException(this.message);

  @override
  String toString() => message;
}

