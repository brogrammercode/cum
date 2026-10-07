class ApiEndpoints {
  ApiEndpoints._();

  static const googleAuth = '/auth/google';
  static const me = '/auth/me';
  static const logout = '/auth/logout';
  static const gameCatalog = '/games/catalog';
  static const selectedGames = '/games/selected';
  static const activityFeed = '/activity/feed';
  static const presenceStart = '/presence/sessions/start';
  static const presenceStop = '/presence/sessions/stop';
  static const friendSearch = '/friends/search';
  static const friends = '/friends';
  static const friendRequests = '/friends/requests';
  static const conversations = '/conversations';
  static const createConversation = '/conversations';
  static String conversationMessages(String id) =>
      '/conversations/$id/messages';
  static String conversationRead(String id) => '/conversations/$id/read';
  static const deviceToken = '/notifications/device-token';
}
