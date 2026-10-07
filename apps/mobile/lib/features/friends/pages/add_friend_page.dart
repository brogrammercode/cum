import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/color.dart';
import '../../../services/api_client.dart';
import '../controllers/friends_repository.dart';
import '../models/friend_model.dart';

class AddFriendPage extends StatefulWidget {
  const AddFriendPage({super.key});

  @override
  State<AddFriendPage> createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
  late final FriendsRepository _repository;
  final _query = TextEditingController();
  List<FriendModel> _results = const [];
  bool _loading = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _repository = FriendsRepository(apiClient: context.read<ApiClient>());
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    if (_query.text.trim().isEmpty) return;
    setState(() => _loading = true);
    final results = await _repository.search(_query.text.trim());
    if (!mounted) return;
    setState(() {
      _results = results;
      _loading = false;
      _message = results.isEmpty
          ? 'No Cruz players matched that identity.'
          : null;
    });
  }

  Future<void> _send(FriendModel friend) async {
    try {
      await _repository.sendRequest(friend.id);
      if (!mounted) return;
      setState(() => _message = 'Friend request sent to ${friend.name}.');
    } catch (_) {
      if (!mounted) return;
      setState(() => _message = 'Could not send the request. Try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Friend')),
      body: ListView(
        padding: EdgeInsets.all(24.r),
        children: [
          Text(
            'Search by email, username, gamer tag, or Cruz invite identity.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          SizedBox(height: 18.h),
          TextField(
            controller: _query,
            onSubmitted: (_) => _search(),
            decoration: InputDecoration(
              hintText: 'Enter a friend identity',
              suffixIcon: IconButton(
                onPressed: _search,
                icon: const Icon(Icons.search),
              ),
            ),
          ),
          if (_loading) ...[
            SizedBox(height: 24.h),
            const Center(child: CircularProgressIndicator()),
          ],
          if (_message != null) ...[
            SizedBox(height: 18.h),
            Text(
              _message!,
              style: const TextStyle(color: AppColors.brandAccent),
            ),
          ],
          SizedBox(height: 18.h),
          for (final friend in _results)
            Card(
              margin: EdgeInsets.only(bottom: 10.h),
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(
                    friend.name.isEmpty ? '?' : friend.name[0].toUpperCase(),
                  ),
                ),
                title: Text(friend.name),
                subtitle: Text('${friend.gamerTag} · ${friend.email}'),
                trailing: friend.status == 'ACCEPTED'
                    ? const Icon(Icons.check, color: AppColors.success)
                    : FilledButton(
                        onPressed: () => _send(friend),
                        child: const Text('Add'),
                      ),
              ),
            ),
        ],
      ),
    );
  }
}
