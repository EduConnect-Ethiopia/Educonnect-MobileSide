import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/app_providers.dart';
import '../../providers/auth_controller.dart';
import '../../providers/settings_provider.dart';
import '../auth/login_screen.dart';
import 'faq_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Switch between light and dark theme'),
            value: settings.isDarkMode,
            onChanged: (value) =>
                ref.read(settingsProvider.notifier).toggleTheme(value),
          ),
          ListTile(
            title: const Text('Language'),
            subtitle: Text(settings.language == 'en' ? 'English' : 'አማርኛ'),
            trailing: DropdownButton<String>(
              value: settings.language,
              items: const [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'am', child: Text('አማርኛ')),
              ],
              onChanged: ref.read(settingsProvider.notifier).setLanguage,
            ),
          ),
          SwitchListTile(
            title: const Text('Push Notifications'),
            value: settings.notificationsEnabled,
            onChanged: ref.read(settingsProvider.notifier).toggleNotifications,
          ),
          SwitchListTile(
            title: const Text('Download over WiFi only'),
            value: settings.wifiOnlyDownload,
            onChanged:
                ref.read(settingsProvider.notifier).toggleWifiOnlyDownload,
          ),
          ListTile(
            title: const Text('Video Quality'),
            trailing: DropdownButton<VideoQuality>(
              value: settings.videoQuality,
              items: const [
                DropdownMenuItem(
                  value: VideoQuality.auto,
                  child: Text('Auto'),
                ),
                DropdownMenuItem(value: VideoQuality.hd, child: Text('HD')),
                DropdownMenuItem(value: VideoQuality.sd, child: Text('SD')),
              ],
              onChanged: ref.read(settingsProvider.notifier).setVideoQuality,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('FAQ'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const FaqScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.support_agent_outlined),
            title: const Text('Help & Support'),
            subtitle: const Text('support@educonnect.et'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const FaqScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Clear Cache'),
            onTap: () => _clearCache(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            subtitle: Text('Version ${settings.appVersion}'),
            onTap: () => _showAboutDialog(context, settings.appVersion),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () => _confirmLogout(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _clearCache(BuildContext context, WidgetRef ref) async {
    final prefs = ref.read(sharedPreferencesProvider);
    final keys = prefs.getKeys().where((k) => k.startsWith('cache_')).toList();
    for (final key in keys) {
      await prefs.remove(key);
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cache cleared')),
    );
  }

  void _showAboutDialog(BuildContext context, String version) {
    showAboutDialog(
      context: context,
      applicationName: 'EduConnect Ethiopia',
      applicationVersion: version,
      applicationLegalese: '© ${DateTime.now().year} EduConnect Ethiopia',
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You will need to sign in again to access your courses.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sign out')),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    await ref.read(authControllerProvider.notifier).signOut();
    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }
}
