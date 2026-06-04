import 'package:flutter_test/flutter_test.dart';

import 'package:educonnect_mobile/data/models/assessment_models.dart';
import 'package:educonnect_mobile/data/repositories/assessment_repository_impl.dart';
import 'package:educonnect_mobile/domain/entities/assessment.dart';
import 'package:educonnect_mobile/data/datasources/remote/assessment_remote_data_source.dart';

class _FakeAssessmentRemote implements AssessmentRemoteDataSource {
  AssessmentSummaryDto? summary;
  final Map<String, List<AssessmentQuestionDto>> questionsById = {};
  final List<String> started = [];
  final Map<String, Map<String, String>> submitted = {};

  @override
  Future<AssessmentSummaryDto?> getAssessment(String assessmentId) async => summary;

  @override
  Future<List<AssessmentSummaryDto>> getAssessmentsByCourse(String courseId) async {
    return summary == null ? [] : [summary!];
  }

  @override
  Future<List<AssessmentQuestionDto>> getQuestions(String assessmentId) async {
    return questionsById[assessmentId] ?? [];
  }

  @override
  Future<DateTime?> startAssessment(String assessmentId) async {
    started.add(assessmentId);
    return DateTime.now().toUtc();
  }

  @override
  Future<SubmissionResultDto> submitAssessment({
    required String assessmentId,
    required Map<String, String> answers,
    String content = '',
  }) async {
    submitted[assessmentId] = answers;
    return SubmissionResultDto(
      score: 80,
      maxScore: 100,
      passed: true,
      feedback: 'Great work',
      attemptNumber: 2,
    );
  }

  @override
  Future<void> submitAssignment({
    required String assessmentId,
    required String filePath,
    String content = '',
  }) async {}
}

void main() {
  test('loads upcoming assessments and maps questions', () async {
    final remote = _FakeAssessmentRemote()
      ..summary = AssessmentSummaryDto(
        assessmentId: 'a1',
        lessonId: 'l1',
        courseId: 'c1',
        title: 'Quiz 1',
        assessmentType: 'Quiz',
        description: 'desc',
        passingScore: 60,
        timeLimitMinutes: 20,
        maxAttempts: 3,
        dueDate: null,
        status: 'published',
      )
      ..questionsById['a1'] = [
        AssessmentQuestionDto(
          questionId: 'q1',
          text: '2+2?',
          questionType: 'MultipleChoice',
          options: const ['3', '4'],
          points: 1,
          orderIndex: 0,
        ),
      ];

    final repo = AssessmentRepositoryImpl(remote);
    final assessments = await repo.getUpcomingAssessments('c1');

    expect(assessments, hasLength(1));
    expect(assessments.single.id, 'a1');
    expect(assessments.single.questions, hasLength(1));
    expect(assessments.single.questions.single.type, QuestionType.multipleChoice);
  });

  test('submitAssessment maps backend submission result', () async {
    final remote = _FakeAssessmentRemote()
      ..summary = AssessmentSummaryDto(
        assessmentId: 'a1',
        lessonId: 'l1',
        courseId: 'c1',
        title: 'Quiz 1',
        assessmentType: 'Quiz',
        description: 'desc',
        passingScore: 60,
        timeLimitMinutes: 20,
        maxAttempts: 3,
        dueDate: null,
        status: 'published',
      )
      ..questionsById['a1'] = [
        AssessmentQuestionDto(
          questionId: 'q1',
          text: '2+2?',
          questionType: 'MultipleChoice',
          options: const ['3', '4'],
          points: 1,
          orderIndex: 0,
        ),
      ];

    final repo = AssessmentRepositoryImpl(remote);
    final result = await repo.submitAssessment('a1', {'q1': '4'});

    expect(result.score, 80);
    expect(result.passed, true);
    expect(remote.submitted['a1'], {'q1': '4'});
  });
}
