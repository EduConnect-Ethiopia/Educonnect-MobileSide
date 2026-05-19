import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/config/app_environment.dart';
import '../../../core/di/app_providers.dart';
import '../../../core/widgets/educonnect_loading_indicator.dart';
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

    final startupState = ref.watch(appStartupProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const FlutterLogo(size: 84),
                SizedBox(height: 24.h),
                Text(
                  AppEnvironment.appName,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                SizedBox(height: 8.h),
                Text(
                  'Verified courses for Ethiopian learners',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                SizedBox(height: 24.h),
                startupState.when(
                  data: (isAuthenticated) => Text(
                    isAuthenticated ? 'Welcome back' : 'Ready to learn',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  error: (_, _) => Text(
                    'Ready to learn',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  loading: () => const EduConnectLoadingIndicator(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
