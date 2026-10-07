import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/color.dart';
import '../../../services/api_client.dart';
import '../../friends/controllers/friends_repository.dart';
import '../../friends/models/friend_model.dart';
import '../controllers/chat_repository.dart';

class NewConversationPage extends StatefulWidget {
  const NewConversationPage({super.key});

  @override
  State<NewConversationPage> createState() => _NewConversationPageState();
}

class _NewConversationPageState extends State<NewConversationPage> {
  late final FriendsRepository _friendsRepository;
  late final ChatRepository _chatRepository;
  late final Future<List<FriendModel>> _friends;
  final _title = TextEditingController();
  final _selected = <String>{};
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final api = context.read<ApiClient>();
    _friendsRepository = FriendsRepository(apiClient: api);
    _chatRepository = ChatRepository(apiClient: api);
    _friends = _friendsRepository.getFriends();
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (_selected.isEmpty) return;
    setState(() => _saving = true);
    try {
      await _chatRepository.createConversation(
        title: _title.text.trim().isEmpty ? 'Cruz squad' : _title.text.trim(),
        memberIds: _selected.toList(),
      );
      if (!mounted) return;
      context.pop();
    } catch (_) {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New group chat')),
      body: FutureBuilder<List<FriendModel>>(
        future: _friends,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final friends = snapshot.data ?? const <FriendModel>[];
          return ListView(
            padding: EdgeInsets.all(24.r),
            children: [
              TextField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Group name'),
              ),
              SizedBox(height: 20.h),
              Text(
                'Choose approved friends',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 10.h),
              for (final friend in friends)
                Card(
                  margin: EdgeInsets.only(bottom: 8.h),
                  child: CheckboxListTile(
                    value: _selected.contains(friend.id),
                    onChanged: (_) {
                      setState(() {
                        if (!_selected.add(friend.id)) {
                          _selected.remove(friend.id);
                        }
                      });
                    },
                    secondary: CircleAvatar(
                      child: Text(
                        friend.name.isEmpty
                            ? '?'
                            : friend.name[0].toUpperCase(),
                      ),
                    ),
                    title: Text(friend.name),
                    subtitle: Text(friend.gamerTag),
                    activeColor: AppColors.brandAccent,
                  ),
                ),
              SizedBox(height: 16.h),
              FilledButton(
                onPressed: _saving || _selected.isEmpty ? null : _create,
                child: _saving
                    ? const CircularProgressIndicator()
                    : const Text('Create group chat'),
              ),
            ],
          );
        },
      ),
    );
  }
}
