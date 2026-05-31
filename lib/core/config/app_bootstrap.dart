import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_environment.dart';

class AppBootstrap {
  AppBootstrap._();

  static Future<AppDependencies> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();

    await dotenv.load(fileName: AppEnvironment.envFileName);
    await Hive.initFlutter();
    final sharedPreferencesFuture = SharedPreferences.getInstance();
    final courseContentCacheFuture = Hive.openBox<String>('course_content_cache');
    final materialFileCacheFuture = Hive.openBox<String>('material_file_cache');

    await Future.wait([
      sharedPreferencesFuture,
      courseContentCacheFuture,
      materialFileCacheFuture,
    ]);

    final sharedPreferences = await sharedPreferencesFuture;

    return AppDependencies(sharedPreferences: sharedPreferences);
  }
}

class AppDependencies {
  const AppDependencies({
    required this.sharedPreferences,
  });

  final SharedPreferences sharedPreferences;
}
