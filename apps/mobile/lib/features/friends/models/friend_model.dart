class FriendModel {
  const FriendModel({
    required this.id,
    required this.name,
    required this.gamerTag,
    required this.email,
    this.avatarUrl,
    required this.status,
  });

  final String id;
  final String name;
  final String gamerTag;
  final String email;
  final String? avatarUrl;
  final String status;

  factory FriendModel.fromJson(Map<String, dynamic> json) {
    return FriendModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      gamerTag: json['gamer_tag']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      avatarUrl: json['avatar_url']?.toString(),
      status: json['relationship_status']?.toString() ?? 'NONE',
    );
  }
}
