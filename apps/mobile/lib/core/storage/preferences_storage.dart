import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class PreferencesStorage {
  PreferencesStorage([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const gameSetupKey = 'cruz_game_setup_complete';
  static const selectedGamesKey = 'cruz_selected_games';
  static const manualPresenceKey = 'cruz_manual_presence';

  Future<bool> hasCompletedGameSetup() async {
    return (await _storage.read(key: gameSetupKey)) == 'true';
  }

  Future<void> setGameSetupComplete() {
    return _storage.write(key: gameSetupKey, value: 'true');
  }

  Future<void> setSelectedGames(List<Map<String, String>> games) {
    return _storage.write(key: selectedGamesKey, value: jsonEncode(games));
  }

  Future<List<Map<String, String>>> getSelectedGames() async {
    final value = await _storage.read(key: selectedGamesKey);
    if (value == null) return const [];
    try {
      final decoded = jsonDecode(value) as List<dynamic>;
      return decoded
          .whereType<Map>()
          .map((item) => Map<String, String>.from(item))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> setManualPresence(Map<String, String> game) {
    return _storage.write(key: manualPresenceKey, value: jsonEncode(game));
  }

  Future<Map<String, String>?> getManualPresence() async {
    final value = await _storage.read(key: manualPresenceKey);
    if (value == null) return null;
    try {
      return Map<String, String>.from(jsonDecode(value) as Map);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearManualPresence() => _storage.delete(key: manualPresenceKey);

  Future<void> clear() => _storage.delete(key: gameSetupKey);
}
