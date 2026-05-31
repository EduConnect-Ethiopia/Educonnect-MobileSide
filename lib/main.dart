import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/config/app_bootstrap.dart';
import 'core/di/app_providers.dart';
import 'core/themes/app_theme.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/screens/splash/splash_screen.dart';

Future<void> main() async {
  final dependencies = await AppBootstrap.initialize();

  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(
          dependencies.sharedPreferences,
        ),
      ],
      child: const EduConnectApp(),
    ),
  );
}

class EduConnectApp extends ConsumerWidget {
  const EduConnectApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        final locale = settings.language == 'am'
            ? const Locale('am')
            : const Locale('en');

        return MaterialApp(
          title: 'EduConnect Ethiopia',
          debugShowCheckedModeBanner: false,
          useInheritedMediaQuery: true,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode:
              settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          locale: locale,
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('am')],
          home: const SplashScreen(),
        );
      },
    );
  }
}
