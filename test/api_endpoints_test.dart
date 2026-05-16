import 'package:educonnect_mobile/core/constants/api_endpoints.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uses documented backend endpoint casing and paths', () {
    expect(ApiEndpoints.signup, '/api/Auth/signup');
    expect(ApiEndpoints.login, '/api/Auth/login');
    expect(ApiEndpoints.course('course-1'), '/api/Course/course-1');
    expect(
      ApiEndpoints.courseModules('course-1'),
      '/api/Course/course-1/modules',
    );
    expect(
      ApiEndpoints.moduleLessons('module-1'),
      '/api/Course/module-1/lessons',
    );
    expect(
      ApiEndpoints.lessonMaterials('lesson-1'),
      '/api/Course/lesson-1/materials',
    );
    expect(ApiEndpoints.enroll, '/api/Enrollment/enroll');
    expect(ApiEndpoints.unenroll, '/api/Enrollment/unenroll');
    expect(
      ApiEndpoints.learnerEnrollments('user-1'),
      '/api/Enrollment/learner/user-1',
    );
    expect(
      ApiEndpoints.courseSessions('course-1'),
      '/api/CourseSession/course-1',
    );
  });
}
