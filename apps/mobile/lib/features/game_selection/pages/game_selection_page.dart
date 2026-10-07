import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/color.dart';
import '../../../core/router/route_names.dart';
import '../../../services/app_usage_service.dart';
import '../../../services/api_client.dart';
import '../../../core/storage/preferences_storage.dart';
import '../controllers/game_selection_repository.dart';
import '../models/game_model.dart';

class GameSelectionPage extends StatefulWidget {
  const GameSelectionPage({super.key});

  @override
  State<GameSelectionPage> createState() => _GameSelectionPageState();
}

class _GameSelectionPageState extends State<GameSelectionPage> {
  late final GameSelectionRepository _repository;
  late final AppUsageService _appUsage;
  late final PreferencesStorage _preferences;
  final _selected = <String>{};
  List<GameModel> _games = const [];
  List<InstalledApp> _installedApps = const [];
  bool _loading = true;
  bool _saving = false;
  bool _usageAccess = false;
  bool _batteryOptimizationExempt = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _appUsage = AppUsageService(storage: context.read());
    _preferences = context.read<PreferencesStorage>();
    _repository = GameSelectionRepository(
      apiClient: context.read<ApiClient>(),
      appUsage: _appUsage,
    );
    _load(_appUsage);
  }

  Future<void> _load(AppUsageService appUsage) async {
    try {
      final results = await Future.wait([
        _repository.getCatalog(),
        _repository.getInstalledApps(),
        appUsage.hasUsageAccess(),
        appUsage.hasBatteryOptimizationExemption(),
      ]);
      if (!mounted) return;
      setState(() {
        _games = results[0] as List<GameModel>;
        _installedApps = results[1] as List<InstalledApp>;
        _usageAccess = results[2] as bool;
        _batteryOptimizationExempt = results[3] as bool;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load games from this device.';
      });
    }
  }

  void _toggle(GameModel game) {
    setState(() {
      if (!_selected.add(game.packageName)) _selected.remove(game.packageName);
    });
  }

  Future<void> _save() async {
    if (_selected.isEmpty) {
      setState(() => _error = 'Select at least one game to continue.');
      return;
    }
    if (!_usageAccess) {
      setState(
        () => _error = 'Usage Access is required for Android game detection.',
      );
      await AppUsageService(storage: context.read()).openUsageAccessSettings();
      return;
    }
    setState(() => _saving = true);
    try {
      final selectedGames = _allGames
          .where((game) => _selected.contains(game.packageName))
          .toList();
      await _repository.saveSelection(selectedGames);
      await _preferences.setSelectedGames(
        selectedGames
            .map(
              (game) => {'name': game.name, 'package_name': game.packageName},
            )
            .toList(),
      );
      await _preferences.setGameSetupComplete();
      if (!mounted) return;
      context.go(AppRoutes.home);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = 'Could not save your game selection. Try again.';
      });
    }
  }

  List<GameModel> get _allGames {
    final byPackage = <String, GameModel>{
      for (final game in _games) game.packageName: game,
    };
    for (final app in _installedApps) {
      byPackage.putIfAbsent(
        app.packageName,
        () => GameModel(
          id: app.packageName,
          name: app.label,
          packageName: app.packageName,
          isCurated: false,
        ),
      );
    }
    return byPackage.values.toList()..sort((a, b) => a.name.compareTo(b.name));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose your games')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(24.r),
              children: [
                Text(
                  'Cruz watches only the games you choose and tells your friends when you start playing.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                SizedBox(height: 20.h),
                if (!_appUsage.supportsAutomaticDetection)
                  Card(
                    color: const Color(0xFFFFF7ED),
                    child: const ListTile(
                      leading: Icon(Icons.touch_app_outlined),
                      title: Text('Manual status on iPhone'),
                      subtitle: Text(
                        'iOS does not allow Cruz to detect arbitrary apps in the background. Use “I’m playing” from the home screen instead.',
                      ),
                    ),
                  ),
                if (_appUsage.supportsAutomaticDetection && !_usageAccess)
                  Card(
                    color: const Color(0xFFFFF7ED),
                    child: ListTile(
                      leading: const Icon(
                        Icons.security,
                        color: AppColors.brandAccent,
                      ),
                      title: const Text('Enable Usage Access'),
                      subtitle: const Text(
                        'Android needs this permission to detect games in the background.',
                      ),
                      trailing: TextButton(
                        onPressed: () async {
                          await _appUsage.openUsageAccessSettings();
                          if (!mounted) return;
                          final access = await _appUsage.hasUsageAccess();
                          setState(() => _usageAccess = access);
                        },
                        child: const Text('Open'),
                      ),
                    ),
                  ),
                if (_appUsage.supportsAutomaticDetection &&
                    _usageAccess &&
                    !_batteryOptimizationExempt)
                  Card(
                    color: const Color(0xFFFFF7ED),
                    child: ListTile(
                      leading: const Icon(
                        Icons.battery_alert_outlined,
                        color: AppColors.brandAccent,
                      ),
                      title: const Text('Allow background reliability'),
                      subtitle: const Text(
                        'Battery optimization can stop Cruz detection while you play. Allow Cruz to run reliably in the background.',
                      ),
                      trailing: TextButton(
                        onPressed: () async {
                          await _appUsage.openBatteryOptimizationSettings();
                          if (!mounted) return;
                          final exempt = await _appUsage
                              .hasBatteryOptimizationExemption();
                          setState(() => _batteryOptimizationExempt = exempt);
                        },
                        child: const Text('Allow'),
                      ),
                    ),
                  ),
                if (_error != null) ...[
                  SizedBox(height: 10.h),
                  Text(_error!, style: const TextStyle(color: AppColors.error)),
                ],
                SizedBox(height: 14.h),
                Text(
                  'Curated games and installed apps',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: 12.h),
                for (final game in _allGames)
                  Card(
                    margin: EdgeInsets.only(bottom: 10.h),
                    child: CheckboxListTile(
                      value: _selected.contains(game.packageName),
                      onChanged: (_) => _toggle(game),
                      title: Text(game.name),
                      subtitle: Text(
                        game.isCurated
                            ? 'Cruz catalog'
                            : 'Manual app selection',
                      ),
                      secondary: CircleAvatar(
                        backgroundColor: AppColors.brandAccent.withValues(
                          alpha: .12,
                        ),
                        child: const Icon(
                          Icons.sports_esports,
                          color: AppColors.brandAccent,
                        ),
                      ),
                    ),
                  ),
                SizedBox(height: 16.h),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const CircularProgressIndicator()
                      : const Text('Continue to Cruz'),
                ),
              ],
            ),
    );
  }
}
