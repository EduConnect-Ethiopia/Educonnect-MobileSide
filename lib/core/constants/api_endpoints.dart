class ApiEndpoints {
  ApiEndpoints._();

  // ==================== AUTH ====================
  static const signup = '/api/Auth/signup';
  static const register = signup;
  static const login = '/api/Auth/login';
  static const forgotPassword = '/api/Auth/forgot-password';
  static const resetPassword = '/api/Auth/reset-password';
  static const requestEmailVerification = '/api/Auth/verify/request';
  static const confirmEmailVerification = '/api/Auth/verify/confirm';
  static const resendEmailVerification = '/api/Auth/verify/resend';

  // ==================== USERS ====================
  static const currentUser = '/api/Users/me';

  // ==================== COURSE ====================
  static const featuredCourses = '/api/Course/featured';
  static const courseSearch = '/api/Course/search';
  static String course(String courseId) => '/api/Course/$courseId';
  static String courseContent(String courseId) => '/api/Course/$courseId/content';
  static String courseModules(String courseId) => '/api/Course/$courseId/modules';
  static String moduleLessons(String moduleId) => '/api/Course/$moduleId/lessons';
  static String lessonMaterials(String lessonId) => '/api/Course/$lessonId/materials';
  static String materialAccess(String materialId) => '/api/files/materials/$materialId/access';

  // ==================== ENROLLMENT ====================
  static const enroll = '/api/Enrollment/enroll';
  static const unenroll = '/api/Enrollment/unenroll';
  static const myEnrollments = '/api/Enrollment/my';
  static String learnerEnrollments(String userId) => '/api/Enrollment/learner/$userId';

  // ==================== SESSIONS ====================
  static String courseSessions(String courseId) => '/api/CourseSession/$courseId';

  // ==================== PROGRESS ====================
  static String courseProgress(String courseId) => '/api/Progress/$courseId';
  static const markLessonComplete = '/api/Progress/complete';

  // ==================== PAYMENT ====================
  static const paymentInitiate = '/api/Payment/initiate';
  static String payment(String paymentId) => '/api/Payment/$paymentId';
  static String paymentComplete(String paymentId) => '/api/Payment/$paymentId/complete';

  // ==================== CERTIFICATES ====================
  static const certificates = '/api/Certificate/my';
  static String certificate(String id) => '/api/Certificate/$id';
  static String certificateDownload(String id) => '/api/Certificate/$id/download';
  static String certificateEligibility(String courseId) => '/api/Certificate/eligibility/$courseId';
  static String certificateIssue(String courseId) => '/api/Certificate/issue/$courseId';

  // ==================== ASSESSMENTS & SUBMISSIONS ====================
  static const assessments = '/api/Assessment';
  static String assessmentsByCourse(String courseId) => '/api/Assessment/course/$courseId';
  static String assessment(String id) => '/api/Assessment/$id';
  static String assessmentQuestions(String id) => '/api/Assessment/$id/questions';
  static const learnerSubmissions = '/api/Submission/learner';
  static String startAssessment(String assessmentId) => '/api/Submission/start/$assessmentId';
  static const submitAssessment = '/api/Submission/submit';

  // ==================== NOTIFICATIONS ====================
  static const notifications = '/api/Notification';
  static String notificationRead(String id) => '/api/Notification/$id/read';
  static const notificationsReadAll = '/api/Notification/read-all';

  // ==================== RECOMMENDATIONS ====================
  static const recommendations = '/api/Recommendation';
  static const trackRecommendation = '/api/Recommendation/track';
}