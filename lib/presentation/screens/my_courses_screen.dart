import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../providers/enrollment_provider.dart';
import '../widgets/course_card.dart';

class MyCoursesScreen extends ConsumerWidget {
  const MyCoursesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myCoursesAsync = ref.watch(myCoursesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Courses'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(myCoursesProvider),
            icon: const Icon(Icons.refresh_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () {
          ref.invalidate(myCoursesProvider);
          return ref.watch(myCoursesProvider.future);
        },
        child: myCoursesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Failed to load your courses.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => ref.invalidate(myCoursesProvider),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
          data: (courses) => courses.isEmpty
              ? ListView(
                  padding: const EdgeInsets.all(16),
                  children: const [_EmptyCoursesState()],
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    return CourseCard(
                      course: courses[index],
                      showProgress: true,
                      onTap: () => _navigateToCourseContent(
                        context,
                        courses[index].id,
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  void _navigateToCourseContent(BuildContext context, String courseId) {
    // TODO: Navigate to course content/player screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Course content coming soon...')),
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
