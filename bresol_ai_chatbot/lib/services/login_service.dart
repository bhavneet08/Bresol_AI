import 'dart:convert';
import 'package:http/http.dart' as http;
import '../helper/constant.dart'; // <-- import where baseUrl is stored

class LoginService {
  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/login/'); // backend endpoint
      // http://localhost:5000/api/login/
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        // success
        final data = jsonDecode(response.body);
        return {
          "success": true,
          "token": data["token"],
          "user": data["user"],
        };
      } else {
        // error from server
        final data = jsonDecode(response.body);
        return {
          "success": false,
          "message": data["message"] ?? "Login failed",
        };
      }
    } catch (e) {
      // network/server error
      return {
        "success": false,
        "message": "Something went wrong: $e",
      };
    }
  }
}
