import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/app_providers.dart';
import '../../domain/entities/course.dart';
import '../../domain/entities/enrollment.dart';

final myEnrollmentsProvider = FutureProvider<List<Enrollment>>((ref) async {
  return ref.watch(enrollmentRepositoryProvider).getMyEnrollments();
});

final myCoursesProvider = FutureProvider<List<Course>>((ref) async {
  final enrollments = await ref.watch(myEnrollmentsProvider.future);
  final courses = <Course>[];
  
  for (final enrollment in enrollments) {
    try {
      final course = await ref.read(courseRepositoryProvider).getCourseById(enrollment.courseId);
      courses.add(
        course.copyWith(
          enrolledAt: enrollment.enrolledAt,
          enrollmentId: enrollment.id,
          enrollmentStatus: enrollment.status,
        ),
      );
    } catch (_) {
      // Skip courses that fail to load
    }
  }
  
  return courses;
});

final enrollmentControllerProvider = NotifierProvider<EnrollmentController, EnrollmentState>(
  EnrollmentController.new,
);

class EnrollmentController extends Notifier<EnrollmentState> {
  @override
  EnrollmentState build() {
    return EnrollmentState.initial();
  }

  Future<void> enrollCourse(String courseId) async {
    state = state.copyWith(isEnrolling: true, clearError: true);

    try {
      await ref.read(enrollmentRepositoryProvider).enroll(courseId);
      state = state.copyWith(
        isEnrolling: false,
        successMessage: 'Successfully enrolled in course!',
      );
      
      // Invalidate the enrollments cache
      ref.invalidate(myEnrollmentsProvider);
      ref.invalidate(myCoursesProvider);
    } on Object {
      state = state.copyWith(
        isEnrolling: false,
        errorMessage: 'Failed to enroll. Please try again.',
      );
    }
  }

  Future<void> unenrollCourse(String courseId) async {
    state = state.copyWith(isEnrolling: true, clearError: true);

    try {
      await ref.read(enrollmentRepositoryProvider).unenroll(courseId);
      state = state.copyWith(
        isEnrolling: false,
        successMessage: 'Successfully unenrolled from course.',
      );
      
      // Invalidate the enrollments cache
      ref.invalidate(myEnrollmentsProvider);
      ref.invalidate(myCoursesProvider);
    } on Object {
      state = state.copyWith(
        isEnrolling: false,
        errorMessage: 'Failed to unenroll. Please try again.',
      );
    }
  }

  void clearMessages() {
    state = state.copyWith(
      successMessage: null,
      errorMessage: null,
    );
  }
}

class EnrollmentState {
  const EnrollmentState({
    required this.isEnrolling,
    this.successMessage,
    this.errorMessage,
  });

  const EnrollmentState.initial()
    : isEnrolling = false,
      successMessage = null,
      errorMessage = null;

  final bool isEnrolling;
  final String? successMessage;
  final String? errorMessage;

  EnrollmentState copyWith({
    bool? isEnrolling,
    String? successMessage,
    String? errorMessage,
    bool clearError = false,
  }) {
    return EnrollmentState(
      isEnrolling: isEnrolling ?? this.isEnrolling,
      successMessage: successMessage ?? this.successMessage,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
