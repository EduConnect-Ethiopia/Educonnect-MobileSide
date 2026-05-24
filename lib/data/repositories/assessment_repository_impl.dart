import '../../domain/entities/assessment.dart';
import '../../domain/repositories/assessment_repository.dart';
import '../datasources/remote/assessment_remote_data_source.dart';

class AssessmentRepositoryImpl implements AssessmentRepository {
  AssessmentRepositoryImpl(this._remote);

  final AssessmentRemoteDataSource _remote;

  @override
  Future<List<Assessment>> getUpcomingAssessments(String courseId) async {
    final summaries = await _remote.getAssessmentsByCourse(courseId);
    final assessments = <Assessment>[];

    for (final summary in summaries) {
      try {
        final questions = await _remote.getQuestions(summary.assessmentId);
        assessments.add(
          summary.toEntity(
            questions: questions.map((q) => q.toEntity()).toList(),
          ),
        );
      } on Object {
        assessments.add(summary.toEntity());
      }
    }

    return assessments;
  }

  @override
  Future<Assessment?> getAssessment(String assessmentId) async {
    final summary = await _remote.getAssessment(assessmentId);
    if (summary == null) return null;
    final questions = await _remote.getQuestions(assessmentId);
    return summary.toEntity(
      questions: questions.map((q) => q.toEntity()).toList(),
    );
  }

  @override
  Future<void> startAssessment(String assessmentId) {
    return _remote.startAssessment(assessmentId);
  }

  @override
  Future<AssessmentResult> submitAssessment(
    String assessmentId,
    Map<String, String> answers,
  ) async {
    final assessment = await getAssessment(assessmentId);
    final result = await _remote.submitAssessment(
      assessmentId: assessmentId,
      answers: answers,
    );
    return result.toEntity(assessment?.passingScore.toDouble() ?? 50);
  }
}
