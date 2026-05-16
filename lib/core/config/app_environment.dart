import 'package:flutter_dotenv/flutter_dotenv.dart';

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

  static String get apiBaseUrl {
    return _env('API_BASE_URL') ??
        (flavor == AppFlavor.prod
            ? 'https://api.educonnect.et'
            : 'http://10.0.2.2:5001');
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
