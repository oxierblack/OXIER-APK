import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class ApiService {
  static Map<String, String> _headers(String? token) {
    final h = <String, String>{'Content-Type': 'application/json'};
    if (token != null && token.isNotEmpty) h['Authorization'] = 'Bearer $token';
    return h;
  }

  static Future<Map<String, dynamic>?> get(String path, {String? token}) async {
    try {
      final res = await http.get(
        Uri.parse('${ApiConstants.backend}$path'),
        headers: _headers(token),
      ).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) return jsonDecode(res.body);
    } catch (_) {}
    return null;
  }

  static Future<List<dynamic>?> getList(String path, {String? token}) async {
    try {
      final res = await http.get(
        Uri.parse('${ApiConstants.backend}$path'),
        headers: _headers(token),
      ).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) return jsonDecode(res.body);
    } catch (_) {}
    return null;
  }

  static Future<Map<String, dynamic>?> post(String path, Map<String, dynamic> body, {String? token}) async {
    try {
      final res = await http.post(
        Uri.parse('${ApiConstants.backend}$path'),
        headers: _headers(token),
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));
      return {'statusCode': res.statusCode, 'body': jsonDecode(res.body)};
    } catch (e) {
      return {'statusCode': 0, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>?> login(String email, String password) async {
    final res = await post(ApiConstants.loginPath, {'email': email, 'password': password});
    return res;
  }

  static Future<Map<String, dynamic>?> register(String email, String password, String name) async {
    final res = await post(ApiConstants.registerPath, {'email': email, 'password': password, 'name': name});
    return res;
  }

  static Future<Map<String, dynamic>?> verifyOtp(String email, String otp) async {
    final res = await post(ApiConstants.verifyPath, {'email': email, 'otp': otp});
    return res;
  }
}
