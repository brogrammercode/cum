// ignore_for_file: non_constant_identifier_names

import 'package:mobile/features/gang/models/game.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String token;
  final String user_id;
  final String image;
  final String cover;
  final String bio;
  final List<GameModel> games;
  final List<UserModel> friends;
  final List<UserModel> following;
  final List<UserModel> followers;
  final String created_at;
  final String updated_at;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.token,
    required this.user_id,
    required this.image,
    required this.cover,
    required this.bio,
    required this.games,
    required this.friends,
    required this.following,
    required this.followers,
    required this.created_at,
    required this.updated_at,
  });

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? token,
    String? user_id,
    String? image,
    String? cover,
    String? bio,
    List<GameModel>? games,
    List<UserModel>? friends,
    List<UserModel>? following,
    List<UserModel>? followers,
    String? created_at,
    String? updated_at,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      token: token ?? this.token,
      user_id: user_id ?? this.user_id,
      image: image ?? this.image,
      cover: cover ?? this.cover,
      bio: bio ?? this.bio,
      games: games ?? this.games,
      friends: friends ?? this.friends,
      following: following ?? this.following,
      followers: followers ?? this.followers,
      created_at: created_at ?? this.created_at,
      updated_at: updated_at ?? this.updated_at,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'],
      email: json['email'],
      name: json['name'],
      token: json['token'],
      user_id: json['user_id'],
      image: json['image'],
      cover: json['cover'],
      bio: json['bio'],
      games: (json['games'] as List<dynamic>)
          .map((e) => GameModel.fromJson(e))
          .toList(),
      friends: (json['friends'] as List<dynamic>)
          .map((e) => UserModel.fromJson(e))
          .toList(),
      following: (json['following'] as List<dynamic>)
          .map((e) => UserModel.fromJson(e))
          .toList(),
      followers: (json['followers'] as List<dynamic>)
          .map((e) => UserModel.fromJson(e))
          .toList(),
      created_at: json['created_at'],
      updated_at: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'token': token,
      'user_id': user_id,
      'image': image,
      'cover': cover,
      'bio': bio,
      'games': games.map((e) => e.toJson()).toList(),
      'friends': friends.map((e) => e.toJson()).toList(),
      'following': following.map((e) => e.toJson()).toList(),
      'followers': followers.map((e) => e.toJson()).toList(),
      'created_at': created_at,
      'updated_at': updated_at,
    };
  }
}
