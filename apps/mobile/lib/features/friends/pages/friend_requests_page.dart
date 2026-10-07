import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../services/api_client.dart';
import '../controllers/friends_repository.dart';
import '../models/friend_request_model.dart';

class FriendRequestsPage extends StatefulWidget {
  const FriendRequestsPage({super.key});

  @override
  State<FriendRequestsPage> createState() => _FriendRequestsPageState();
}

class _FriendRequestsPageState extends State<FriendRequestsPage> {
  late final FriendsRepository _repository;
  late Future<List<FriendRequestModel>> _incoming;
  late Future<List<FriendRequestModel>> _outgoing;

  @override
  void initState() {
    super.initState();
    _repository = FriendsRepository(apiClient: context.read<ApiClient>());
    _reload();
  }

  void _reload() {
    _incoming = _repository.getRequests('incoming');
    _outgoing = _repository.getRequests('outgoing');
  }

  Future<void> _respond(String id, String action) async {
    await _repository.respond(id, action);
    if (!mounted) return;
    setState(_reload);
  }

  Future<void> _cancel(String id) async {
    await _repository.cancel(id);
    if (!mounted) return;
    setState(_reload);
  }

  Widget _section(
    String title,
    Future<List<FriendRequestModel>> future, {
    required bool incoming,
  }) {
    return FutureBuilder<List<FriendRequestModel>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final requests = snapshot.data ?? const <FriendRequestModel>[];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(24.r, 18.r, 24.r, 8.r),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            if (requests.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Text('Nothing here yet.'),
              ),
            for (final request in requests)
              Card(
                margin: EdgeInsets.fromLTRB(24.r, 4.r, 24.r, 6.r),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      request.user.name.isEmpty
                          ? '?'
                          : request.user.name[0].toUpperCase(),
                    ),
                  ),
                  title: Text(request.user.name),
                  subtitle: Text('@${request.user.gamerTag}'),
                  trailing: incoming
                      ? Wrap(
                          spacing: 2,
                          children: [
                            IconButton(
                              tooltip: 'Accept',
                              onPressed: () => _respond(request.id, 'accept'),
                              icon: const Icon(Icons.check),
                            ),
                            IconButton(
                              tooltip: 'Reject',
                              onPressed: () => _respond(request.id, 'reject'),
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        )
                      : TextButton(
                          onPressed: () => _cancel(request.id),
                          child: const Text('Cancel'),
                        ),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Friend requests')),
      body: ListView(
        padding: EdgeInsets.only(bottom: 24.h),
        children: [
          _section('Incoming', _incoming, incoming: true),
          _section('Sent', _outgoing, incoming: false),
        ],
      ),
    );
  }
}
