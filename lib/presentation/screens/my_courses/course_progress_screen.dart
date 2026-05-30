import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/course.dart';
import '../../../domain/entities/assessment.dart';
import '../../../domain/entities/course_content.dart';
import '../../providers/assessment_provider.dart';
import '../../providers/course_detail_provider.dart';
import '../../providers/progress_provider.dart';
import '../assessments/assessment_player_screen.dart';
import '../certificates/certificate_list_screen.dart';
import '../assessments/assignment_submission_screen.dart';
import '../courses/course_player_screen.dart';

class CourseProgressScreen extends ConsumerStatefulWidget {
  const CourseProgressScreen({
    required this.course,
    super.key,
  });

  final Course course;

  @override
  ConsumerState<CourseProgressScreen> createState() =>
      _CourseProgressScreenState();
}

class _CourseProgressScreenState extends ConsumerState<CourseProgressScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final enrollmentId = widget.course.enrollmentId;
    if (enrollmentId == null) return;

    final content = await ref.read(
      courseContentAsyncProvider(widget.course.id).future,
    );
    await ref
        .read(progressControllerProvider.notifier)
        .loadCourseProgress(
          courseId: widget.course.id,
          enrollmentId: enrollmentId,
          content: content,
        );
    await ref.read(progressControllerProvider.notifier).loadLearningStreak();
  }

  @override
  Widget build(BuildContext context) {
    final enrollmentId = widget.course.enrollmentId ?? '';
    final progress =
        ref.watch(progressControllerProvider);
    final contentAsync =
        ref.watch(courseContentAsyncProvider(widget.course.id));
    final assessmentsAsync =
        ref.watch(upcomingAssessmentsProvider(widget.course.id));

    return Scaffold(
      appBar: AppBar(title: Text(widget.course.title)),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildProgressHeader(progress),
            const SizedBox(height: 16),
            _buildStatsCards(progress),
            const SizedBox(height: 16),
            contentAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (_, _) => const SizedBox.shrink(),
              data: (content) =>
                  _buildModuleProgress(content, progress, enrollmentId),
            ),
            const SizedBox(height: 16),
            assessmentsAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
              data: (assessments) => _buildUpcomingAssessments(assessments),
            ),
            if (progress.overallProgress >= 100) ...[
              const SizedBox(height: 16),
              _buildCertificateButton(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressHeader(ProgressState progress) {
    final value = (progress.overallProgress / 100).clamp(0.0, 1.0);
    return Column(
      children: [
        SizedBox(
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(
                  value: value.toDouble(),
                  strokeWidth: 8,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${progress.overallProgress.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text('Complete'),
                ],
              ),
            ],
          ),
        ),
        LinearProgressIndicator(value: value.toDouble()),
        const SizedBox(height: 8),
        Text(
          '${progress.completedLessons}/${progress.totalLessons} lessons completed',
        ),
      ],
    );
  }

  Widget _buildStatsCards(ProgressState progress) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Streak',
            value: '${progress.learningStreak} days',
            icon: Icons.local_fire_department,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Time spent',
            value: '${progress.timeSpentMinutes} min',
            icon: Icons.timer_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildModuleProgress(
    CourseContent content,
    ProgressState progress,
    String enrollmentId,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Module progress',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        ...content.modules.map((module) {
          final total = module.lessons.length;
          final completed = module.lessons
              .where((l) => progress.isLessonCompleted(l.id))
              .length;
          final moduleProgress = total == 0 ? 0.0 : completed / total;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(module.title),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: moduleProgress),
                  const SizedBox(height: 4),
                  Text('$completed / $total lessons'),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.play_arrow),
                onPressed: module.lessons.isEmpty
                    ? null
                    : () => _openFirstIncomplete(
                          content,
                          module,
                          progress,
                          enrollmentId,
                        ),
              ),
            ),
          );
        }),
      ],
    );
  }

  void _openFirstIncomplete(
    CourseContent content,
    Module module,
    ProgressState progress,
    String enrollmentId,
  ) {
    final lesson = module.lessons.firstWhere(
      (l) => !progress.isLessonCompleted(l.id),
      orElse: () => module.lessons.first,
    );
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CoursePlayerScreen(
          course: widget.course,
          enrollmentId: enrollmentId,
          initialLesson: lesson,
        ),
      ),
    );
  }

  Widget _buildUpcomingAssessments(List<Assessment> assessments) {
    if (assessments.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upcoming assessments',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ...assessments.map(
          (a) => Card(
            child: ListTile(
              leading: const Icon(Icons.quiz, color: AppColors.primary),
              title: Text(a.title),
              subtitle: Text(
                a.dueDate != null
                    ? 'Due: ${a.dueDate!.day}/${a.dueDate!.month}/${a.dueDate!.year}'
                    : 'No due date',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => a.isAssignment
                        ? AssignmentSubmissionScreen(assessment: a)
                        : AssessmentPlayerScreen(assessment: a),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCertificateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const CertificateListScreen(),
            ),
          );
        },
        icon: const Icon(Icons.workspace_premium),
        label: const Text('View Certificate'),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.titleMedium),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
