// ignore_for_file: non_constant_identifier_names

import 'package:mobile/features/auth/models/user.dart';
import 'package:mobile/features/gang/models/gang.dart';
import 'package:mobile/features/gang/models/role.dart';

class PlayerModel {
  final String id;
  final String player_id;
  final String player_name;
  final UserModel user;
  final GangModel gang;
  final RoleModel role;
  final List<String> permissions;
  final String created_at;
  final String updated_at;

  const PlayerModel({
    required this.id,
    required this.player_id,
    required this.player_name,
    required this.user,
    required this.gang,
    required this.role,
    required this.permissions,
    required this.created_at,
    required this.updated_at,
  });

  PlayerModel copyWith({
    String? id,
    String? player_id,
    String? player_name,
    UserModel? user,
    GangModel? gang,
    RoleModel? role,
    List<String>? permissions,
    String? created_at,
    String? updated_at,
  }) {
    return PlayerModel(
      id: id ?? this.id,
      player_id: player_id ?? this.player_id,
      player_name: player_name ?? this.player_name,
      user: user ?? this.user,
      gang: gang ?? this.gang,
      role: role ?? this.role,
      permissions: permissions ?? this.permissions,
      created_at: created_at ?? this.created_at,
      updated_at: updated_at ?? this.updated_at,
    );
  }

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      id: json['_id'],
      player_id: json['player_id'],
      player_name: json['player_name'],
      user: UserModel.fromJson(json['user']),
      gang: GangModel.fromJson(json['gang']),
      role: RoleModel.fromJson(json['role']),
      permissions: json['permissions'].cast<String>(),
      created_at: json['created_at'],
      updated_at: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'player_id': player_id,
      'player_name': player_name,
      'user': user.toJson(),
      'gang': gang.toJson(),
      'role': role.toJson(),
      'permissions': permissions,
      'created_at': created_at,
      'updated_at': updated_at,
    };
  }
}
