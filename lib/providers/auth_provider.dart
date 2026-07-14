import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../models/app_models.dart';
import '../repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository authRepository;

  UserModel? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AuthProvider(this.authRepository) {
    checkAuthStatus();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? err) {
    _error = err;
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    _setLoading(true);
    _setError(null);
    try {
      final hasToken = await authRepository.apiClient.hasToken();
      if (hasToken) {
        _currentUser = await authRepository.getProfile();
        _isAuthenticated = true;
      } else {
        _currentUser = null;
        _isAuthenticated = false;
      }
    } catch (e) {
      _currentUser = null;
      _isAuthenticated = false;
      // Token might be invalid, clear it
      await authRepository.apiClient.clearToken();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setError(null);
    try {
      final result = await authRepository.login(email, password);
      _isAuthenticated = true;
      if (result['user'] != null) {
        _currentUser = result['user'] as UserModel;
      } else {
        // Fallback to fetch profile
        _currentUser = await authRepository.getProfile();
      }
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String confirmPassword,
    required String fullName,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      await authRepository.register(
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        fullName: fullName,
      );
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await authRepository.logout();
    } catch (_) {
      // Ignore repository error and clear token locally anyway
      await authRepository.apiClient.clearToken();
    } finally {
      _currentUser = null;
      _isAuthenticated = false;
      _setLoading(false);
    }
  }

  Future<bool> updateProfile(String fullName) async {
    _setLoading(true);
    _setError(null);
    try {
      _currentUser = await authRepository.updateProfile(fullName);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    _setLoading(true);
    _setError(null);
    try {
      await authRepository.changePassword(currentPassword, newPassword);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> requestChangeEmail(String newEmail, String password) async {
    _setLoading(true);
    _setError(null);
    try {
      await authRepository.requestChangeEmail(newEmail, password);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> verifyNewEmail(String token) async {
    _setLoading(true);
    _setError(null);
    try {
      await authRepository.verifyNewEmail(token);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> sendOtp(String email) async {
    _setLoading(true);
    _setError(null);
    try {
      await authRepository.sendOtp(email);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> verifyOtp(String email, String code) async {
    _setLoading(true);
    _setError(null);
    try {
      await authRepository.verifyOtp(email, code);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> forgotPassword(String email) async {
    _setLoading(true);
    _setError(null);
    try {
      await authRepository.forgotPassword(email);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(String token, String newPassword) async {
    _setLoading(true);
    _setError(null);
    try {
      await authRepository.resetPassword(token, newPassword);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> uploadAvatar(String filePath) async {
    _setLoading(true);
    _setError(null);
    try {
      _currentUser = await authRepository.uploadAvatar(filePath);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteAvatar() async {
    _setLoading(true);
    _setError(null);
    try {
      await authRepository.deleteAvatar();
      if (_currentUser != null) {
        // Clear avatar local field
        _currentUser = UserModel(
          id: _currentUser!.id,
          email: _currentUser!.email,
          fullName: _currentUser!.fullName,
          role: _currentUser!.role,
          avatar: null,
        );
      }
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> loginWithGoogle() async {
    _setLoading(true);
    _setError(null);
    try {
      final googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled the sign-in
        _setLoading(false);
        return false;
      }
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) {
        throw Exception('Could not get Google ID token');
      }
      final result = await authRepository.loginWithGoogle(idToken);
      _isAuthenticated = true;
      if (result['user'] != null) {
        _currentUser = result['user'] as UserModel;
      } else {
        _currentUser = await authRepository.getProfile();
      }
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> loginWithFacebook() async {
    _setLoading(true);
    _setError(null);
    try {
      final loginResult = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );
      if (loginResult.status != LoginStatus.success) {
        _setLoading(false);
        return false;
      }
      final accessToken = loginResult.accessToken?.tokenString;
      if (accessToken == null) {
        throw Exception('Could not get Facebook access token');
      }
      final result = await authRepository.loginWithFacebook(accessToken);
      _isAuthenticated = true;
      if (result['user'] != null) {
        _currentUser = result['user'] as UserModel;
      } else {
        _currentUser = await authRepository.getProfile();
      }
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
