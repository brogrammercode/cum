import 'package:firebase_messaging/firebase_messaging.dart';

import '../constants/api.dart';
import '../services/api_client.dart';

class NotificationService {
  NotificationService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<void> initialize({required void Function(String path) onOpen}) async {
    try {
      final messaging = FirebaseMessaging.instance;
      FirebaseMessaging.onMessageOpenedApp.listen(
        (message) => _openMessage(message.data, onOpen),
      );
      final initial = await messaging.getInitialMessage();
      if (initial != null) _openMessage(initial.data, onOpen);
    } catch (_) {
      return;
    }
  }

  void _openMessage(
    Map<String, dynamic> data,
    void Function(String path) onOpen,
  ) {
    switch (data['type']?.toString()) {
      case 'friend_request':
        onOpen('/friends/requests');
        return;
      case 'chat':
        final conversationId = data['conversation_id']?.toString();
        if (conversationId != null && conversationId.isNotEmpty) {
          onOpen('/chat/$conversationId');
          return;
        }
        return;
      default:
        onOpen('/home');
    }
  }

  Future<void> registerDevice() async {
    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(alert: true, badge: true, sound: true);
      final token = await messaging.getToken();
      if (token == null || token.isEmpty) return;
      await _apiClient.dio.post(
        ApiEndpoints.deviceToken,
        data: {'token': token, 'platform': 'android'},
      );
    } catch (_) {
      return;
    }
  }
}
