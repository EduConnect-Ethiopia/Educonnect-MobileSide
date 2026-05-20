import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../domain/entities/course.dart';
import '../../domain/entities/course_content.dart';
import '../../domain/entities/course_session.dart';
import '../providers/course_detail_provider.dart';
import '../providers/enrollment_provider.dart';

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

              // Enrollment Button
              Padding(
                padding: const EdgeInsets.all(16),
                child: _EnrollButton(
                  course: course,
                  onEnroll: () => _handleEnrollment(context, enrollmentState),
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
                    ...content.modules.map((module) {
                      return _ModuleListTile(module: module);
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

  void _handleEnrollment(
    BuildContext context,
    EnrollmentState enrollmentState,
  ) {
    if (course.price > 0) {
      _showEnrollmentDialog(context);
    } else {
      _performEnroll();
    }
  }

  void _showEnrollmentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Enroll in Course'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Course: ${course.title}'),
            const SizedBox(height: 8),
            Text(
              'Price: ${course.price.toStringAsFixed(0)} ETB',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Payment integration coming soon. For now, click "Proceed" to mock enrollment.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _performEnroll();
            },
            child: const Text('Proceed'),
          ),
        ],
      ),
    );
  }

  void _performEnroll() {
    // Enrollment will be handled by the provider
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

class _EnrollButton extends StatelessWidget {
  const _EnrollButton({
    required this.course,
    required this.onEnroll,
  });

  final Course course;
  final VoidCallback onEnroll;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onEnroll,
        icon: const Icon(Icons.add_circle_outline),
        label: const Text('Enroll Now'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}

class _ModuleListTile extends StatefulWidget {
  const _ModuleListTile({required this.module});

  final Module module;

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
            return Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${lesson.materials.length} materials',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textSubtitle,
                    ),
                  ),
                ],
              ),
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
                onPressed: () => _openMeetingUrl(session.meetingUrl),
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

  void _openMeetingUrl(String meetingUrl) {
    if (meetingUrl.isEmpty) {
      return;
    }
    // For now, show the URL. Later integrate with url_launcher package
    // final url = Uri.parse(meetingUrl);
    // if (await canLaunchUrl(url)) {
    //   await launchUrl(url, mode: LaunchMode.externalApplication);
    // }
  }
}
