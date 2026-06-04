import '../entities/assessment.dart';

abstract class AssessmentRepository {
  Future<List<Assessment>> getUpcomingAssessments(String courseId);
  Future<Assessment?> getAssessment(String assessmentId);
  Future<DateTime?> startAssessment(String assessmentId);
  Future<AssessmentResult> submitAssessment(
    String assessmentId,
    Map<String, String> answers,
  );
  Future<void> submitAssignment({
    required String assessmentId,
    required String filePath,
    String content,
  });
}
