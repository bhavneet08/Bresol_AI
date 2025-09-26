
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../helper/constant.dart';

/// ChatSession model
class ChatSession {
  final String id;
  final String title;
  final DateTime createdAt;
  List<Map<String, dynamic>> messages;

  ChatSession({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.messages,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'messages': messages,
    };
  }

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'],
      title: json['title'],
      createdAt: DateTime.parse(json['createdAt']),
      messages: List<Map<String, dynamic>>.from(json['messages']),
    );
  }
}

/// API service for chat operations
class ApiService {
  // Get auth token from storage
  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken'); // 👈 must match save key
    debugPrint("🔑 Loaded token: $token");
    return token;
  }
  // Get user ID from shared preferences
  // static Future<int?> getUserId() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   return prefs.getInt('userid');
  // }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('userId');
    debugPrint("📦 Retrieved userId: $id");
    return id;
  }


  // Prepare auth headers
  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await getAuthToken();

    if (token == null || token.isEmpty) {
      debugPrint("❌ No token found — user might not be logged in");
      return {'Content-Type': 'application/json'};
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }


  static Future<bool> saveChatHistory(List<ChatSession> chatHistory) async {
    try {
      print("3");
      final userId = await getUserId();
      if (userId == null) return false;

      final headers = await getAuthHeaders();

      // Print chat history nicely
      print("4: ChatHistory for userId $userId:");
      for (var session in chatHistory) {
        print("🧵 Session ID: ${session.id}");
        print("📌 Title: ${session.title}");
        print("🕒 CreatedAt: ${session.createdAt}");
        print("💬 Messages:");
        for (var msg in session.messages) {
          print("   • ${msg['role'] ?? msg['sender']}: ${msg['text']}");
        }
      }

      final body = json.encode({
        'chatHistory': chatHistory.map((session) => {
          'id': session.id,
          'title': session.title,
          'createdAt': session.createdAt.toIso8601String(),
          'messages': session.messages,
          'userId': userId, // 🔑 add this
        }).toList(),
      });


      final response = await http.post(
        Uri.parse('$baseUrl/chat-history/$userId'),
        headers: headers,
        body: body,
      );

      debugPrint('chat save response: ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error saving chat history: $e');
      return false;
    }
  }



  // Get chat history from backend
  // static Future<List<ChatSession>> getChatHistory({int limit = 50, int offset = 0}) async {
  //   try {
  //     print("2");
  //     final userId = await getUserId();
  //     if (userId == null) return [];
  //
  //     final headers = await getAuthHeaders();
  //     final response = await http.get(
  //       Uri.parse('$baseUrl/chat-history/$userId?limit=$limit&offset=$offset'),
  //       headers: headers,
  //     );
  //     print("3");
  //     if (response.statusCode == 200) {
  //       print("4");
  //       final data = json.decode(response.body);
  //       final List<dynamic> chatHistoryData = data['data']['chatHistory'];
  //       debugPrint('chat history response: ${response.body}');
  //       return chatHistoryData.map((item) => ChatSession.fromJson(item)).toList();
  //     }
  //     print("5");
  //     return [];
  //   } catch (e) {
  //     print("6");
  //     debugPrint('Error loading chat history: $e');
  //     return [];
  //   }
  // }
  // Get chat history from backend
  // static Future<List<ChatSession>> getChatHistory({int limit = 50, int offset = 0}) async {
  //   try {
  //     debugPrint("📡 Fetching chat history...");
  //     final userId = await getUserId();
  //     if (userId == null) return [];
  //
  //     final headers = await getAuthHeaders();
  //     final response = await http.get(
  //       Uri.parse('$baseUrl/chat-history/$userId?limit=$limit&offset=$offset'),
  //       headers: headers,
  //     );
  //
  //     debugPrint("📩 Raw Response: ${response.body}"); // <-- print full backend JSON
  //
  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       final List<dynamic> chatHistoryData = data['data']['chatHistory'];
  //
  //       debugPrint("📦 Parsed Sessions: ${chatHistoryData.length}");
  //       return chatHistoryData.map((item) => ChatSession.fromJson(item)).toList();
  //     }
  //
  //     return [];
  //   } catch (e) {
  //     debugPrint('❌ Error loading chat history: $e');
  //     return [];
  //   }
  // }

  static Future<List<ChatSession>> getChatHistory({int limit = 50, int offset = 0}) async {
    try {
      debugPrint("📡 Fetching chat history...");

      final userId = await getUserId();
      if (userId == null) {
        debugPrint("❌ No user ID found. Are you logged in?");
        return [];
      }

      final headers = await getAuthHeaders();
      debugPrint("📤 Headers: $headers"); // 👀 Verify token is sent

      // 🔥 Make GET request
      final response = await http.get(
        Uri.parse('$baseUrl/chat-history/$userId?limit=$limit&offset=$offset'),
        headers: headers,
      );

      debugPrint("📩 Raw Response (${response.statusCode}): ${response.body}");

      // 🛑 Handle token/auth errors
      if (response.statusCode == 401) {
        debugPrint("❌ Unauthorized - Access token is missing or expired.");
        // 👉 You can optionally trigger logout or refresh token here
        return [];
      }

      if (response.statusCode != 200) {
        debugPrint("❌ Failed to load chat history. Status: ${response.statusCode}");
        return [];
      }

      // ✅ Parse response safely
      final decoded = json.decode(response.body);
      final data = decoded['data'];

      if (data == null || data['chatHistory'] == null) {
        debugPrint("⚠️ No chat history found in response.");
        return [];
      }

      final List<dynamic> chatHistoryData = data['chatHistory'];
      debugPrint("📦 Parsed Sessions: ${chatHistoryData.length}");

      return chatHistoryData
          .map((item) => ChatSession.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('❌ Error loading chat history: $e');
      return [];
    }
  }



  // Get specific chat session
  static Future<ChatSession?> getChatSession(String sessionId) async {
    try {
      final userId = await getUserId();
      if (userId == null) return null;

      final headers = await getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/chat-history/$userId/$sessionId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('chat session response: ${response.body}');
        return ChatSession.fromJson(data['data']);
      }
      return null;
    } catch (e) {
      debugPrint('Error loading chat session: $e');
      return null;
    }
  }

  // Delete chat session
  static Future<bool> deleteChatSession(String sessionId) async {
    try {
      final userId = await getUserId();
      if (userId == null) return false;

      final headers = await getAuthHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/chat-history/$userId/$sessionId'),
        headers: headers,
      );

      debugPrint('chat delete response: ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error deleting chat session: $e');
      return false;
    }
  }
}
