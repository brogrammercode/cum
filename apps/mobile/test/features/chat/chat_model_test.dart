import 'package:flutter_test/flutter_test.dart';

import 'package:cruz/features/chat/models/chat_model.dart';

void main() {
  test('parses unread conversation count', () {
    final conversation = ConversationModel.fromJson({
      'id': 'conversation-1',
      'title': 'Squad chat',
      'last_message': 'Ready?',
      'member_count': 3,
      'unread_count': 4,
    });

    expect(conversation.memberCount, 3);
    expect(conversation.unreadCount, 4);
    expect(conversation.lastMessage, 'Ready?');
  });
}
