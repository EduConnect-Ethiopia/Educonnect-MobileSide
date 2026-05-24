import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/app_providers.dart';
import '../../domain/entities/assessment.dart';

class AssessmentController {
  AssessmentController({
    required this.assessment,
    required this.ref,
  }) : pageController = PageController();

  final Assessment assessment;
  final WidgetRef ref;
  final PageController pageController;
  final Map<String, String> _answers = {};
  int _currentIndex = 0;
  bool _started = false;

  int get currentIndex => _currentIndex;

  Future<void> ensureStarted() async {
    if (_started) return;
    await ref.read(assessmentRepositoryProvider).startAssessment(assessment.id);
    _started = true;
  }

  void saveAnswer(int index, dynamic answer) {
    if (index < 0 || index >= assessment.questions.length) return;
    final question = assessment.questions[index];
    _answers[question.id] = _serializeAnswer(question, answer);
  }

  String? getAnswer(int index) {
    if (index < 0 || index >= assessment.questions.length) return null;
    return _answers[assessment.questions[index].id];
  }

  void goToQuestion(int index) {
    _currentIndex = index.clamp(0, assessment.questions.length - 1);
    pageController.animateToPage(
      _currentIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void next() {
    if (_currentIndex < assessment.questions.length - 1) {
      goToQuestion(_currentIndex + 1);
    }
  }

  void previous() {
    if (_currentIndex > 0) {
      goToQuestion(_currentIndex - 1);
    }
  }

  Future<AssessmentResult> submit() {
    return ref.read(assessmentRepositoryProvider).submitAssessment(
          assessment.id,
          Map<String, String>.from(_answers),
        );
  }

  String _serializeAnswer(Question question, dynamic answer) {
    switch (question.type) {
      case QuestionType.multipleChoice:
      case QuestionType.trueFalse:
        if (answer is int && answer >= 0 && answer < question.options.length) {
          return question.options[answer];
        }
        return answer?.toString() ?? '';
      case QuestionType.multipleSelect:
        if (answer is List<int>) {
          return answer
              .where((i) => i >= 0 && i < question.options.length)
              .map((i) => question.options[i])
              .join('|');
        }
        return answer?.toString() ?? '';
      case QuestionType.fillBlank:
      case QuestionType.essay:
        return answer?.toString().trim() ?? '';
    }
  }

  void dispose() {
    pageController.dispose();
  }
}
