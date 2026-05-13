// ignore_for_file: non_constant_identifier_names

class GameModel {
  final String id;
  final String name;
  final String package_name;
  final String icon;
  final String platform;
  final String created_at;
  final String updated_at;

  GameModel({
    required this.id,
    required this.name,
    required this.package_name,
    required this.icon,
    required this.platform,
    required this.created_at,
    required this.updated_at,
  });

  factory GameModel.fromJson(Map<String, dynamic> json) {
    return GameModel(
      id: json['_id'],
      name: json['name'],
      package_name: json['package_name'],
      icon: json['icon'],
      platform: json['platform'],
      created_at: json['created_at'],
      updated_at: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'package_name': package_name,
      'icon': icon,
      'platform': platform,
      'created_at': created_at,
      'updated_at': updated_at,
    };
  }
}
