import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/app_providers.dart';
import '../../domain/entities/course.dart';

final featuredCoursesProvider = FutureProvider<List<Course>>((ref) async {
  return ref.watch(courseRepositoryProvider).getPublishedCourses();
});

final publishedCoursesControllerProvider =
    NotifierProvider<PublishedCoursesController, FeaturedCoursesState>(
  PublishedCoursesController.new,
);

class PublishedCoursesController extends Notifier<FeaturedCoursesState> {
  int _requestId = 0;

  @override
  FeaturedCoursesState build() {
    Future<void>.microtask(loadCourses);
    return FeaturedCoursesState.initial();
  }

  Future<void> loadCourses({String query = ''}) async {
    final currentRequestId = ++_requestId;
    state = state.copyWith(isLoading: true, query: query, clearError: true);

    try {
      final repository = ref.read(courseRepositoryProvider);
      final courses = query.trim().isEmpty
          ? await repository.getPublishedCourses()
          : await repository.searchCourses(query);

      if (currentRequestId != _requestId) return;

      state = state.copyWith(
        isLoading: false,
        query: query,
        courses: courses,
        clearError: true,
      );
    } on Object {
      if (currentRequestId != _requestId) return;

      state = state.copyWith(
        isLoading: false,
        query: query,
        errorMessage: 'Failed to load courses. Please try again.',
      );
    }
  }
}

class FeaturedCoursesState {
  const FeaturedCoursesState({
    required this.isLoading,
    required this.query,
    required this.courses,
    this.errorMessage,
  });

  const FeaturedCoursesState.initial()
    : isLoading = false,
      query = '',
      courses = const [],
      errorMessage = null;

  final bool isLoading;
  final String query;
  final List<Course> courses;
  final String? errorMessage;

  FeaturedCoursesState copyWith({
    bool? isLoading,
    String? query,
    List<Course>? courses,
    String? errorMessage,
    bool clearError = false,
  }) {
    return FeaturedCoursesState(
      isLoading: isLoading ?? this.isLoading,
      query: query ?? this.query,
      courses: courses ?? this.courses,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
