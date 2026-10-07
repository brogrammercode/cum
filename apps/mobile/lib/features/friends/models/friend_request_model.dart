import 'friend_model.dart';

class FriendRequestModel {
  const FriendRequestModel({
    required this.id,
    required this.user,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final FriendModel user;
  final String status;
  final DateTime? createdAt;

  factory FriendRequestModel.fromJson(Map<String, dynamic> json) {
    return FriendRequestModel(
      id: json['id']?.toString() ?? '',
      user: FriendModel.fromJson(
        Map<String, dynamic>.from(json['user'] as Map? ?? const {}),
      ),
      status: json['status']?.toString() ?? 'PENDING',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }
}
