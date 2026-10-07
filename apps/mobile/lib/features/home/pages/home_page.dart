import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/color.dart';
import '../../../constants/assets.dart';
import '../../../core/router/route_names.dart';
import '../../../services/api_client.dart';
import '../../../services/app_usage_service.dart';
import '../../../core/storage/secure_storage.dart';
import '../../activity/controllers/activity_repository.dart';
import '../../activity/models/activity_model.dart';
import '../../activity/widgets/manual_presence_card.dart';
import '../../chat/controllers/chat_repository.dart';
import '../../chat/models/chat_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  late final ActivityRepository _activityRepository;
  late final ChatRepository _chatRepository;
  late Future<List<ActivityModel>> _activity;
  late Future<List<ConversationModel>> _conversations;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    final api = context.read<ApiClient>();
    _activityRepository = ActivityRepository(apiClient: api);
    _chatRepository = ChatRepository(apiClient: api);
    _activity = _activityRepository.getFeed();
    _conversations = _chatRepository.getConversations();
    AppUsageService(storage: context.read<SecureStorage>()).startMonitoring();
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) => _refresh());
  }

  @override
  void dispose() {
    _tabs.dispose();
    _pollTimer?.cancel();
    super.dispose();
  }

  void _refresh() {
    setState(() {
      _activity = _activityRepository.getFeed();
      _conversations = _chatRepository.getConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(AppAssets.logo, width: 32.r, height: 32.r),
            SizedBox(width: 10.w),
            const Text('Cruz'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => context.push(AppRoutes.addFriend),
            icon: const Icon(Icons.person_add_alt_1),
            tooltip: 'Add friend',
          ),
          IconButton(
            onPressed: () => context.push(AppRoutes.newChat),
            icon: const Icon(Icons.forum_outlined),
            tooltip: 'New chat',
          ),
          IconButton(
            onPressed: () => context.push(AppRoutes.settings),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          labelColor: AppColors.brandAccent,
          indicatorColor: AppColors.brandAccent,
          tabs: const [
            Tab(text: 'Activity Log'),
            Tab(text: 'Chat'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          Column(
            children: [
              if (!AppUsageService(
                storage: context.read<SecureStorage>(),
              ).supportsAutomaticDetection)
                ManualPresenceCard(repository: _activityRepository),
              Expanded(
                child: _ActivityTab(future: _activity, onRefresh: _refresh),
              ),
            ],
          ),
          _ChatTab(future: _conversations, onRefresh: _refresh),
        ],
      ),
    );
  }
}

class _ActivityTab extends StatelessWidget {
  const _ActivityTab({required this.future, required this.onRefresh});

  final Future<List<ActivityModel>> future;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: FutureBuilder<List<ActivityModel>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final activities = snapshot.data ?? const <ActivityModel>[];
          if (activities.isEmpty) {
            return ListView(
              padding: EdgeInsets.all(24.r),
              children: [
                SizedBox(height: 80.h),
                const Icon(
                  Icons.sports_esports_outlined,
                  size: 56,
                  color: AppColors.brandAccent,
                ),
                SizedBox(height: 16.h),
                Text(
                  'No friend activity yet',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: 8.h),
                Text(
                  'Add friends and Cruz will show their game sessions here.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            );
          }
          return ListView.separated(
            padding: EdgeInsets.all(24.r),
            itemCount: activities.length,
            separatorBuilder: (_, _) => SizedBox(height: 12.h),
            itemBuilder: (context, index) =>
                _ActivityCard(activity: activities[index]),
          );
        },
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.activity});

  final ActivityModel activity;

  @override
  Widget build(BuildContext context) {
    final online = activity.status == 'PLAYING';
    final elapsed = activity.startedAt == null
        ? ''
        : _elapsed(DateTime.now().difference(activity.startedAt!));
    return Card(
      child: ListTile(
        contentPadding: EdgeInsets.all(16.r),
        leading: CircleAvatar(
          backgroundColor: (online ? AppColors.success : AppColors.faintGrey)
              .withValues(alpha: .18),
          child: Icon(
            Icons.sports_esports_outlined,
            color: online ? AppColors.success : AppColors.textSecondary,
          ),
        ),
        title: Text(
          activity.friendName,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          online
              ? 'Playing ${activity.gameName}'
              : 'Offline · Last played ${activity.gameName}',
        ),
        trailing: online
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: const Text(
                      'LIVE',
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(elapsed, style: Theme.of(context).textTheme.bodySmall),
                ],
              )
            : const Icon(Icons.circle_outlined, color: AppColors.textSecondary),
      ),
    );
  }
}

class _ChatTab extends StatelessWidget {
  const _ChatTab({required this.future, required this.onRefresh});

  final Future<List<ConversationModel>> future;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: FutureBuilder<List<ConversationModel>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final conversations = snapshot.data ?? const <ConversationModel>[];
          if (conversations.isEmpty) {
            return ListView(
              padding: EdgeInsets.all(24.r),
              children: [
                SizedBox(height: 80.h),
                const Icon(
                  Icons.forum_outlined,
                  size: 56,
                  color: AppColors.brandAccent,
                ),
                SizedBox(height: 16.h),
                Text(
                  'Your chats will appear here',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: 8.h),
                Text(
                  'Start a conversation with an approved friend.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            );
          }
          return ListView.separated(
            padding: EdgeInsets.all(24.r),
            itemCount: conversations.length,
            separatorBuilder: (_, _) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              return Card(
                child: ListTile(
                  contentPadding: EdgeInsets.all(14.r),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.brandAccent.withValues(
                      alpha: .12,
                    ),
                    child: const Icon(
                      Icons.forum_outlined,
                      color: AppColors.brandAccent,
                    ),
                  ),
                  title: Text(conversation.title),
                  subtitle: Text(conversation.lastMessage),
                  trailing: conversation.unreadCount > 0
                      ? Badge(
                          label: Text('${conversation.unreadCount}'),
                          child: const Icon(Icons.chevron_right),
                        )
                      : const Icon(Icons.chevron_right),
                  onTap: () => context.push('/chat/${conversation.id}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

String _elapsed(Duration duration) {
  if (duration.inHours > 0) {
    return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
  }
  return '${duration.inMinutes}m';
}
