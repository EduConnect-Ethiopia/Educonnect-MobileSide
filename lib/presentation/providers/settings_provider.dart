import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/di/app_providers.dart';

enum VideoQuality { auto, hd, sd }

class SettingsState {
  const SettingsState({
    required this.isDarkMode,
    required this.language,
    required this.notificationsEnabled,
    required this.wifiOnlyDownload,
    required this.videoQuality,
    required this.appVersion,
  });

  final bool isDarkMode;
  final String language;
  final bool notificationsEnabled;
  final bool wifiOnlyDownload;
  final VideoQuality videoQuality;
  final String appVersion;

  SettingsState copyWith({
    bool? isDarkMode,
    String? language,
    bool? notificationsEnabled,
    bool? wifiOnlyDownload,
    VideoQuality? videoQuality,
    String? appVersion,
  }) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      language: language ?? this.language,
      notificationsEnabled:
          notificationsEnabled ?? this.notificationsEnabled,
      wifiOnlyDownload: wifiOnlyDownload ?? this.wifiOnlyDownload,
      videoQuality: videoQuality ?? this.videoQuality,
      appVersion: appVersion ?? this.appVersion,
    );
  }
}

final settingsProvider =
    NotifierProvider<SettingsController, SettingsState>(SettingsController.new);

class SettingsController extends Notifier<SettingsState> {
  static const _keyDarkMode = 'settings_dark_mode';
  static const _keyLanguage = 'settings_language';
  static const _keyNotifications = 'settings_notifications';
  static const _keyWifiOnly = 'settings_wifi_only';
  static const _keyVideoQuality = 'settings_video_quality';

  @override
  SettingsState build() {
    Future.microtask(_load);
    return const SettingsState(
      isDarkMode: false,
      language: 'en',
      notificationsEnabled: true,
      wifiOnlyDownload: true,
      videoQuality: VideoQuality.auto,
      appVersion: '1.0.0',
    );
  }

  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  Future<void> _load() async {
    final qualityName = _prefs.getString(_keyVideoQuality) ?? 'auto';
    state = SettingsState(
      isDarkMode: _prefs.getBool(_keyDarkMode) ?? false,
      language: _prefs.getString(_keyLanguage) ?? 'en',
      notificationsEnabled: _prefs.getBool(_keyNotifications) ?? true,
      wifiOnlyDownload: _prefs.getBool(_keyWifiOnly) ?? true,
      videoQuality: VideoQuality.values.firstWhere(
        (q) => q.name == qualityName,
        orElse: () => VideoQuality.auto,
      ),
      appVersion: '1.0.0',
    );
  }

  Future<void> toggleTheme(bool value) async {
    await _prefs.setBool(_keyDarkMode, value);
    state = state.copyWith(isDarkMode: value);
  }

  Future<void> setLanguage(String? language) async {
    if (language == null) return;
    await _prefs.setString(_keyLanguage, language);
    state = state.copyWith(language: language);
  }

  Future<void> toggleNotifications(bool value) async {
    await _prefs.setBool(_keyNotifications, value);
    state = state.copyWith(notificationsEnabled: value);
  }

  Future<void> toggleWifiOnlyDownload(bool value) async {
    await _prefs.setBool(_keyWifiOnly, value);
    state = state.copyWith(wifiOnlyDownload: value);
  }

  Future<void> setVideoQuality(VideoQuality? quality) async {
    if (quality == null) return;
    await _prefs.setString(_keyVideoQuality, quality.name);
    state = state.copyWith(videoQuality: quality);
  }

  ThemeMode get themeMode =>
      state.isDarkMode ? ThemeMode.dark : ThemeMode.light;
}
