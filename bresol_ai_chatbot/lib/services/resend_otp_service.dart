

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../helper/constant.dart';

class ResendOtpService {
  static Future<Map<String, dynamic>> resendOtp({required String email}) async {
    final url = Uri.parse('$baseUrl/resend-otp');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          "success": false,
          "message": jsonDecode(response.body)['message'] ??
              "Failed to resend OTP"
        };
      }
    } catch (e) {
      return {"success": false, "message": "Server error: $e"};
    }
  }
}
