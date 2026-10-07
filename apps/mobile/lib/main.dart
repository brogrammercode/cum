import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'core/router/app_router.dart';
import 'core/storage/preferences_storage.dart';
import 'core/storage/secure_storage.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/controllers/auth_cubit.dart';
import 'features/auth/controllers/auth_repository.dart';
import 'services/api_client.dart';
import 'services/app_usage_service.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    await dotenv.load(fileName: '.env.example');
  }
  try {
    await Firebase.initializeApp();
  } catch (_) {}
  final secureStorage = SecureStorage();
  final preferences = PreferencesStorage();
  final apiClient = ApiClient(storage: secureStorage);
  final notifications = NotificationService(apiClient: apiClient);
  final authRepository = AuthRepository(
    apiClient: apiClient,
    storage: secureStorage,
  );
  runApp(
    CruzApp(
      secureStorage: secureStorage,
      preferences: preferences,
      apiClient: apiClient,
      notifications: notifications,
      authRepository: authRepository,
    ),
  );
}

class CruzApp extends StatefulWidget {
  const CruzApp({
    required this.secureStorage,
    required this.preferences,
    required this.apiClient,
    required this.notifications,
    required this.authRepository,
    super.key,
  });

  final SecureStorage secureStorage;
  final PreferencesStorage preferences;
  final ApiClient apiClient;
  final NotificationService notifications;
  final AuthRepository authRepository;

  @override
  State<CruzApp> createState() => _CruzAppState();
}

class _CruzAppState extends State<CruzApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = AppRouter.create();
    widget.notifications.initialize(onOpen: _router.go);
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: widget.secureStorage),
        RepositoryProvider.value(value: widget.preferences),
        RepositoryProvider.value(value: widget.apiClient),
        RepositoryProvider.value(value: widget.notifications),
      ],
      child: BlocProvider(
        create: (_) => AuthCubit(
          repository: widget.authRepository,
          notifications: widget.notifications,
          appUsage: AppUsageService(storage: widget.secureStorage),
        ),
        child: ScreenUtilInit(
          designSize: const Size(411.42857142857144, 843.4285714285714),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) => MaterialApp.router(
            title: 'Cruz',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            routerConfig: _router,
          ),
        ),
      ),
    );
  }
}
