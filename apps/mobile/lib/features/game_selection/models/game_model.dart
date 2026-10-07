class GameModel {
  const GameModel({
    required this.id,
    required this.name,
    required this.packageName,
    this.iconUrl,
    this.isCurated = true,
  });

  final String id;
  final String name;
  final String packageName;
  final String? iconUrl;
  final bool isCurated;

  factory GameModel.fromJson(Map<String, dynamic> json) {
    return GameModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      packageName: json['package_name']?.toString() ?? '',
      iconUrl: json['icon_url']?.toString(),
      isCurated: json['is_curated'] != false,
    );
  }
}
