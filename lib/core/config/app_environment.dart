import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io' show Platform;

enum AppFlavor { dev, prod }

class AppEnvironment {
  AppEnvironment._();

  static const _flavorValue = String.fromEnvironment(
    'APP_FLAVOR',
    defaultValue: 'dev',
  );

  static AppFlavor get flavor {
    return _flavorValue.toLowerCase() == AppFlavor.prod.name
        ? AppFlavor.prod
        : AppFlavor.dev;
  }

  static bool get isDev => flavor == AppFlavor.dev;

  static String get envFileName {
    return flavor == AppFlavor.prod ? '.env.prod' : '.env.dev';
  }

  static String get appName {
    return _env('APP_NAME') ?? 'EduConnect Ethiopia';
  }

  /// Returns the appropriate API base URL based on platform and environment
  static String get apiBaseUrl {
    // 1. መጀመሪያ በ .env ፋይል ውስጥ የተቀመጠ URL ካለ እሱን ይፈትሻል
    final envUrl = _env('API_BASE_URL');
    if (envUrl != null && envUrl.isNotEmpty) {
      print('[AppEnvironment] Using API URL from .env: $envUrl');
      return envUrl;
    }

    // 2. ፕሮዳክሽን (Prod) ከሆነ የላይቭ ሰርቨር አድራሻውን ይመልሳል
    if (flavor == AppFlavor.prod) {
      return 'https://api.educonnect.et';
    }

    // 3. የዴቨሎፕመንት (Dev) አካባቢ ከሆነ እንደየ ታርጌት ፕላትፎርሙ ይመድባል
    String url;
    if (kIsWeb) {
      url = 'http://localhost:5001';
    } else if (Platform.isAndroid) {
      url = 'http://10.0.2.2:5001';   // ለአንድሮይድ አምሳይሌተር (Emulator)
    } else if (Platform.isIOS) {
      url = 'http://127.0.0.1:5001';  // ለ iOS አስሙሌተር (Simulator)
    } else {
      url = 'http://localhost:5001';  // ለዴስክቶፕ ወይም ለሌሎች
    }

    print('[AppEnvironment] Platform: ${kIsWeb ? 'Web' : Platform.operatingSystem}, API URL: $url');
    return url;
  }

  static Duration get connectTimeout {
    return Duration(
      milliseconds: int.tryParse(_env('API_CONNECT_TIMEOUT_MS') ?? '') ?? 30000,
    );
  }

  static Duration get receiveTimeout {
    return Duration(
      milliseconds: int.tryParse(_env('API_RECEIVE_TIMEOUT_MS') ?? '') ?? 30000,
    );
  }

  static String? _env(String key) {
    try {
      final value = dotenv.env[key]?.trim();
      return value == null || value.isEmpty ? null : value;
    } on Object {
      return null;
    }
  }
}
