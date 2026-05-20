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
  @override
  PublishedCoursesState build() {
    Future<void>.microtask(loadCourses);
    return PublishedCoursesState.initial();
  }

  Future<void> loadCourses() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final courses = await ref.read(courseRepositoryProvider).getPublishedCourses();
      state = state.copyWith(
        isLoading: false,
        courses: courses,
        clearError: true,
      );
    } on Object {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load courses. Please try again.',
      );
    }
  }
}

class PublishedCoursesState {
  const PublishedCoursesState({
    required this.isLoading,
    required this.courses,
    this.errorMessage,
  });

  const PublishedCoursesState.initial()
    : isLoading = false,
      courses = const [],
      errorMessage = null;

  final bool isLoading;
  final List<Course> courses;
  final String? errorMessage;

  PublishedCoursesState copyWith({
    bool? isLoading,
    List<Course>? courses,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PublishedCoursesState(
      isLoading: isLoading ?? this.isLoading,
      courses: courses ?? this.courses,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
