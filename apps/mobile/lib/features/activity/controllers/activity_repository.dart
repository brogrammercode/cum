import 'package:dio/dio.dart';

import '../../../constants/api.dart';
import '../../../services/api_client.dart';
import '../models/activity_model.dart';

class ActivityRepository {
  ActivityRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<ActivityModel>> getFeed() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.activityFeed);
      final activities =
          response.data['activities'] as List<dynamic>? ?? const [];
      return activities
          .whereType<Map>()
          .map(
            (item) => ActivityModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    } on DioException {
      return const [];
    }
  }

  Future<void> startPresence({
    required String packageName,
    required String gameName,
  }) {
    return _apiClient.dio.post(
      ApiEndpoints.presenceStart,
      data: {'package_name': packageName, 'game_name': gameName},
    );
  }

  Future<void> stopPresence(String packageName) {
    return _apiClient.dio.post(
      ApiEndpoints.presenceStop,
      data: {'package_name': packageName},
    );
  }
}
