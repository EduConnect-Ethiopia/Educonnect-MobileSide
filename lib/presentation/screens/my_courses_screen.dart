import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../widgets/course_card.dart';
import 'home_screen.dart';

class MyCoursesScreen extends ConsumerWidget {
  const MyCoursesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Courses'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: homeState.isLoading
                ? null
                : () => ref.read(homeProvider.notifier).loadData(),
            icon: const Icon(Icons.refresh_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(homeProvider.notifier).loadData(),
        child: homeState.inProgressCourses.isEmpty
            ? ListView(
                padding: const EdgeInsets.all(16),
                children: const [_EmptyCoursesState()],
              )
            : ListView.builder(
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: homeState.inProgressCourses.length,
                itemBuilder: (context, index) {
                  return CourseCard(
                    course: homeState.inProgressCourses[index],
                    showProgress: true,
                  );
                },
              ),
      ),
    );
  }
}

class _EmptyCoursesState extends StatelessWidget {
  const _EmptyCoursesState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.school_outlined,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Your course list is empty',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textHeadline,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Enrolled courses will appear here after the backend returns active learner enrollments.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
