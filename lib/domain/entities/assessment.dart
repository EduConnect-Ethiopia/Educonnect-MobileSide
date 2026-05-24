enum QuestionType {
  multipleChoice,
  multipleSelect,
  trueFalse,
  fillBlank,
  essay,
}

class Assessment {
  const Assessment({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.durationMinutes,
    required this.passingScore,
    required this.questions,
    this.dueDate,
    this.attemptLimit = 3,
    this.shuffleQuestions = false,
  });

  final String id;
  final String courseId;
  final String title;
  final String description;
  final int durationMinutes;
  final int passingScore;
  final List<Question> questions;
  final DateTime? dueDate;
  final int attemptLimit;
  final bool shuffleQuestions;
}

class Question {
  const Question({
    required this.id,
    required this.text,
    required this.type,
    required this.options,
    required this.correctAnswers,
    this.correctAnswerText,
    this.points = 1,
  });

  final String id;
  final String text;
  final QuestionType type;
  final List<String> options;
  final List<int> correctAnswers;
  final String? correctAnswerText;
  final int points;
}

class AssessmentResult {
  const AssessmentResult({
    required this.score,
    required this.maxScore,
    required this.passed,
    required this.feedback,
    this.attemptNumber = 1,
  });

  final int score;
  final int maxScore;
  final bool passed;
  final String feedback;
  final int attemptNumber;

  double get percentage =>
      maxScore == 0 ? 0 : (score / maxScore) * 100;
}
