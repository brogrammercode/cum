import 'package:dio/dio.dart';

import '../../../constants/api.dart';
import '../../../services/api_client.dart';
import '../../../services/app_usage_service.dart';
import '../models/game_model.dart';

class GameSelectionRepository {
  GameSelectionRepository({
    required ApiClient apiClient,
    required AppUsageService appUsage,
  }) : _apiClient = apiClient,
       _appUsage = appUsage;

  final ApiClient _apiClient;
  final AppUsageService _appUsage;

  Future<List<GameModel>> getCatalog() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.gameCatalog);
      final games = response.data['games'] as List<dynamic>? ?? const [];
      return games
          .whereType<Map>()
          .map((game) => GameModel.fromJson(Map<String, dynamic>.from(game)))
          .toList();
    } on DioException {
      return const [];
    }
  }

  Future<List<InstalledApp>> getInstalledApps() =>
      _appUsage.getLaunchableApps();

  Future<void> saveSelection(List<GameModel> games) async {
    await _apiClient.dio.put(
      ApiEndpoints.selectedGames,
      data: {
        'games': games
            .map(
              (game) => {
                'name': game.name,
                'package_name': game.packageName,
                'catalog_game_id': game.isCurated ? game.id : null,
              },
            )
            .toList(),
      },
    );
    await _appUsage.configureMonitoring(
      games.map((game) => game.packageName).toList(),
    );
    await _appUsage.startMonitoring();
  }
}
