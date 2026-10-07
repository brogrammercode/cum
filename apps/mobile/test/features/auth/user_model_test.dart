import 'package:flutter_test/flutter_test.dart';

import 'package:cruz/features/auth/models/user_model.dart';

void main() {
  test('parses an authenticated Cruz user and setup state', () {
    final user = UserModel.fromJson({
      'id': 'u1',
      'name': 'Player One',
      'email': 'player@example.com',
      'gamer_tag': 'player_one',
      'status': 'ACTIVE',
      'game_setup_complete': true,
    });

    expect(user.id, 'u1');
    expect(user.gamerTag, 'player_one');
    expect(user.gameSetupComplete, isTrue);
    expect(user.isActive, isTrue);
  });

  test('uses safe defaults for incomplete API data', () {
    final user = UserModel.fromJson({});

    expect(user.name, 'Cruz player');
    expect(user.status, 'ACTIVE');
    expect(user.gameSetupComplete, isFalse);
  });
}
