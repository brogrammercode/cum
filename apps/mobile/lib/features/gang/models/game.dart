// ignore_for_file: non_constant_identifier_names

class GameModel {
  final String id;
  final String game_id;
  final String name;
  final String description;
  final String image;
  final String type;
  final String status;
  final String created_at;
  final String updated_at;

  const GameModel({
    required this.id,
    required this.game_id,
    required this.name,
    required this.description,
    required this.image,
    required this.type,
    required this.status,
    required this.created_at,
    required this.updated_at,
  });

  GameModel copyWith({
    String? id,
    String? game_id,
    String? name,
    String? description,
    String? image,
    String? type,
    String? status,
    String? created_at,
    String? updated_at,
  }) {
    return GameModel(
      id: id ?? this.id,
      game_id: game_id ?? this.game_id,
      name: name ?? this.name,
      description: description ?? this.description,
      image: image ?? this.image,
      type: type ?? this.type,
      status: status ?? this.status,
      created_at: created_at ?? this.created_at,
      updated_at: updated_at ?? this.updated_at,
    );
  }

  factory GameModel.fromJson(Map<String, dynamic> json) {
    return GameModel(
      id: json['_id'],
      game_id: json['game_id'],
      name: json['name'],
      description: json['description'],
      image: json['image'],
      type: json['type'],
      status: json['status'],
      created_at: json['created_at'],
      updated_at: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'game_id': game_id,
      'name': name,
      'description': description,
      'image': image,
      'type': type,
      'status': status,
      'created_at': created_at,
      'updated_at': updated_at,
    };
  }
}
