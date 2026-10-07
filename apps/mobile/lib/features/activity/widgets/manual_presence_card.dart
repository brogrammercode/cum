import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/color.dart';
import '../../../core/storage/preferences_storage.dart';
import '../controllers/activity_repository.dart';

class ManualPresenceCard extends StatefulWidget {
  const ManualPresenceCard({required this.repository, super.key});

  final ActivityRepository repository;

  @override
  State<ManualPresenceCard> createState() => _ManualPresenceCardState();
}

class _ManualPresenceCardState extends State<ManualPresenceCard> {
  List<Map<String, String>> _games = const [];
  Map<String, String>? _active;
  bool _loading = true;
  bool _working = false;

  PreferencesStorage get _preferences => context.read<PreferencesStorage>();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final games = await _preferences.getSelectedGames();
    final active = await _preferences.getManualPresence();
    if (!mounted) return;
    setState(() {
      _games = games;
      _active = active;
      _loading = false;
    });
  }

  Future<void> _start(Map<String, String> game) async {
    setState(() => _working = true);
    try {
      await widget.repository.startPresence(
        packageName: game['package_name'] ?? '',
        gameName: game['name'] ?? 'Selected game',
      );
      await _preferences.setManualPresence(game);
      if (mounted) setState(() => _active = game);
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _stop() async {
    final packageName = _active?['package_name'];
    if (packageName == null) return;
    setState(() => _working = true);
    try {
      await widget.repository.stopPresence(packageName);
      await _preferences.clearManualPresence();
      if (mounted) setState(() => _active = null);
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _games.isEmpty) return const SizedBox.shrink();
    final activeName = _active?['name'];
    return Card(
      margin: EdgeInsets.fromLTRB(24.r, 16.r, 24.r, 0),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Row(
          children: [
            const Icon(Icons.touch_app_outlined, color: AppColors.brandAccent),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                activeName == null ? 'Not playing' : 'Playing $activeName',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            if (_active != null)
              TextButton(
                onPressed: _working ? null : _stop,
                child: const Text('Stop'),
              )
            else
              PopupMenuButton<Map<String, String>>(
                enabled: !_working,
                onSelected: _start,
                itemBuilder: (context) => [
                  for (final game in _games)
                    PopupMenuItem(
                      value: game,
                      child: Text(game['name'] ?? 'Selected game'),
                    ),
                ],
                child: const Chip(label: Text("I'm playing")),
              ),
          ],
        ),
      ),
    );
  }
}
