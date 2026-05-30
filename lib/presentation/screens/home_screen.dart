import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/di/app_providers.dart';
import '../../domain/entities/course.dart';
import '../providers/recommendation_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/enrollment_provider.dart';
import '../providers/settings_provider.dart';
import '../../domain/entities/auth_session.dart';
import '../screens/course_detail_screen.dart';
import '../widgets/continue_learning_card.dart';
import '../widgets/course_card.dart';
import '../widgets/section_header.dart';

final homeProvider = NotifierProvider<HomeController, HomeState>(
  HomeController.new,
);

class HomeController extends Notifier<HomeState> {
  @override
  HomeState build() {
    Future<void>.microtask(loadData);
    return HomeState.initial();
  }

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final user = await ref.read(authRepositoryProvider).getCurrentUser();
      final inProgressCourses = user == null
          ? const <Course>[]
          : await ref
                .read(courseRepositoryProvider)
                .getActiveCoursesForLearner(user.id);

      List<Course> recommendations = const [];
      try {
        recommendations =
            await ref.read(recommendationRepositoryProvider).getRecommendations();
      } on Object {
        recommendations = const [];
      }

      state = state.copyWith(
        isLoading: false,
        user: user,
        inProgressCourses: inProgressCourses,
        recommendations: recommendations,
        clearError: true,
      );
    } on Object {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to load your courses right now.',
      );
    }
  }
}

class HomeState {
  const HomeState({
    required this.isLoading,
    required this.inProgressCourses,
    required this.recommendations,
    this.user,
    this.errorMessage,
  });

  const HomeState.initial()
    : isLoading = false,
      user = null,
      inProgressCourses = const [],
      recommendations = const [],
      errorMessage = null;

  final bool isLoading;
  final AuthenticatedUser? user;
  final List<Course> inProgressCourses;
  final List<Course> recommendations;
  final String? errorMessage;

  HomeState copyWith({
    bool? isLoading,
    AuthenticatedUser? user,
    List<Course>? inProgressCourses,
    List<Course>? recommendations,
    String? errorMessage,
    bool clearError = false,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      inProgressCourses: inProgressCourses ?? this.inProgressCourses,
      recommendations: recommendations ?? this.recommendations,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);
    final isAmharic = ref.watch(settingsProvider).language == 'am';
    final myCourses = ref.watch(myCoursesProvider).value ?? const <Course>[];
    final ownedCourseIds = myCourses.map((course) => course.id).toSet();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.read(homeProvider.notifier).loadData(),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: Text(isAmharic ? 'ቤት' : 'Home'),
              floating: true,
              actions: [
                IconButton(
                  tooltip: isAmharic ? 'አድስ' : 'Refresh',
                  onPressed: homeState.isLoading
                      ? null
                      : () => ref.read(homeProvider.notifier).loadData(),
                  icon: const Icon(Icons.refresh_outlined),
                ),
              ],
            ),
            if (homeState.errorMessage != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: _InfoBanner(message: homeState.errorMessage!),
                ),
              ),
            if (homeState.isLoading && homeState.inProgressCourses.isEmpty)
              const SliverToBoxAdapter(child: LinearProgressIndicator()),
            if (homeState.inProgressCourses.isNotEmpty)
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(title: isAmharic ? 'ቀጥሎ ይማሩ' : 'Continue Learning'),
                    SizedBox(
                      height: 190,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(right: 12),
                        itemCount: homeState.inProgressCourses.length,
                        itemBuilder: (context, index) {
                          return ContinueLearningCard(
                            course: homeState.inProgressCourses[index],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              )
            else if (!homeState.isLoading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: _EmptyLearningState(),
                ),
              ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(title: isAmharic ? 'ለእርስዎ የተመከሩ' : 'Recommended for You'),
                  ...homeState.recommendations.map(
                    (course) {
                      final isOwned = ownedCourseIds.contains(course.id) ||
                          course.enrollmentId != null;
                      return CourseCard(
                        course: course,
                        onTap: () {
                          ref
                              .read(recommendationControllerProvider)
                              .trackView(course.id, category: course.category);
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => CourseDetailScreen(course: course),
                            ),
                          );
                        },
                        showActionButton: !isOwned,
                        actionLabel: 'Buy',
                        onActionPressed: () {
                          ref.read(cartControllerProvider.notifier).addToCart(course);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isAmharic
                                    ? 'ኮርሱ ወደ ካርት ታክሏል'
                                    : 'Course added to cart',
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _firstName(String? fullName) {
    final trimmed = fullName?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return 'Learner';
    }

    return trimmed.split(RegExp(r'\s+')).first;
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.accentAmber.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.textHeadline),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}

class _EmptyLearningState extends StatelessWidget {
  const _EmptyLearningState();

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
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.menu_book_outlined,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No active courses yet',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Explore recommended courses to start your learning journey.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
