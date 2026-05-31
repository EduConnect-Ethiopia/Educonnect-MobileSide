import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/app_providers.dart';
import '../auth/login_screen.dart';
import '../main_navigation_screen.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<bool>>(appStartupProvider, (previous, next) {
      next.whenData((isAuthenticated) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) {
            return;
          }

          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (_) => isAuthenticated
                  ? const MainNavigationScreen()
                  : const LoginScreen(),
            ),
          );
        });
      });
    });

    ref.watch(appStartupProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ClipOval(
            child: SizedBox(
              width: 260,
              height: 260,
              child: Image.asset(
                'assets/icons/educonnect logo.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
