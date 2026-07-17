import 'dart:io';
import 'package:dio/dio.dart';
import '../models/app_models.dart';
import '../core/network/api_client.dart';
import 'package:http_parser/http_parser.dart';

class AuthRepository {
  final ApiClient apiClient;

  AuthRepository(this.apiClient);

  String _getErrorMessage(DioException e) {
    if (e.response?.data != null && e.response?.data is Map) {
      final msg = e.response?.data['message'];
      if (msg != null) return msg.toString();
    }
    return e.message ?? 'An unknown network error occurred';
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await apiClient.dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      final envelope = response.data as Map<String, dynamic>;
      // API wraps actual data in a 'data' key: {result, message, data: {user, token}}
      final data = (envelope['data'] as Map<String, dynamic>?) ?? envelope;
      final token = data['token'] as String? ?? data['jwt_token'] as String? ?? '';
      if (token.isNotEmpty) {
        await apiClient.saveToken(token);
      }

      UserModel? user;
      if (data['user'] != null) {
        user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      }

      return {
        'token': token,
        'user': user,
      };
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String confirmPassword,
    required String fullName,
  }) async {
    try {
      await apiClient.dio.post('/auth/register', data: {
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
        'fullName': fullName,
      });
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  Future<void> logout() async {
    try {
      await apiClient.dio.delete('/auth/logout');
    } finally {
      await apiClient.clearToken();
    }
  }

  Future<UserModel> getProfile() async {
    try {
      final response = await apiClient.dio.get('/auth/profile');
      final envelope = response.data as Map<String, dynamic>;
      final data = (envelope['data'] as Map<String, dynamic>?) ?? envelope;
      return UserModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  Future<UserModel> updateProfile(String fullName) async {
    try {
      final response = await apiClient.dio.put('/auth/profile', data: {
        'fullName': fullName,
      });
      final envelope = response.data as Map<String, dynamic>;
      final data = (envelope['data'] as Map<String, dynamic>?) ?? envelope;
      return UserModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      await apiClient.dio.put('/auth/change-password', data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  Future<void> requestChangeEmail(String newEmail, String password) async {
    try {
      await apiClient.dio.post('/auth/change-email/request', data: {
        'newEmail': newEmail,
        'password': password,
      });
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  Future<void> verifyNewEmail(String token) async {
    try {
      await apiClient.dio.post('/auth/change-email/verify', data: {
        'token': token,
      });
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  Future<void> sendOtp(String email) async {
    try {
      await apiClient.dio.post('/otp/send', data: {
        'email': email,
      });
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  Future<void> verifyOtp(String email, String code) async {
    try {
      await apiClient.dio.post('/otp/verify', data: {
        'email': email,
        'code': code,
      });
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await apiClient.dio.post('/auth/forgot-password', data: {
        'email': email,
      });
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  Future<void> resetPassword(String token, String newPassword) async {
    try {
      await apiClient.dio.post('/auth/reset-password', data: {
        'token': token,
        'newPassword': newPassword,
      });
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  Future<UserModel> uploadAvatar(String filePath) async {
    try {
      final file = File(filePath);
      final filename = file.path.split(Platform.isWindows ? '\\' : '/').last;
      
      // Determine file extension/type
      String ext = filename.split('.').last.toLowerCase();
      MediaType mediaType = MediaType('image', ext == 'png' ? 'png' : 'jpeg');

      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(
          file.path,
          filename: filename,
          contentType: mediaType,
        ),
      });

      final response = await apiClient.dio.put(
        '/auth/profile/avatar',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      final envelope = response.data as Map<String, dynamic>;
      final data = (envelope['data'] as Map<String, dynamic>?) ?? envelope;
      return UserModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  Future<void> deleteAvatar() async {
    try {
      await apiClient.dio.delete('/auth/profile/avatar');
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  Future<Map<String, dynamic>> loginWithGoogle({String? idToken, String? accessToken}) async {
    try {
      final response = await apiClient.dio.post('/auth/google', data: {
        if (idToken != null) 'idToken': idToken,
        if (accessToken != null) 'accessToken': accessToken,
      });
      final envelope = response.data as Map<String, dynamic>;
      final data = (envelope['data'] as Map<String, dynamic>?) ?? envelope;
      final token = data['token'] as String? ?? data['jwt_token'] as String? ?? '';
      if (token.isNotEmpty) {
        await apiClient.saveToken(token);
      }
      UserModel? user;
      if (data['user'] != null) {
        user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      }
      return {'token': token, 'user': user};
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }


  Future<Map<String, dynamic>> loginWithFacebook(String accessToken) async {
    try {
      final response = await apiClient.dio.post('/auth/facebook', data: {
        'accessToken': accessToken,
      });
      final envelope = response.data as Map<String, dynamic>;
      final data = (envelope['data'] as Map<String, dynamic>?) ?? envelope;
      final token = data['token'] as String? ?? data['jwt_token'] as String? ?? '';
      if (token.isNotEmpty) {
        await apiClient.saveToken(token);
      }
      UserModel? user;
      if (data['user'] != null) {
        user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      }
      return {'token': token, 'user': user};
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }
}
