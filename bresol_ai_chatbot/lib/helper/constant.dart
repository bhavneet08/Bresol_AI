import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// const String baseUrl = 'http://localhost:5000/api';
const String baseUrl = 'http://192.168.137.1:5000/api';
const String apiKey = 'your-api-key';
Future<String> getToken() async {
  final storage = FlutterSecureStorage();
  String? token = await storage.read(key: 'token');
  return token ?? '';
}