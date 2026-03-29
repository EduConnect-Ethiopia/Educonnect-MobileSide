import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(
    // ProviderScope is required for Riverpod to work
    // It stores the state of all providers in the app.
    const ProviderScope(
      child: EduConnectApp(),
    ),
  );
}

class EduConnectApp extends StatelessWidget {
  const EduConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ScreenUtilInit for responsive UI across different devices
    // designSize is the size of the screen you're designing for (usually Figma desktop or mobile)
    return ScreenUtilInit(
      designSize: const Size(375, 812), // standard iPhone 13/14 size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'EduConnect Ethiopia',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: const SplashScreen(),
        );
      },
    );
  }
}

// Temporary Splash Screen placeholder
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FlutterLogo(size: 80),
            SizedBox(height: 24.h),
            Text(
              'EduConnect Ethiopia',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 8.h),
            const Text('Empowering Education for All'),
          ],
        ),
      ),
    );
  }
}
