import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../domain/entities/course.dart';
import '../screens/course_detail_screen.dart';

class ContinueLearningCard extends StatelessWidget {
  const ContinueLearningCard({required this.course, this.onTap, super.key});

  final Course course;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final progress = (course.progress / 100).clamp(0.0, 1.0).toDouble();

    return SizedBox(
      width: 260,
      child: Card(
        margin: const EdgeInsets.only(left: 16, right: 4, bottom: 8),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap ??
              () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => CourseDetailScreen(course: course),
                  ),
                );
              },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.play_lesson_outlined,
                    color: AppColors.primary,
                  ),
                ),
                const Spacer(),
                Text(
                  course.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    minHeight: 7,
                    value: progress,
                    backgroundColor: const Color(0xFFE8EEF2),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${course.progress.toStringAsFixed(0)}% complete',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
