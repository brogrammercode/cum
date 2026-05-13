// ignore_for_file: non_constant_identifier_names

import 'package:mobile/features/game/models/game.dart';
import 'package:mobile/features/gang/models/player.dart';

class GameSessionModel {
  final String id;
  final GameModel game;
  final PlayerModel player;
  final DateTime started_at;
  final DateTime? ended_at;
  final String created_at;
  final String updated_at;

  GameSessionModel({
    required this.id,
    required this.game,
    required this.player,
    required this.started_at,
    required this.ended_at,
    required this.created_at,
    required this.updated_at,
  });

  GameSessionModel copyWith({
    String? id,
    GameModel? game,
    PlayerModel? player,
    DateTime? started_at,
    DateTime? ended_at,
    String? created_at,
    String? updated_at,
  }) {
    return GameSessionModel(
      id: id ?? this.id,
      game: game ?? this.game,
      player: player ?? this.player,
      started_at: started_at ?? this.started_at,
      ended_at: ended_at ?? this.ended_at,
      created_at: created_at ?? this.created_at,
      updated_at: updated_at ?? this.updated_at,
    );
  }

  factory GameSessionModel.fromJson(Map<String, dynamic> json) {
    return GameSessionModel(
      id: json['_id'],
      game: json['game'],
      player: json['player'],
      started_at: json['started_at'],
      ended_at: json['ended_at'],
      created_at: json['created_at'],
      updated_at: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'game': game,
      'player': player,
      'started_at': started_at,
      'ended_at': ended_at,
      'created_at': created_at,
      'updated_at': updated_at,
    };
  }
}
