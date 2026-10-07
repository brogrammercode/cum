import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../services/app_usage_service.dart';
import '../../../core/storage/secure_storage.dart';
import '../../auth/controllers/auth_cubit.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _sharingEnabled = true;

  Future<void> _setSharing(bool enabled) async {
    final usage = AppUsageService(storage: context.read<SecureStorage>());
    if (enabled) {
      await usage.startMonitoring();
    } else {
      await usage.stopMonitoring();
    }
    if (mounted) setState(() => _sharingEnabled = enabled);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cruz settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.people_outline),
            title: const Text('Friends'),
            onTap: () => context.push(AppRoutes.friends),
          ),
          ListTile(
            leading: const Icon(Icons.mark_email_unread_outlined),
            title: const Text('Friend requests'),
            onTap: () => context.push(AppRoutes.friendRequests),
          ),
          ListTile(
            leading: const Icon(Icons.sports_esports_outlined),
            title: const Text('Game detection'),
            subtitle: const Text('Manage Android Usage Access and monitoring'),
            onTap: () => context.push(AppRoutes.gameSetup),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.visibility_off_outlined),
            title: const Text('Incognito mode'),
            subtitle: Text(
              _sharingEnabled
                  ? 'Friends can see your selected game activity'
                  : 'Activity sharing is paused for everyone',
            ),
            value: !_sharingEnabled,
            onChanged: (incognito) => _setSharing(!incognito),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign out'),
            onTap: () => context.read<AuthCubit>().signOut(),
          ),
        ],
      ),
    );
  }
}
