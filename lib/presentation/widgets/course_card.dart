import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../domain/entities/course.dart';

class CourseCard extends StatelessWidget {
  const CourseCard({
    required this.course,
    this.showProgress = false,
    this.onTap,
    this.showActionButton = false,
    this.actionLabel,
    this.onActionPressed,
    super.key,
  });

  final Course course;
  final bool showProgress;
  final VoidCallback? onTap;
  final bool showActionButton;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    final progress = (course.progress / 100).clamp(0.0, 1.0).toDouble();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap ?? () => _showComingSoon(context),
        child: SizedBox(
          height: 124,
          child: Row(
            children: [
              _CourseThumbnail(course: course),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        course.instructor,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          _PriceBadge(course: course),
                          if (showProgress) ...[
                            const SizedBox(width: 10),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  minHeight: 6,
                                  value: progress,
                                  backgroundColor: const Color(0xFFE8EEF2),
                                ),
                              ),
                            ),
                          ],
                          if (showActionButton) ...[
                            const Spacer(),
                            TextButton(
                              onPressed: onActionPressed,
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                minimumSize: const Size(0, 30),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ),
                              child: Text(
                                actionLabel ?? (course.isFree ? 'Enroll' : 'Buy'),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Course details are coming soon.')),
    );
  }
}

class _CourseThumbnail extends StatelessWidget {
  const _CourseThumbnail({required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    final thumbnailUrl = course.thumbnailUrl;

    return Container(
      width: 108,
      height: double.infinity,
      color: AppColors.primary.withValues(alpha: 0.12),
      child: thumbnailUrl == null || thumbnailUrl.isEmpty
          ? const Icon(
              Icons.school_outlined,
              size: 40,
              color: AppColors.primary,
            )
          : CachedNetworkImage(
              imageUrl: thumbnailUrl,
              fit: BoxFit.cover,
              errorWidget: (_, _, _) => const Icon(
                Icons.school_outlined,
                size: 40,
                color: AppColors.primary,
              ),
            ),
    );
  }
}

class _PriceBadge extends StatelessWidget {
  const _PriceBadge({required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    if (course.isFree) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.secondary.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Free',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColors.secondary,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }

    final price = course.price.truncateToDouble() == course.price
        ? course.price.toStringAsFixed(0)
        : course.price.toStringAsFixed(2);

    return Text(
      '$price ETB',
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: Theme.of(context).colorScheme.onSurface,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}
