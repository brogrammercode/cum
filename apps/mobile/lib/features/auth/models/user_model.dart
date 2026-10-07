class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.status,
    required this.gameSetupComplete,
    required this.gamerTag,
  });

  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String status;
  final bool gameSetupComplete;
  final String gamerTag;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Cruz player',
      email: json['email']?.toString() ?? '',
      avatarUrl: json['avatar_url']?.toString(),
      status: json['status']?.toString() ?? 'ACTIVE',
      gameSetupComplete: json['game_setup_complete'] == true,
      gamerTag: json['gamer_tag']?.toString() ?? '',
    );
  }

  bool get isActive => status == 'ACTIVE';
}
