import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/app_providers.dart';
import '../../domain/entities/course.dart';

final publishedCoursesProvider = FutureProvider<List<Course>>((ref) async {
  return ref.watch(courseRepositoryProvider).getPublishedCourses();
});

final publishedCoursesControllerProvider =
    NotifierProvider<PublishedCoursesController, PublishedCoursesState>(
  PublishedCoursesController.new,
);

class PublishedCoursesController extends Notifier<PublishedCoursesState> {
  int _requestId = 0;

  @override
  PublishedCoursesState build() {
    Future<void>.microtask(loadCourses);
    return PublishedCoursesState.initial();
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

class PublishedCoursesState {
  const PublishedCoursesState({
    required this.isLoading,
    required this.query,
    required this.courses,
    this.errorMessage,
  });

  const PublishedCoursesState.initial()
    : isLoading = false,
      query = '',
      courses = const [],
      errorMessage = null;

  final bool isLoading;
  final String query;
  final List<Course> courses;
  final String? errorMessage;

  PublishedCoursesState copyWith({
    bool? isLoading,
    String? query,
    List<Course>? courses,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PublishedCoursesState(
      isLoading: isLoading ?? this.isLoading,
      query: query ?? this.query,
      courses: courses ?? this.courses,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
