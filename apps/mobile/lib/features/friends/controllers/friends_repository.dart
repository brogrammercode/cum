import 'package:dio/dio.dart';

import '../../../constants/api.dart';
import '../../../services/api_client.dart';
import '../models/friend_model.dart';
import '../models/friend_request_model.dart';

class FriendsRepository {
  FriendsRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<FriendModel>> getFriends() async {
    final response = await _apiClient.dio.get(ApiEndpoints.friends);
    final friends = response.data['friends'] as List<dynamic>? ?? const [];
    return friends
        .whereType<Map>()
        .map((item) => FriendModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<FriendModel>> search(String query) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.friendSearch,
        queryParameters: {'q': query},
      );
      final users = response.data['users'] as List<dynamic>? ?? const [];
      return users
          .whereType<Map>()
          .map((item) => FriendModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } on DioException {
      return const [];
    }
  }

  Future<void> sendRequest(String userId) {
    return _apiClient.dio.post(
      ApiEndpoints.friendRequests,
      data: {'user_id': userId},
    );
  }

  Future<void> respond(String requestId, String action) {
    return _apiClient.dio.patch(
      '${ApiEndpoints.friendRequests}/$requestId',
      data: {'action': action},
    );
  }

  Future<List<FriendRequestModel>> getRequests(String direction) async {
    final response = await _apiClient.dio.get(
      ApiEndpoints.friendRequests,
      queryParameters: {'direction': direction},
    );
    final requests = response.data['requests'] as List<dynamic>? ?? const [];
    return requests
        .whereType<Map>()
        .map(
          (item) =>
              FriendRequestModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  Future<void> cancel(String requestId) {
    return _apiClient.dio.delete('${ApiEndpoints.friendRequests}/$requestId');
  }
}
