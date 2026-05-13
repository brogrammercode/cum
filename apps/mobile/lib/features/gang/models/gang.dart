// ignore_for_file: non_constant_identifier_names

class GangModel {
  final String id;
  final String gang_id;
  final String name;
  final String bio;
  final String image;
  final String cover;
  final String status;
  final String created_at;
  final String updated_at;

  const GangModel({
    required this.id,
    required this.gang_id,
    required this.name,
    required this.bio,
    required this.image,
    required this.cover,
    required this.status,
    required this.created_at,
    required this.updated_at,
  });

  GangModel copyWith({
    String? id,
    String? gang_id,
    String? name,
    String? bio,
    String? image,
    String? cover,
    String? status,
    String? created_at,
    String? updated_at,
  }) {
    return GangModel(
      id: id ?? this.id,
      gang_id: gang_id ?? this.gang_id,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      image: image ?? this.image,
      cover: cover ?? this.cover,
      status: status ?? this.status,
      created_at: created_at ?? this.created_at,
      updated_at: updated_at ?? this.updated_at,
    );
  }

  factory GangModel.fromJson(Map<String, dynamic> json) {
    return GangModel(
      id: json['_id'],
      gang_id: json['gang_id'],
      name: json['name'],
      bio: json['bio'],
      image: json['image'],
      cover: json['cover'],
      status: json['status'],
      created_at: json['created_at'],
      updated_at: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'gang_id': gang_id,
      'name': name,
      'bio': bio,
      'image': image,
      'cover': cover,
      'status': status,
      'created_at': created_at,
      'updated_at': updated_at,
    };
  }
}
