import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/assets.dart';
import '../../../core/color.dart';
import '../controllers/auth_cubit.dart';
import '../controllers/auth_state.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.loginBackground,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final error = state is AuthError ? state.message : null;
          final loading = state is AuthLoading;
          return Scaffold(
            backgroundColor: AppColors.loginBackground,
            body: CustomPaint(
              painter: const _LoginBackgroundPainter(),
              child: SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxHeight < 700.r;
                    final horizontal = (constraints.maxWidth * .08).clamp(
                      24.r,
                      48.r,
                    );
                    return SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        horizontal,
                        compact ? 22.r : constraints.maxHeight * .085,
                        horizontal,
                        compact ? 24.r : 34.r,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: math.max(
                            0,
                            constraints.maxHeight - (compact ? 46.r : 119.r),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: (constraints.maxWidth * .74).clamp(
                                240.r,
                                320.r,
                              ),
                              child: Image.asset(
                                AppAssets.logo,
                                fit: BoxFit.contain,
                                alignment: Alignment.centerLeft,
                              ),
                            ),
                            SizedBox(
                              height: compact
                                  ? 25.r
                                  : constraints.maxHeight * .035,
                            ),
                            Text(
                              'YOUR SQUAD\nIS ONLINE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: (constraints.maxWidth * .098).clamp(
                                  31.r,
                                  48.r,
                                ),
                                height: .99,
                                fontWeight: FontWeight.w800,
                                letterSpacing: (-1.3).r,
                              ),
                            ),
                            SizedBox(height: compact ? 14.r : 22.r),
                            ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: 360.r),
                              child: Text(
                                'See who is playing,\nchat with your friends,\nand never miss a session.',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: .82),
                                  fontSize: (constraints.maxWidth * .048).clamp(
                                    16.r,
                                    22.r,
                                  ),
                                  height: 1.3,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: compact
                                  ? 105.r
                                  : (constraints.maxHeight * .275).clamp(
                                      145.r,
                                      570.r,
                                    ),
                            ),
                            if (error != null) ...[
                              _ErrorBanner(message: error),
                              SizedBox(height: 14.r),
                            ],
                            _GoogleButton(
                              loading: loading,
                              onPressed: () =>
                                  context.read<AuthCubit>().signInWithGoogle(),
                            ),
                            SizedBox(height: 26.r),
                            const _LegalCopy(),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LoginBackgroundPainter extends CustomPainter {
  const _LoginBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = AppColors.loginBackground,
    );
    _glow(
      canvas,
      size,
      Offset(size.width * 1.08, size.height * .03),
      size.width * 1.05,
      .95,
    );
    _glow(
      canvas,
      size,
      Offset(size.width * 1.09, size.height * .97),
      size.width * 1.1,
      .9,
    );
    _arcs(
      canvas,
      size,
      Offset(size.width * 1.08, size.height * .02),
      size.width * .55,
      5,
      size.width * .15,
    );
    _arcs(
      canvas,
      size,
      Offset(size.width * 1.08, size.height * .98),
      size.width * .56,
      6,
      size.width * .15,
    );
  }

  void _glow(
    Canvas canvas,
    Size size,
    Offset center,
    double radius,
    double strength,
  ) {
    final paint = Paint()
      ..shader = RadialGradient(
        center: Alignment(
          (center.dx / size.width) * 2 - 1,
          (center.dy / size.height) * 2 - 1,
        ),
        radius: radius / math.max(size.width, size.height),
        colors: [
          AppColors.brandAccent.withValues(alpha: .74 * strength),
          AppColors.brandAccent.withValues(alpha: .25 * strength),
          Colors.transparent,
        ],
        stops: const [.02, .28, .8],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, paint);
  }

  void _arcs(
    Canvas canvas,
    Size size,
    Offset center,
    double start,
    int count,
    double step,
  ) {
    for (var i = 0; i < count; i++) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = i == 0 ? 1.35.r : 1.r
        ..color = AppColors.brandAccent.withValues(
          alpha: (.52 - i * .065).clamp(.12, .52),
        );
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: start + i * step),
        math.pi * .48,
        math.pi * .52,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.loading, required this.onPressed});

  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 64.r,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(34.r),
        child: InkWell(
          onTap: loading ? null : onPressed,
          borderRadius: BorderRadius.circular(34.r),
          child: Center(
            child: loading
                ? SizedBox(
                    width: 22.r,
                    height: 22.r,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Color(0xFF11151B),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'G',
                        style: TextStyle(
                          color: const Color(0xFF4285F4),
                          fontSize: 28.r,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(width: 16.r),
                      Text(
                        'Continue with Google',
                        style: TextStyle(
                          color: const Color(0xFF11151B),
                          fontSize: 17.r,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: const Color(0xFF3A1518).withValues(alpha: .9),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: const Color(0xFFFF807A).withValues(alpha: .35),
        ),
      ),
      child: Text(
        message,
        style: TextStyle(color: const Color(0xFFFFD8D5), fontSize: 12.r),
      ),
    );
  }
}

class _LegalCopy extends StatelessWidget {
  const _LegalCopy();

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: 'By continuing, you agree to Cruz ',
        style: TextStyle(
          color: Colors.white.withValues(alpha: .88),
          fontSize: 14.r,
          height: 1.45,
        ),
        children: const [
          TextSpan(
            text: 'Privacy Policy',
            style: TextStyle(decoration: TextDecoration.underline),
          ),
          TextSpan(text: ' and '),
          TextSpan(
            text: 'Terms of Service.',
            style: TextStyle(decoration: TextDecoration.underline),
          ),
        ],
      ),
    );
  }
}
