import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../domain/entities/course_content.dart';
import '../../domain/entities/lesson_play_type.dart';

class CourseNavigationDrawer extends StatelessWidget {
  const CourseNavigationDrawer({
    required this.content,
    required this.currentLessonId,
    required this.onLessonSelected,
    required this.isLessonCompleted,
    super.key,
  });

  final CourseContent content;
  final String currentLessonId;
  final void Function(Lesson lesson) onLessonSelected;
  final bool Function(String lessonId) isLessonCompleted;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                content.course.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: content.modules.length,
              itemBuilder: (context, moduleIndex) {
                final module = content.modules[moduleIndex];
                return ExpansionTile(
                  title: Text(module.title),
                  initiallyExpanded: _isModuleActive(module),
                  children: module.lessons.map((lesson) {
                    final completed = isLessonCompleted(lesson.id);
                    return ListTile(
                      leading: Icon(_iconForType(lesson.playType), size: 20),
                      title: Text(
                        lesson.title,
                        style: TextStyle(
                          fontWeight: lesson.id == currentLessonId
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      trailing: completed
                          ? const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            )
                          : null,
                      selected: lesson.id == currentLessonId,
                      onTap: () {
                        Navigator.pop(context);
                        onLessonSelected(lesson);
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  bool _isModuleActive(Module module) {
    return module.lessons.any((l) => l.id == currentLessonId);
  }

  IconData _iconForType(LessonPlayType type) {
    switch (type) {
      case LessonPlayType.video:
        return Icons.play_circle_outline;
      case LessonPlayType.article:
        return Icons.article_outlined;
      case LessonPlayType.quiz:
        return Icons.quiz_outlined;
      case LessonPlayType.assignment:
        return Icons.assignment_outlined;
      case LessonPlayType.live:
        return Icons.video_call_outlined;
      case LessonPlayType.unknown:
        return Icons.menu_book_outlined;
    }
  }
}
