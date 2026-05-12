class ApiEndpoints {
  ApiEndpoints._();

  static const register = '/api/auth/register';
  static const login = '/api/auth/login';
  static const refreshToken = '/api/auth/refresh-token';
  static const logout = '/api/auth/logout';
  static const forgotPassword = '/api/auth/forgot-password';
  static const resetPassword = '/api/auth/reset-password';

  static const userProfile = '/api/users/profile';
  static const changePassword = '/api/users/change-password';
  static const userProgress = '/api/users/progress';

  static const courses = '/api/courses';
  static const enrolledCourses = '/api/courses/enrolled';
  static const recommendedCourses = '/api/courses/recommended';

  static String course(String id) => '/api/courses/$id';
  static String courseContent(String id) => '/api/courses/$id/content';
  static String courseProgress(String id) => '/api/courses/$id/progress';
  static String enrollCourse(String id) => '/api/courses/$id/enroll';

  static const upcomingAssessments = '/api/assessments/upcoming';
  static String assessment(String id) => '/api/assessments/$id';
  static String submitAssessment(String id) => '/api/assessments/$id/submit';
  static String assessmentResult(String id) => '/api/assessments/$id/result';

  static const certificates = '/api/certificates';
  static String downloadCertificate(String id) =>
      '/api/certificates/$id/download';
  static String verifyCertificate(String code) =>
      '/api/certificates/verify/$code';

  static const notifications = '/api/notifications';
  static String readNotification(String id) => '/api/notifications/$id/read';
  static String notification(String id) => '/api/notifications/$id';
}
