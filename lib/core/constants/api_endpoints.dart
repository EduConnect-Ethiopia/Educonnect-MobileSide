class ApiEndpoints {
  ApiEndpoints._();

  static const baseUrl = 'http://10.0.2.2:5001';
  
  // Auth endpoints
  static const signup = '/api/Auth/signup';
  static const register = signup;
  static const login = '/api/Auth/login';
  static const forgotPassword = '/api/Auth/forgot-password';
  static const verifyResetCode = '/api/Auth/verify-reset-code';
  static const resetPassword = '/api/Auth/reset-password';

  // Course endpoints
  static const publishedCourses = '/api/Course/published';
  static String course(String courseId) => '/api/Course/$courseId';
  static String courseContent(String courseId) => '/api/Course/$courseId/content';
  static String courseModules(String courseId) =>
      '/api/Course/$courseId/modules';
  static String moduleLessons(String moduleId) =>
      '/api/Course/$moduleId/lessons';
  static String lessonMaterials(String lessonId) =>
      '/api/Course/$lessonId/materials';

  // Enrollment endpoints
  static const enroll = '/api/Enrollment/enroll';
  static const unenroll = '/api/Enrollment/unenroll';
  static const myEnrollments = '/api/Enrollment/me';
  static String learnerEnrollments(String userId) =>
      '/api/Enrollment/learner/$userId';

  // Session endpoints
  static String courseSessions(String courseId) =>
      '/api/CourseSession/$courseId';
}
