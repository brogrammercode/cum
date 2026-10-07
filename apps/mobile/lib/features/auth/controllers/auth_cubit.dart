import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../services/notification_service.dart';
import '../../../services/app_usage_service.dart';
import 'auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required AuthRepository repository,
    required NotificationService notifications,
    required AppUsageService appUsage,
  }) : _repository = repository,
       _notifications = notifications,
       _appUsage = appUsage,
       super(const AuthInitial());

  final AuthRepository _repository;
  final NotificationService _notifications;
  final AppUsageService _appUsage;

  Future<void> checkSession() async {
    emit(const AuthLoading());
    try {
      final user = await _repository.getMe();
      if (user == null || !user.isActive) {
        emit(const AuthUnauthenticated());
        return;
      }
      await _notifications.registerDevice();
      emit(AuthAuthenticated(user));
    } catch (_) {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> signInWithGoogle() async {
    emit(const AuthLoading());
    try {
      final result = await _repository.signInWithGoogle();
      await _notifications.registerDevice();
      emit(AuthAuthenticated(result.user));
    } on AuthException catch (error) {
      emit(AuthError(error.message));
    } catch (_) {
      emit(
        const AuthError(
          'Google sign-in failed. Check your connection and try again.',
        ),
      );
    }
  }

  Future<void> signOut() async {
    await _appUsage.stopMonitoring();
    await _appUsage.clearMonitoring();
    await _repository.signOut();
    emit(const AuthUnauthenticated());
  }
}
