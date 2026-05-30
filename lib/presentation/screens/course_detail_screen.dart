import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';
import '../../domain/entities/course.dart';
import '../../domain/entities/course_content.dart';
import '../../domain/entities/course_session.dart';
import '../providers/cart_provider.dart';
import '../providers/course_detail_provider.dart';
import '../providers/enrollment_provider.dart';
import 'courses/course_player_screen.dart';

class CourseDetailScreen extends ConsumerWidget {
  const CourseDetailScreen({required this.course, super.key});

  final Course course;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentAsync = ref.watch(courseContentAsyncProvider(course.id));
    final sessionsAsync = ref.watch(courseSessionsAsyncProvider(course.id));
    final enrollmentState = ref.watch(enrollmentControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(course.title),
      ),
      body: contentAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Failed to load course content.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => ref.invalidate(courseContentAsyncProvider(course.id)),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
        data: (content) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course Header
              _CourseHeader(course: course),

              Padding(
                padding: const EdgeInsets.all(16),
                child: _CourseActions(
                  course: course,
                  enrollmentState: enrollmentState,
                ),
              ),

              // Syllabus Section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Course Content',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    if (content.modules.isEmpty)
                      Text(
                        'No modules available yet.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      )
                    else
                      ...content.modules.map((module) {
                        return _ModuleListTile(
                          module: module,
                          course: course,
                          content: content,
                        );
                      }),
                  ],
                ),
              ),

              // Live Sessions Section
              sessionsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    height: 40,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
                error: (error, stackTrace) => const SizedBox.shrink(),
                data: (sessions) {
                  if (course.isInstructorLed && sessions.isNotEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Upcoming Sessions',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          ...sessions.map((session) {
                            return _SessionCard(session: session);
                          }),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

}

class _CourseActions extends ConsumerWidget {
  const _CourseActions({
    required this.course,
    required this.enrollmentState,
  });

  final Course course;
  final EnrollmentState enrollmentState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (course.enrollmentId != null) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            final content = ref.read(courseContentAsyncProvider(course.id)).value;
            if (content != null && content.modules.isNotEmpty && content.modules.first.lessons.isNotEmpty) {
              final lesson = content.modules.first.lessons.first;
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => CoursePlayerScreen(
                    course: course,
                    enrollmentId: course.enrollmentId ?? 'local',
                    initialLesson: lesson,
                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Select a lesson below to resume learning.')),
              );
            }
          },
          icon: const Icon(Icons.play_circle_fill),
          label: const Text('Continue Learning'),
        ),
      );
    }

    return Column(
      children: [
        if (!course.isFree) ...[
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                await ref.read(cartControllerProvider.notifier).addToCart(course);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Added to cart')),
                );
              },
              icon: const Icon(Icons.shopping_cart_outlined),
              label: const Text('Add to Cart'),
            ),
          ),
          const SizedBox(height: 8),
        ],
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: enrollmentState.isEnrolling
                ? null
                : () async {
                    if (course.price > 0 && !course.isFree) {
                      await ref
                          .read(cartControllerProvider.notifier)
                          .addToCart(course);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Added to cart — proceed to checkout'),
                        ),
                      );
                      return;
                    }
                    await ref
                        .read(enrollmentControllerProvider.notifier)
                        .enrollCourse(course.id);
                    if (!context.mounted) return;
                    final msg = ref.read(enrollmentControllerProvider).successMessage;
                    if (msg != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(msg)),
                      );
                    }
                  },
            icon: enrollmentState.isEnrolling
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add_circle_outline),
            label: Text(course.isFree ? 'Enroll Free' : 'Buy / Enroll'),
          ),
        ),
      ],
    );
  }
}

class _CourseHeader extends StatelessWidget {
  const _CourseHeader({required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.08),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            course.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            course.category,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSubtitle,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Instructor: ${course.instructor}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSubtitle,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            course.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _ModuleListTile extends StatefulWidget {
  const _ModuleListTile({
    required this.module,
    required this.course,
    required this.content,
  });

  final Module module;
  final Course course;
  final CourseContent content;

  @override
  State<_ModuleListTile> createState() => _ModuleListTileState();
}

class _ModuleListTileState extends State<_ModuleListTile> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(
          widget.module.title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          '${widget.module.lessons.length} lessons',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSubtitle,
          ),
        ),
        children: [
          ...widget.module.lessons.map((lesson) {
            return ListTile(
              dense: true,
              title: Text(lesson.title),
              subtitle: Text('${lesson.materials.length} materials'),
              trailing: const Icon(Icons.play_circle_outline, size: 20),
              onTap: () {
                final enrollmentId = widget.course.enrollmentId ?? 'local';
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => CoursePlayerScreen(
                      course: widget.course,
                      enrollmentId: enrollmentId,
                      initialLesson: lesson,
                    ),
                  ),
                );
              },
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session});

  final CourseSession session;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    session.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(session).withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    session.statusText,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: _statusColor(session),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Starts: ${_formatDateTime(session.startTime)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSubtitle,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Ends: ${_formatDateTime(session.endTime)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSubtitle,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async => _openMeetingUrl(session.meetingUrl),
                icon: const Icon(Icons.video_call_outlined, size: 18),
                label: const Text('Join Session'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(CourseSession session) {
    if (session.isLive) return Colors.green;
    if (session.isUpcoming) return AppColors.primary;
    if (session.isCancelled) return Colors.red;
    return AppColors.textSubtitle;
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _openMeetingUrl(String meetingUrl) async {
    if (meetingUrl.isEmpty) return;
    final uri = Uri.parse(meetingUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
