import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static const String _tokenKey = 'jwt_token';
  
  // Base URL configuration - supports Web/Desktop and Android Emulator
  static String get defaultBaseUrl {
    if (kIsWeb) {
      // return 'https://ant-g2-pet.tt.linkpc.net/api/v1';
      // return 'http://localhost:3000/api/v1';
      return 'https://personal-expense-tracker-app-backend-ppau.onrender.com/api/v1';
      
    }
    // Android emulator loops back to machine via 10.0.2.2
    if (defaultTargetPlatform == TargetPlatform.android) {
      //  return 'http://localhost:3000/api/v1';
      return 'https://personal-expense-tracker-app-backend-ppau.onrender.com/api/v1';
    }
    // return 'http://localhost:3000/api/v1';
    return 'https://personal-expense-tracker-app-backend-ppau.onrender.com/api/v1';
  }

  late final Dio dio;
  String _baseUrl = defaultBaseUrl;

  ApiClient({String? customBaseUrl}) {
    if (customBaseUrl != null) {
      _baseUrl = customBaseUrl;
    }
    
    dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString(_tokenKey);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // You could handle globally 401s (token expiry) here by broadcasting a logout event or clearing state
          if (e.response?.statusCode == 401) {
            // Token is invalid/expired
            clearToken();
          }
          return handler.next(e);
        },
      ),
    );
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
