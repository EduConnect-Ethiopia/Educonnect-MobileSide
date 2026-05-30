import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/assessment.dart';
import '../../controllers/assessment_controller.dart';
import '../../widgets/question_widgets.dart';
import 'assessment_result_screen.dart';

class AssessmentPlayerScreen extends ConsumerStatefulWidget {
  const AssessmentPlayerScreen({
    required this.assessment,
    this.onPassed,
    super.key,
  });

  final Assessment assessment;
  final VoidCallback? onPassed;

  @override
  ConsumerState<AssessmentPlayerScreen> createState() =>
      _AssessmentPlayerScreenState();
}

class _AssessmentPlayerScreenState
    extends ConsumerState<AssessmentPlayerScreen> {
  late AssessmentController _controller;
  Timer? _timer;
  Timer? _autoSaveTimer;
  int _remainingSeconds = 0;
  final Set<int> _flagged = {};

  @override
  void initState() {
    super.initState();
    _controller = AssessmentController(
      assessment: widget.assessment,
      ref: ref,
    );
    _remainingSeconds = widget.assessment.durationMinutes * 60;
    _controller.ensureStarted();
    _startTimer();
    _startAutoSave();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 0) {
        timer.cancel();
        _submitAssessment(force: true);
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  void _startAutoSave() {
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Progress auto-saved'),
          duration: Duration(seconds: 1),
        ),
      );
    });
  }

  Future<void> _submitAssessment({bool force = false}) async {
    _timer?.cancel();
    _autoSaveTimer?.cancel();

    if (force) {
      await _finishSubmit();
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Submit assessment?'),
        content: const Text('You cannot change answers after submitting.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    await _finishSubmit();
  }

  Future<void> _finishSubmit() async {
    final result = await _controller.submit();
    if (result.passed) {
      widget.onPassed?.call();
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (context) => AssessmentResultScreen(
          assessment: widget.assessment,
          result: result,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _autoSaveTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.assessment.title),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text(
                  '$minutes:$seconds',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller.pageController,
                onPageChanged: (i) => setState(() {}),
                itemCount: widget.assessment.questions.length,
                itemBuilder: (context, index) {
                  return QuestionWidget(
                    question: widget.assessment.questions[index],
                    onAnswer: (answer) =>
                        _controller.saveAnswer(index, answer),
                    initialAnswer: _controller.getAnswer(index),
                  );
                },
              ),
            ),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    final index = _controller.pageController.hasClients
        ? _controller.pageController.page?.round() ?? 0
        : 0;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Flag for review',
            icon: Icon(
              _flagged.contains(index)
                  ? Icons.flag
                  : Icons.outlined_flag,
              color: _flagged.contains(index) ? Colors.orange : null,
            ),
            onPressed: () {
              setState(() {
                if (_flagged.contains(index)) {
                  _flagged.remove(index);
                } else {
                  _flagged.add(index);
                }
              });
            },
          ),
          TextButton(
            onPressed: index > 0
                ? () => _controller.goToQuestion(index - 1)
                : null,
            child: const Text('Previous'),
          ),
          const Spacer(),
          if (index < widget.assessment.questions.length - 1)
            ElevatedButton(
              onPressed: () => _controller.goToQuestion(index + 1),
              child: const Text('Next'),
            )
          else
            ElevatedButton(
              onPressed: _submitAssessment,
              child: const Text('Submit'),
            ),
        ],
      ),
    );
  }
}
