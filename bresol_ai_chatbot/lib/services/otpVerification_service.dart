import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import '../helper/constant.dart';

class VerifyOtpService {
  /// Verify OTP for a user
  static Future<Map<String, dynamic>> verifyOtp({
    required int tempUserId,
    required String otp,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/otp/verify-email"); // ✅ Correct route
      // http://localhost:5000/api/otp/verify-email
      debugPrint("📡 Sending OTP verification request to: $url with tempUserId: $tempUserId and OTP: $otp");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "temp_user_id": tempUserId,
          "otp": otp,
        }),
      );

      debugPrint("📥 Response: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          "success": false,
          "message": "Failed: ${response.body}",
        };
      }
    } catch (e) {
      debugPrint("❌ Exception in verifyOtp: $e");
      return {
        "success": false,
        "message": "Error: $e",
      };
    }
  }
}
