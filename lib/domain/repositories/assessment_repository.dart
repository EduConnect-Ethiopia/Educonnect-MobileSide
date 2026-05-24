import '../entities/assessment.dart';

abstract class AssessmentRepository {
  Future<List<Assessment>> getUpcomingAssessments(String courseId);
  Future<Assessment?> getAssessment(String assessmentId);
  Future<void> startAssessment(String assessmentId);
  Future<AssessmentResult> submitAssessment(
    String assessmentId,
    Map<String, String> answers,
  );
}
