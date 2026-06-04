import 'package:educonnect_mobile/core/constants/backend_enum_values.dart';
import 'package:educonnect_mobile/data/models/course_models.dart';
import 'package:educonnect_mobile/data/models/session_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('course model parses ApiResponse wrapped backend object', () {
    final course = CourseModel.fromJson({
      'success': true,
      'data': {
        'courseId': 'course-1',
        'title': 'Flutter Basics',
        'description': 'Learn Flutter',
        'category': 'Technology',
        'mode': BackendEnumValues.modeSelfPaced,
        'price': 0,
        'courseStatus': BackendEnumValues.courseStatusPublished,
        'updatedAt': '0001-01-01T00:00:00',
      },
    });

    expect(course.courseId, 'course-1');
    expect(course.mode, BackendEnumValues.modeSelfPaced);
    expect(course.courseStatus, BackendEnumValues.courseStatusPublished);
    expect(course.updatedAt, isNull);
    expect(course.toEntity().isPublished, isTrue);
  });

  test('course model parses instructor-led mode from string values', () {
    final course = CourseModel.fromJson({
      'courseId': 'course-2',
      'title': 'Live Bootcamp',
      'description': 'Instructor-led',
      'category': 'Technology',
      'mode': 'InstructorLed',
      'price': 0,
      'courseStatus': BackendEnumValues.courseStatusPublished,
    });

    expect(course.mode, BackendEnumValues.modeInstructorLed);
    expect(course.toEntity().isInstructorLed, isTrue);
  });

  test('session model parses string status values for live/upcoming cards', () {
    final now = DateTime.now().toUtc();
    final session = CourseSessionModel.fromJson({
      'sessionId': 'session-1',
      'courseId': 'course-2',
      'title': 'Live Zoom Session',
      'startTime': now.subtract(const Duration(minutes: 5)).toIso8601String(),
      'endTime': now.add(const Duration(hours: 1)).toIso8601String(),
      'meetingUrl': 'https://zoom.us/j/123',
      'status': 'Live',
    }).toEntity();

    expect(session.status, 1);
    expect(session.statusText, 'Live Now');
  });

  test('enrollment model parses integer status values', () {
    final enrollment = EnrollmentModel.fromJson({
      'enrollmentId': 'enrollment-1',
      'learnerId': 'learner-1',
      'courseId': 'course-1',
      'enrollmentStatus': BackendEnumValues.enrollmentActive,
      'enrolledAt': '2026-05-12T10:00:00',
    });

    expect(enrollment.courseId, 'course-1');
    expect(enrollment.enrollmentStatus, BackendEnumValues.enrollmentActive);
    expect(enrollment.toEntity().isActive, isTrue);
  });
}
