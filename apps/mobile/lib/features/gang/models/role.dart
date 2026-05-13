// ignore_for_file: non_constant_identifier_names

import 'package:mobile/features/gang/models/gang.dart';

class RoleModel {
  final String id;
  final GangModel gang;
  final String name;
  final String description;
  final List<String> permissions;
  final String created_at;
  final String updated_at;

  RoleModel({
    required this.id,
    required this.gang,
    required this.name,
    required this.description,
    required this.permissions,
    required this.created_at,
    required this.updated_at,
  });

  RoleModel copyWith({
    String? id,
    GangModel? gang,
    String? name,
    String? description,
    List<String>? permissions,
    String? created_at,
    String? updated_at,
  }) {
    return RoleModel(
      id: id ?? this.id,
      gang: gang ?? this.gang,
      name: name ?? this.name,
      description: description ?? this.description,
      permissions: permissions ?? this.permissions,
      created_at: created_at ?? this.created_at,
      updated_at: updated_at ?? this.updated_at,
    );
  }

  factory RoleModel.fromJson(Map<String, dynamic> map) {
    return RoleModel(
      id: map['_id'],
      gang: GangModel.fromJson(map['gang']),
      name: map['name'],
      description: map['description'],
      permissions: map['permissions'].cast<String>(),
      created_at: map['created_at'],
      updated_at: map['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'gang': gang.toJson(),
      'name': name,
      'description': description,
      'permissions': permissions,
      'created_at': created_at,
      'updated_at': updated_at,
    };
  }
}
