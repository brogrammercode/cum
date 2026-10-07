import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../services/api_client.dart';
import '../controllers/friends_repository.dart';
import '../models/friend_model.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  late final Future<List<FriendModel>> _friends;

  @override
  void initState() {
    super.initState();
    _friends = FriendsRepository(
      apiClient: context.read<ApiClient>(),
    ).getFriends();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Friends')),
      body: FutureBuilder<List<FriendModel>>(
        future: _friends,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final friends = snapshot.data ?? const <FriendModel>[];
          if (friends.isEmpty) {
            return const Center(child: Text('No approved friends yet.'));
          }
          return ListView.separated(
            padding: EdgeInsets.all(24.r),
            itemCount: friends.length,
            separatorBuilder: (_, _) => SizedBox(height: 10.h),
            itemBuilder: (context, index) {
              final friend = friends[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      friend.name.isEmpty ? '?' : friend.name[0].toUpperCase(),
                    ),
                  ),
                  title: Text(friend.name),
                  subtitle: Text(friend.gamerTag),
                  trailing: Text(friend.status),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
