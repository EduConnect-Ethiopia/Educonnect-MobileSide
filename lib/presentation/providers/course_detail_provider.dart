import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/app_providers.dart';
import '../../domain/entities/course_content.dart';
import '../../domain/entities/course_session.dart';

final courseContentAsyncProvider = FutureProvider.family<CourseContent, String>((ref, courseId) async {
  return ref.watch(courseRepositoryProvider).getCourseContent(courseId);
});

final courseSessionsAsyncProvider = FutureProvider.family<List<CourseSession>, String>((ref, courseId) async {
  return ref.watch(courseRepositoryProvider).getCourseSessions(courseId);
});

class CourseDetailState {
  const CourseDetailState({
    required this.isLoading,
    this.content,
    this.sessions = const [],
    this.selectedLesson,
    this.selectedMaterial,
    this.errorMessage,
  });

  const CourseDetailState.initial()
    : isLoading = false,
      content = null,
      sessions = const [],
      selectedLesson = null,
      selectedMaterial = null,
      errorMessage = null;

  final bool isLoading;
  final CourseContent? content;
  final List<CourseSession> sessions;
  final Lesson? selectedLesson;
  final Material? selectedMaterial;
  final String? errorMessage;

  CourseDetailState copyWith({
    bool? isLoading,
    CourseContent? content,
    List<CourseSession>? sessions,
    Lesson? selectedLesson,
    Material? selectedMaterial,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CourseDetailState(
      isLoading: isLoading ?? this.isLoading,
      content: content ?? this.content,
      sessions: sessions ?? this.sessions,
      selectedLesson: selectedLesson ?? this.selectedLesson,
      selectedMaterial: selectedMaterial ?? this.selectedMaterial,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
