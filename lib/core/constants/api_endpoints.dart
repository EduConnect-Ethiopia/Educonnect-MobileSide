class ApiEndpoints {
  ApiEndpoints._();

  static const signup = '/api/Auth/signup';
  static const register = signup;
  static const login = '/api/Auth/login';

  static String course(String courseId) => '/api/Course/$courseId';
  static String courseModules(String courseId) =>
      '/api/Course/$courseId/modules';
  static String moduleLessons(String moduleId) =>
      '/api/Course/$moduleId/lessons';
  static String lessonMaterials(String lessonId) =>
      '/api/Course/$lessonId/materials';

  static const enroll = '/api/Enrollment/enroll';
  static const unenroll = '/api/Enrollment/unenroll';
  static String learnerEnrollments(String userId) =>
      '/api/Enrollment/learner/$userId';

  static String courseSessions(String courseId) =>
      '/api/CourseSession/$courseId';
}
