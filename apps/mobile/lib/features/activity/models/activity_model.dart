class ActivityModel {
  const ActivityModel({
    required this.id,
    required this.friendName,
    required this.friendTag,
    required this.gameName,
    required this.status,
    required this.startedAt,
  });

  final String id;
  final String friendName;
  final String friendTag;
  final String gameName;
  final String status;
  final DateTime? startedAt;

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id']?.toString() ?? '',
      friendName: json['friend']?['name']?.toString() ?? 'Cruz friend',
      friendTag: json['friend']?['gamer_tag']?.toString() ?? '',
      gameName: json['game']?['name']?.toString() ?? 'Unknown game',
      status: json['status']?.toString() ?? 'OFFLINE',
      startedAt: DateTime.tryParse(json['started_at']?.toString() ?? ''),
    );
  }
}
