import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/di/app_providers.dart';
import '../../../domain/entities/course.dart';
import '../../providers/enrollment_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/course_card.dart';
import 'course_progress_screen.dart';

class MyCoursesScreen extends ConsumerStatefulWidget {
  const MyCoursesScreen({super.key});

  @override
  ConsumerState<MyCoursesScreen> createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends ConsumerState<MyCoursesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myCoursesAsync = ref.watch(myCoursesProvider);
    final progressMapAsync = ref.watch(myCoursesProgressProvider);
    final isAmharic = ref.watch(settingsProvider).language == 'am';

    return Scaffold(
      appBar: AppBar(
        title: Text(isAmharic ? 'የእኔ ኮርሶች' : 'My Courses'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: [
            Tab(text: isAmharic ? 'ሁሉም' : 'All'),
            Tab(text: isAmharic ? 'በሂደት' : 'In Progress'),
            Tab(text: isAmharic ? 'ተጠናቀቀ' : 'Completed'),
            Tab(text: isAmharic ? 'ተተወ' : 'Dropped'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: isAmharic ? 'አድስ' : 'Refresh',
            onPressed: () {
              ref.invalidate(myCoursesProvider);
              ref.invalidate(myCoursesProgressProvider);
            },
            icon: const Icon(Icons.refresh_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(myCoursesProvider);
          ref.invalidate(myCoursesProgressProvider);
          await ref.read(myCoursesProvider.future);
        },
        child: myCoursesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                const Text('Failed to load your courses.'),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => ref.invalidate(myCoursesProvider),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
          data: (courses) {
            final progressMap = progressMapAsync.value ?? {};
            final withProgress = courses.map((c) {
              final p = progressMap[c.id] ?? c.progress;
              return c.copyWith(progress: p);
            }).toList();

            final filtered =
                _filterByTab(withProgress, _tabController.index);

            if (filtered.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: const [_EmptyCoursesState()],
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final course = filtered[index];
                return CourseCard(
                  course: course,
                  showProgress: true,
                  onTap: () => _navigateToCourse(context, course),
                );
              },
            );
          },
        ),
      ),
    );
  }

  List<Course> _filterByTab(List<Course> courses, int tabIndex) {
    switch (tabIndex) {
      case 1:
        return courses.where((c) {
          return !c.isEnrollmentCompleted &&
              !c.isEnrollmentDropped &&
              c.progress < 100;
        }).toList();
      case 2:
        return courses
            .where(
              (c) =>
                  c.isEnrollmentCompleted || c.progress >= 100,
            )
            .toList();
      case 3:
        return courses.where((c) => c.isEnrollmentDropped).toList();
      default:
        return courses;
    }
  }

  void _navigateToCourse(BuildContext context, Course course) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CourseProgressScreen(course: course),
      ),
    );
  }
}

final myCoursesProgressProvider =
    FutureProvider<Map<String, double>>((ref) async {
  final courses = await ref.watch(myCoursesProvider.future);
  final map = <String, double>{};

  for (final course in courses) {
    final enrollmentId = course.enrollmentId;
    if (enrollmentId == null) continue;
    try {
      final content = await ref
          .read(courseRepositoryProvider)
          .getCourseContent(course.id);
      final total = content.modules.fold<int>(
        0,
        (s, m) => s + m.lessons.length,
      );
      final progress = await ref.read(progressRepositoryProvider).getCourseProgress(
            course.id,
            enrollmentId,
            total,
          );
      map[course.id] = progress.percentage;
    } on Object {
      map[course.id] = course.progress;
    }
  }
  return map;
});

class _EmptyCoursesState extends StatelessWidget {
  const _EmptyCoursesState();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF333333)
              : const Color(0xFFE0E0E0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.school_outlined, color: AppColors.secondary, size: 48),
          const SizedBox(height: 16),
          Text(
            'No courses in this tab',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Enroll in courses from Browse to see them here.',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
