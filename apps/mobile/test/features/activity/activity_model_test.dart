import 'package:flutter_test/flutter_test.dart';

import 'package:cruz/features/activity/models/activity_model.dart';

void main() {
  test('parses a playing activity with server timestamp', () {
    final activity = ActivityModel.fromJson({
      'id': 'session-1',
      'friend': {'name': 'Alex', 'gamer_tag': 'alex99'},
      'game': {'name': 'Minecraft'},
      'status': 'PLAYING',
      'started_at': '2026-10-07T10:00:00.000Z',
    });

    expect(activity.friendName, 'Alex');
    expect(activity.gameName, 'Minecraft');
    expect(activity.status, 'PLAYING');
    expect(activity.startedAt, isNotNull);
  });

  test('keeps missing timestamps nullable for offline activity', () {
    final activity = ActivityModel.fromJson({
      'friend': {'name': 'Alex'},
      'game': {'name': 'Roblox'},
      'status': 'ENDED',
    });

    expect(activity.status, 'ENDED');
    expect(activity.startedAt, isNull);
  });
}
