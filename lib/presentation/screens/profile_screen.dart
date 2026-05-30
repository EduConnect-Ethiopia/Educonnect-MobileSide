import 'dart:typed_data';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../domain/entities/course.dart';
import '../providers/auth_controller.dart';
import '../providers/notification_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/settings_provider.dart';
import 'assessments/assessments_list_screen.dart';
import 'auth/login_screen.dart';
import 'certificates/certificate_list_screen.dart';
import 'notifications/notification_screen.dart';
import 'profile/edit_profile_screen.dart';
import 'profile/help_support_screen.dart';
import 'profile/settings_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final notificationState = ref.watch(notificationControllerProvider);
    final isAmharic = ref.watch(settingsProvider).language == 'am';

    return Scaffold(
      appBar: AppBar(
        title: Text(isAmharic ? 'መገለጫ' : 'Profile'),
        actions: [
          IconButton(
            tooltip: isAmharic ? 'ማሳወቂያዎች' : 'Notifications',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const NotificationScreen(),
                ),
              );
            },
            icon: Badge(
              isLabelVisible: notificationState.unreadCount > 0,
              label: Text('${notificationState.unreadCount}'),
              child: const Icon(Icons.notifications_outlined),
            ),
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Text(isAmharic ? 'መገለጫውን መጫን አልተቻለም' : 'Unable to load profile'),
        ),
        data: (profile) {
          if (profile == null) {
            return Center(
              child: Text(
                isAmharic ? 'መገለጫዎን ለማየት ይግቡ' : 'Sign in to view your profile',
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _ProfileHeader(
                profile: profile,
                onAvatarTap: () => _showAvatarOptions(context, ref, profile),
              ),
              const SizedBox(height: 16),
              _StatsRow(stats: profile.stats),
              const SizedBox(height: 16),
              _ProfileAction(
                icon: Icons.edit_outlined,
                title: isAmharic ? 'መገለጫ አስተካክል' : 'Edit Profile',
                subtitle: isAmharic
                    ? 'ስልክ፣ ባዮ እና የይለፍ ቃል አዘምን'
                    : 'Update phone, bio, and password',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const EditProfileScreen(),
                    ),
                  );
                },
              ),
              _ProfileAction(
                icon: Icons.help_outline,
                title: isAmharic ? 'እገዛ እና ድጋፍ' : 'Help & Support',
                subtitle: isAmharic
                    ? 'ጥያቄና መልስ እና የድጋፍ መገኛ'
                    : 'FAQ and contact support',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const HelpSupportScreen(),
                    ),
                  );
                },
              ),
              _ProfileAction(
                icon: Icons.settings_outlined,
                title: isAmharic ? 'ቅንብሮች' : 'Settings',
                subtitle: isAmharic
                    ? 'ገጽታ፣ ቋንቋ እና ምርጫዎች'
                    : 'Theme, language, and preferences',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const SettingsScreen(),
                    ),
                  );
                },
              ),
              _ProfileAction(
                icon: Icons.workspace_premium_outlined,
                title: isAmharic ? 'ሰርተፊኬቶች' : 'Certificates',
                subtitle: isAmharic
                    ? 'ያገኙትን ሰርተፊኬት ይመልከቱ እና ያውርዱ'
                    : 'View and download earned certificates',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const CertificateListScreen(),
                    ),
                  );
                },
              ),
              _ProfileAction(
                icon: Icons.quiz_outlined,
                title: isAmharic ? 'ፈተናዎች' : 'Assessments',
                subtitle: isAmharic
                    ? 'ለተመዘገቡበት ኮርስ ፈተናዎችን ይውሰዱ'
                    : 'Take quizzes for enrolled courses',
                onTap: () => _openAssessments(context, ref),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  await ref.read(authControllerProvider.notifier).signOut();
                  if (!context.mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute<void>(
                      builder: (_) => const LoginScreen(),
                    ),
                    (_) => false,
                  );
                },
                icon: const Icon(Icons.logout_outlined),
                label: Text(isAmharic ? 'ውጣ' : 'Sign out'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openAssessments(BuildContext context, WidgetRef ref) async {
    final courses = await ref.read(profileCoursesForAssessmentsProvider.future);
    final isAmharic = ref.read(settingsProvider).language == 'am';
    if (!context.mounted) return;

    if (courses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isAmharic
                ? 'ፈተና ለመውሰድ በአንድ ኮርስ ይመዝገቡ'
                : 'Enroll in a course to take assessments',
          ),
        ),
      );
      return;
    }

    final course = courses.length == 1
        ? courses.first
        : await showModalBottomSheet<Course>(
            context: context,
            builder: (ctx) {
              return SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Choose a course',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    ...courses.map(
                      (c) => ListTile(
                        title: Text(c.title),
                        onTap: () => Navigator.pop(ctx, c),
                      ),
                    ),
                  ],
                ),
              );
            },
          );

    if (course == null || !context.mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AssessmentsListScreen(courseId: course.id),
      ),
    );
  }

  Future<void> _showAvatarOptions(
    BuildContext context,
    WidgetRef ref,
    LearnerProfile profile,
  ) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose photo'),
                onTap: () => Navigator.of(ctx).pop('choose'),
              ),
              if (profile.avatarBytes != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: const Text('Remove photo'),
                  onTap: () => Navigator.of(ctx).pop('remove'),
                ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('Cancel'),
                onTap: () => Navigator.of(ctx).pop('cancel'),
              ),
            ],
          ),
        );
      },
    );

    if (action == null || action == 'cancel') {
      return;
    }

    if (action == 'remove') {
      await ref.read(profileLocalDataSourceProvider).clearAvatar();
      ref.invalidate(profileProvider);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile photo removed')),
      );
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    final bytes = result.files.single.bytes;
    if (bytes == null || bytes.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to read selected image')),
      );
      return;
    }

    await ref.read(profileLocalDataSourceProvider).saveProfile(
          avatarBase64: base64Encode(bytes),
        );
    ref.invalidate(profileProvider);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile photo updated')),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.profile,
    required this.onAvatarTap,
  });

  final LearnerProfile profile;
  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = profile.user;
    final initial = user.fullName.trim().isEmpty
        ? 'L'
        : user.fullName.trim().characters.first.toUpperCase();
    final avatarBytes = profile.avatarBytes;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF333333)
              : const Color(0xFFE0E0E0),
        ),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              GestureDetector(
                onTap: onAvatarTap,
                child: CircleAvatar(
                  radius: 44,
                  backgroundColor: AppColors.primary,
                  backgroundImage: avatarBytes != null
                      ? MemoryImage(Uint8List.fromList(avatarBytes))
                      : null,
                  child: avatarBytes == null
                      ? Text(
                          initial,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                        )
                      : null,
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Material(
                  color: Theme.of(context).colorScheme.primary,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onAvatarTap,
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(Icons.camera_alt_outlined, size: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            user.fullName,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          if (profile.bio.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              profile.bio,
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurface),
            ),
          ],
          if (profile.isVerified) ...[
            const SizedBox(height: 8),
            Chip(
              label: Text(
                'Verified Learner',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.green.shade100
                      : Colors.green.shade900,
                  fontWeight: FontWeight.w700,
                ),
              ),
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.green.shade900.withValues(alpha: 0.35)
                  : Colors.green.shade100,
              side: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.green.shade400
                    : Colors.green.shade300,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.stats});

  final ProfileStats stats;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(
          label: 'Completed',
          value: '${stats.coursesCompleted}',
        ),
        const SizedBox(width: 8),
        _StatCard(
          label: 'Certificates',
          value: '${stats.certificatesEarned}',
        ),
        const SizedBox(width: 8),
        _StatCard(
          label: 'Hours',
          value: '${stats.learningHours}',
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileAction extends StatelessWidget {
  const _ProfileAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          title,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
