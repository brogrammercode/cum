import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../constants/api.dart';
import '../../../core/config.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../services/api_client.dart';
import '../models/user_model.dart';

class AuthRepository {
  AuthRepository({required ApiClient apiClient, required SecureStorage storage})
    : _apiClient = apiClient,
      _storage = storage;

  final ApiClient _apiClient;
  final SecureStorage _storage;

  Future<({UserModel user, String accessToken})> signInWithGoogle() async {
    final clientId = AppConfig.googleServerClientId;
    if (clientId.isEmpty || clientId.startsWith('YOUR_')) {
      throw const AuthException(
        'Google sign-in is not configured for this build.',
      );
    }
    final googleSignIn = GoogleSignIn(serverClientId: clientId);
    final account = await googleSignIn.signIn();
    if (account == null) throw const AuthException('Sign-in was cancelled.');
    final authentication = await account.authentication;
    final idToken = authentication.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw const AuthException('Google did not return an ID token.');
    }
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.googleAuth,
        data: {'idToken': idToken},
      );
      final accessToken = response.data['accessToken']?.toString() ?? '';
      final refreshToken = response.data['refreshToken']?.toString() ?? '';
      final user = UserModel.fromJson(
        Map<String, dynamic>.from(response.data['user'] as Map),
      );
      await _storage.saveTokens(access: accessToken, refresh: refreshToken);
      return (user: user, accessToken: accessToken);
    } on DioException catch (error) {
      throw AuthException(
        error.response?.data?['message']?.toString() ??
            'Google sign-in failed.',
      );
    }
  }

  Future<UserModel?> getMe() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.me);
      return UserModel.fromJson(
        Map<String, dynamic>.from(response.data['user'] as Map),
      );
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) return null;
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _apiClient.dio.post(ApiEndpoints.logout);
    } finally {
      await _storage.clear();
    }
  }
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;
}
