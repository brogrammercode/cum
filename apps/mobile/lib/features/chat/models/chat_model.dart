class ConversationModel {
  const ConversationModel({
    required this.id,
    required this.title,
    required this.lastMessage,
    required this.updatedAt,
    required this.memberCount,
    required this.unreadCount,
  });

  final String id;
  final String title;
  final String lastMessage;
  final DateTime? updatedAt;
  final int memberCount;
  final int unreadCount;

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Conversation',
      lastMessage: json['last_message']?.toString() ?? '',
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
      memberCount: int.tryParse(json['member_count']?.toString() ?? '') ?? 2,
      unreadCount: int.tryParse(json['unread_count']?.toString() ?? '') ?? 0,
    );
  }
}

class MessageModel {
  const MessageModel({
    required this.id,
    required this.body,
    required this.senderName,
    required this.createdAt,
    required this.mine,
  });

  final String id;
  final String body;
  final String senderName;
  final DateTime? createdAt;
  final bool mine;

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      senderName: json['sender']?['name']?.toString() ?? 'Cruz friend',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      mine: json['mine'] == true,
    );
  }
}
