import 'dart:convert';

import '../../core/utils/json_map.dart';
import '../../domain/entities/assessment.dart';

class AssessmentSummaryDto {
  const AssessmentSummaryDto({
    required this.assessmentId,
    required this.courseId,
    required this.title,
    required this.description,
    required this.passingScore,
    required this.timeLimitMinutes,
    required this.maxAttempts,
    required this.dueDate,
    required this.status,
  });

  final String assessmentId;
  final String courseId;
  final String title;
  final String description;
  final double passingScore;
  final int? timeLimitMinutes;
  final int maxAttempts;
  final DateTime? dueDate;
  final String status;

  factory AssessmentSummaryDto.fromJson(JsonMap json) {
    final data = findMap(json, const ['data', 'result']) ?? json;
    return AssessmentSummaryDto(
      assessmentId:
          findString(data, const ['assessmentId', 'id']) ?? '',
      courseId: findString(data, const ['courseId']) ?? '',
      title: findString(data, const ['title']) ?? 'Assessment',
      description: findString(data, const ['description']) ?? '',
      passingScore: _readDouble(data['passingScore']) ?? 50,
      timeLimitMinutes: _readInt(data['timeLimitMinutes']),
      maxAttempts: _readInt(data['maxAttempts']) ?? 3,
      dueDate: parseDateTime(data['dueDate']),
      status: findString(data, const ['assessmentStatus', 'status']) ?? '',
    );
  }

  Assessment toEntity({List<Question> questions = const []}) {
    return Assessment(
      id: assessmentId,
      courseId: courseId,
      title: title,
      description: description,
      durationMinutes: timeLimitMinutes ?? 30,
      passingScore: passingScore.round(),
      questions: questions,
      dueDate: dueDate,
      attemptLimit: maxAttempts,
    );
  }
}

class AssessmentQuestionDto {
  const AssessmentQuestionDto({
    required this.questionId,
    required this.text,
    required this.questionType,
    required this.options,
    required this.points,
    required this.orderIndex,
  });

  final String questionId;
  final String text;
  final String questionType;
  final List<String> options;
  final int points;
  final int orderIndex;

  factory AssessmentQuestionDto.fromJson(JsonMap json) {
    final data = findMap(json, const ['data', 'result']) ?? json;
    return AssessmentQuestionDto(
      questionId: findString(data, const ['questionId', 'id']) ?? '',
      text: findString(data, const ['text']) ?? '',
      questionType:
          findString(data, const ['questionType', 'type']) ?? 'MultipleChoice',
      options: _parseOptions(data['optionsJson'] ?? data['options']),
      points: _readInt(data['points']) ?? 1,
      orderIndex: _readInt(data['orderIndex']) ?? 0,
    );
  }

  Question toEntity() {
    return Question(
      id: questionId,
      text: text,
      type: _mapQuestionType(questionType, options),
      options: options,
      correctAnswers: const [],
      points: points,
    );
  }

  static List<String> _parseOptions(Object? raw) {
    if (raw is List) {
      return raw.map((e) => e.toString()).toList();
    }
    if (raw is String && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          return decoded.map((e) => e.toString()).toList();
        }
      } on Object {
        return const [];
      }
    }
    return const [];
  }

  static QuestionType _mapQuestionType(
    String backendType,
    List<String> options,
  ) {
    switch (backendType.toLowerCase()) {
      case 'multiplechoice':
        return QuestionType.multipleChoice;
      case 'shortanswer':
        return QuestionType.essay;
      case 'truefalse':
        return QuestionType.trueFalse;
      default:
        return options.length <= 2
            ? QuestionType.multipleChoice
            : QuestionType.essay;
    }
  }
}

class SubmissionResultDto {
  const SubmissionResultDto({
    required this.score,
    required this.maxScore,
    required this.passed,
    required this.feedback,
    required this.attemptNumber,
  });

  final double? score;
  final double maxScore;
  final bool passed;
  final String feedback;
  final int attemptNumber;

  factory SubmissionResultDto.fromJson(JsonMap json) {
    final data = findMap(json, const ['data', 'result']) ?? json;
    final score = _readDouble(data['score']);
    final passingScore = _readDouble(data['passingScore']) ?? 50;
    final maxScore = _readDouble(data['maxScore']) ?? 100;
    final percentage = maxScore == 0 ? 0.0 : ((score ?? 0) / maxScore) * 100;
    return SubmissionResultDto(
      score: score,
      maxScore: maxScore,
      passed: percentage >= passingScore,
      feedback: findString(data, const ['feedback']) ?? '',
      attemptNumber: _readInt(data['attemptNumber']) ?? 1,
    );
  }

  AssessmentResult toEntity(double assessmentPassingPercent) {
    final scoreValue = (score ?? 0).round();
    final max = maxScore.round();
    final percentage = max == 0 ? 0.0 : (scoreValue / max) * 100;
    return AssessmentResult(
      score: scoreValue,
      maxScore: max,
      passed: percentage >= assessmentPassingPercent,
      feedback: feedback.isNotEmpty
          ? feedback
          : (percentage >= assessmentPassingPercent
              ? 'Great work! You passed this assessment.'
              : 'Keep studying and try again when ready.'),
      attemptNumber: attemptNumber,
    );
  }
}

int? _readInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

double? _readDouble(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
