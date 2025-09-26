
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import '../helper/constant.dart'; // for debugPrint

class RegisterService {
  /// Register a new user
  static Future<Map<String, dynamic>> registerUser({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/register/");
      // http://localhost:5000/api/register/

      debugPrint("📡 Sending request to: $url with email: $email, username: $username");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username.trim(),
          "email": email.trim(),
          "password": password.trim(),
        }),
      );

      debugPrint("📥 Response: ${response.statusCode} - ${response.body}");

      // Always try to decode JSON response from backend
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      return responseData;
    } catch (e) {
      debugPrint("❌ Exception in registerUser: $e");
      return {
        "success": false,
        "message": "Error: $e",
      };
    }
  }
}

