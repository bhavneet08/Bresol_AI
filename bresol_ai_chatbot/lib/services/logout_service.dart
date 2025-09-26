import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../helper/constant.dart';

class LogoutService {
  /// Logs out the user
  static Future<Map<String, dynamic>> logoutUser({
    required int userId, // Pass userId from app
  }) async {
    final url = Uri.parse("$baseUrl/logout"); // ✅ use baseUrl from constants.dart

    try {
      debugPrint("📡 Sending logout request to: $url with userId: $userId");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userId": userId}),
      );

      debugPrint("📥 Response: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          "success": false,
          "message": "Failed to logout: ${response.body}",
        };
      }
    } catch (e) {
      debugPrint("❌ Exception in logoutUser: $e");
      return {
        "success": false,
        "message": "Network error: $e",
      };
    }
  }
}
