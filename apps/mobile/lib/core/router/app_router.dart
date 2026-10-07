import 'package:go_router/go_router.dart';

import '../../features/auth/pages/session_gate_page.dart';
import '../../features/chat/pages/chat_thread_page.dart';
import '../../features/chat/pages/new_conversation_page.dart';
import '../../features/friends/pages/add_friend_page.dart';
import '../../features/friends/pages/friends_page.dart';
import '../../features/friends/pages/friend_requests_page.dart';
import '../../features/game_selection/pages/game_selection_page.dart';
import '../../features/home/pages/home_page.dart';
import '../../features/settings/pages/settings_page.dart';
import 'route_names.dart';

class AppRouter {
  AppRouter._();

  static GoRouter create() {
    return GoRouter(
      initialLocation: AppRoutes.root,
      routes: [
        GoRoute(
          path: AppRoutes.root,
          builder: (_, _) => const SessionGatePage(),
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (_, _) => const SessionGatePage(),
        ),
        GoRoute(
          path: AppRoutes.gameSetup,
          builder: (_, _) => const GameSelectionPage(),
        ),
        GoRoute(path: AppRoutes.home, builder: (_, _) => const HomePage()),
        GoRoute(
          path: AppRoutes.addFriend,
          builder: (_, _) => const AddFriendPage(),
        ),
        GoRoute(
          path: AppRoutes.friends,
          builder: (_, _) => const FriendsPage(),
        ),
        GoRoute(
          path: AppRoutes.friendRequests,
          builder: (_, _) => const FriendRequestsPage(),
        ),
        GoRoute(
          path: AppRoutes.newChat,
          builder: (_, _) => const NewConversationPage(),
        ),
        GoRoute(
          path: AppRoutes.chat,
          builder: (_, state) => ChatThreadPage(
            conversationId: state.pathParameters['conversationId']!,
          ),
        ),
        GoRoute(
          path: AppRoutes.settings,
          builder: (_, _) => const SettingsPage(),
        ),
      ],
    );
  }
}
