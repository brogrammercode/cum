import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/color.dart';
import '../../../core/router/route_names.dart';
import '../controllers/auth_cubit.dart';
import '../controllers/auth_state.dart';
import 'login_page.dart';

class SessionGatePage extends StatefulWidget {
  const SessionGatePage({super.key});

  @override
  State<SessionGatePage> createState() => _SessionGatePageState();
}

class _SessionGatePageState extends State<SessionGatePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && context.read<AuthCubit>().state is AuthInitial) {
        context.read<AuthCubit>().checkSession();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go(
            state.user.gameSetupComplete ? AppRoutes.home : AppRoutes.gameSetup,
          );
        }
      },
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Scaffold(
              backgroundColor: AppColors.loginBackground,
              body: Center(
                child: CircularProgressIndicator(color: AppColors.brandAccent),
              ),
            );
          }
          if (state is AuthUnauthenticated || state is AuthError) {
            return const LoginPage();
          }
          return const Scaffold(
            backgroundColor: AppColors.loginBackground,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.brandAccent),
            ),
          );
        },
      ),
    );
  }
}
