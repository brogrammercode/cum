import 'package:dio/dio.dart';

import '../../../constants/api.dart';
import '../../../services/api_client.dart';
import '../models/chat_model.dart';

class ChatRepository {
  ChatRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<ConversationModel>> getConversations() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.conversations);
      final items =
          response.data['conversations'] as List<dynamic>? ?? const [];
      return items
          .whereType<Map>()
          .map(
            (item) =>
                ConversationModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    } on DioException {
      return const [];
    }
  }

  Future<List<MessageModel>> getMessages(String conversationId) async {
    final response = await _apiClient.dio.get(
      ApiEndpoints.conversationMessages(conversationId),
    );
    final items = response.data['messages'] as List<dynamic>? ?? const [];
    return items
        .whereType<Map>()
        .map((item) => MessageModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<String> createConversation({
    required String title,
    required List<String> memberIds,
  }) async {
    final response = await _apiClient.dio.post(
      ApiEndpoints.createConversation,
      data: {'title': title, 'member_ids': memberIds},
    );
    return response.data['conversation']['id'].toString();
  }

  Future<void> sendMessage(String conversationId, String body) {
    return _apiClient.dio.post(
      ApiEndpoints.conversationMessages(conversationId),
      data: {'body': body},
    );
  }

  Future<void> markRead(String conversationId) {
    return _apiClient.dio.patch(ApiEndpoints.conversationRead(conversationId));
  }
}
