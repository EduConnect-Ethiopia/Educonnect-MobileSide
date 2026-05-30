import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../domain/entities/course.dart';
import '../providers/auth_controller.dart';
import '../providers/notification_provider.dart';
import '../providers/profile_provider.dart';
import 'assessments/assessments_list_screen.dart';
import 'auth/login_screen.dart';
import 'certificates/certificate_list_screen.dart';
import 'notifications/notification_screen.dart';
import 'profile/edit_profile_screen.dart';
import 'profile/faq_screen.dart';
import 'profile/settings_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final notificationState = ref.watch(notificationControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            tooltip: 'Notifications',
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
        error: (_, _) => const Center(child: Text('Unable to load profile')),
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('Sign in to view your profile'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _ProfileHeader(profile: profile),
              const SizedBox(height: 16),
              _StatsRow(stats: profile.stats),
              const SizedBox(height: 16),
              _ProfileAction(
                icon: Icons.edit_outlined,
                title: 'Edit Profile',
                subtitle: 'Update phone, bio, and password',
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
                title: 'Help & Support',
                subtitle: 'FAQ and contact support',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const FaqScreen(),
                    ),
                  );
                },
              ),
              _ProfileAction(
                icon: Icons.settings_outlined,
                title: 'Settings',
                subtitle: 'Theme, language, and preferences',
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
                title: 'Certificates',
                subtitle: 'View and download earned certificates',
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
                title: 'Assessments',
                subtitle: 'Take quizzes for enrolled courses',
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
                label: const Text('Sign out'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openAssessments(BuildContext context, WidgetRef ref) async {
    final courses = await ref.read(profileCoursesForAssessmentsProvider.future);
    if (!context.mounted) return;

    if (courses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enroll in a course to take assessments')),
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
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile});

  final LearnerProfile profile;

  @override
  Widget build(BuildContext context) {
    final user = profile.user;
    final initial = user.fullName.trim().isEmpty
        ? 'L'
        : user.fullName.trim().characters.first.toUpperCase();
    final avatarBytes = profile.avatarBytes;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        children: [
          CircleAvatar(
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
          const SizedBox(height: 12),
          Text(
            user.fullName,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(user.email, style: Theme.of(context).textTheme.bodySmall),
          if (profile.bio.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(profile.bio, textAlign: TextAlign.center),
          ],
          if (profile.isVerified) ...[
            const SizedBox(height: 8),
            Chip(
              label: const Text('Verified Learner'),
              backgroundColor: Colors.green.shade100,
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
            Text(label, style: Theme.of(context).textTheme.bodySmall),
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
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
