enum QuestionType {
  multipleChoice,
  multipleSelect,
  trueFalse,
  fillBlank,
  essay,
}

enum AssessmentType {
  quiz,
  assignment,
  exam,
  unknown,
}

class Assessment {
  const Assessment({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.type,
    required this.durationMinutes,
    required this.passingScore,
    required this.questions,
    this.lessonId,
    this.dueDate,
    this.attemptLimit = 3,
    this.shuffleQuestions = false,
  });

  final String id;
  final String courseId;
  final String? lessonId;
  final String title;
  final String description;
  final AssessmentType type;
  final int durationMinutes;
  final int passingScore;
  final List<Question> questions;
  final DateTime? dueDate;
  final int attemptLimit;
  final bool shuffleQuestions;

  bool get isAssignment => type == AssessmentType.assignment;
  bool get isExam => type == AssessmentType.exam;
  bool get isQuiz => type == AssessmentType.quiz;
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
    this.isPendingGrade = false,
  });

  final int score;
  final int maxScore;
  final bool passed;
  final String feedback;
  final int attemptNumber;
  final bool isPendingGrade;

  double get percentage =>
      maxScore == 0 ? 0 : (score / maxScore) * 100;
}
