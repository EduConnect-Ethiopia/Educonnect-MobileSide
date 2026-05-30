import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/app_providers.dart';
import '../../domain/entities/course.dart';

final featuredCoursesProvider = FutureProvider<List<Course>>((ref) async {
  return ref.watch(courseRepositoryProvider).getFeaturedCourses();
});

final featuredCoursesControllerProvider =
    NotifierProvider<FeaturedCoursesController, FeaturedCoursesState>(
  FeaturedCoursesController.new,
);

class FeaturedCoursesController extends Notifier<FeaturedCoursesState> {
  @override
  FeaturedCoursesState build() {
    Future<void>.microtask(loadCourses);
    return FeaturedCoursesState.initial();
  }

  Future<void> loadCourses({String query = ''}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final courses = query.isEmpty
          ? await ref.read(courseRepositoryProvider).getFeaturedCourses()
          : await ref.read(courseRepositoryProvider).searchCourses(query);
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

class FeaturedCoursesState {
  const FeaturedCoursesState({
    required this.isLoading,
    required this.courses,
    this.errorMessage,
  });

  const FeaturedCoursesState.initial()
    : isLoading = false,
      courses = const [],
      errorMessage = null;

  final bool isLoading;
  final List<Course> courses;
  final String? errorMessage;

  FeaturedCoursesState copyWith({
    bool? isLoading,
    List<Course>? courses,
    String? errorMessage,
    bool clearError = false,
  }) {
    return FeaturedCoursesState(
      isLoading: isLoading ?? this.isLoading,
      courses: courses ?? this.courses,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
