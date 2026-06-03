import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/app_providers.dart';
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
  Assessment? _assessment;
  AssessmentController? _controller;
  Timer? _timer;
  Timer? _autoSaveTimer;
  int _remainingSeconds = 0;
  final Set<int> _flagged = {};
  bool _loading = true;
  String? _loadError;
  bool _submitting = false;
  bool _canPop = false;

  Assessment get _activeAssessment => _assessment ?? widget.assessment;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    Assessment assessment = widget.assessment;
    if (assessment.questions.isEmpty) {
      try {
        final loaded = await ref
            .read(assessmentRepositoryProvider)
            .getAssessment(assessment.id);
        if (loaded != null) {
          assessment = loaded;
        }
      } on Object catch (error) {
        if (mounted) {
          setState(() {
            _loadError = error.toString();
            _loading = false;
          });
        }
        return;
      }
    }

    if (!mounted) return;

    final controller = AssessmentController(assessment: assessment, ref: ref);
    setState(() {
      _assessment = assessment;
      _controller = controller;
      _remainingSeconds = assessment.durationMinutes * 60;
      _loading = false;
      _loadError = assessment.questions.isEmpty
          ? 'This assessment is currently empty.'
          : null;
    });

    if (assessment.questions.isEmpty) return;

    try {
      await controller.ensureStarted();
    } on Object catch (error) {
      if (!mounted) return;
      setState(() => _loadError = error.toString());
      return;
    }

    if (!mounted) return;
    _startTimer();
    _startAutoSave();
  }

  void _startTimer() {
    _timer?.cancel();
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
    _autoSaveTimer?.cancel();
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
    final controller = _controller;
    if (controller == null || _submitting) return;

    _timer?.cancel();
    _autoSaveTimer?.cancel();

    if (force) {
      await _finishSubmit(controller);
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

    if (confirmed != true || !mounted) {
      if (_activeAssessment.questions.isNotEmpty) {
        _startTimer();
        _startAutoSave();
      }
      return;
    }
    await _finishSubmit(controller);
  }

  Future<void> _finishSubmit(AssessmentController controller) async {
    setState(() => _submitting = true);
    try {
      final result = await controller.submit();
      if (result.passed) {
        widget.onPassed?.call();
      }

      if (!mounted) return;
      setState(() => _canPop = true);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (context) => AssessmentResultScreen(
            assessment: _activeAssessment,
            result: result,
          ),
        ),
      );
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
      setState(() => _submitting = false);
      if (_activeAssessment.questions.isNotEmpty) {
        _startTimer();
        _startAutoSave();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _autoSaveTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    final controller = _controller;
    final hasQuestions = _activeAssessment.questions.isNotEmpty;

    return PopScope(
      canPop: _canPop,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        if (_loadError != null || _loading || !hasQuestions) {
          setState(() => _canPop = true);
          Future.delayed(Duration.zero, () {
            if (mounted) Navigator.pop(context);
          });
          return;
        }
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Exit assessment?'),
            content: const Text('Your progress will be saved, but the timer will continue running on the server.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Exit'),
              ),
            ],
          ),
        );
        if (confirm == true && mounted) {
          setState(() => _canPop = true);
          Future.delayed(Duration.zero, () {
            if (mounted) Navigator.pop(context);
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              if (_loading || _loadError != null || !hasQuestions) {
                setState(() => _canPop = true);
                Future.delayed(Duration.zero, () {
                  if (mounted) Navigator.of(context).pop();
                });
                return;
              }
              Navigator.maybePop(context);
            },
          ),
          title: Text(_activeAssessment.title),
          actions: [
            if (!_loading && _loadError == null && hasQuestions)
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
        body: _buildBody(controller),
      ),
    );
  }

  Widget _buildBody(AssessmentController? controller) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_loadError != null) {
      final isEmpty = _loadError == 'This assessment is currently empty.';
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(isEmpty ? Icons.inbox_outlined : Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              Text(_loadError!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              if (!isEmpty)
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _loading = true;
                      _loadError = null;
                    });
                    _bootstrap();
                  },
                  child: const Text('Retry'),
                ),
              TextButton(
                onPressed: () {
                  setState(() => _canPop = true);
                  Future.delayed(Duration.zero, () {
                    if (mounted) Navigator.of(context).pop();
                  });
                },
                child: const Text('Go back'),
              ),
            ],
          ),
        ),
      );
    }

    if (controller == null) {
      return const SizedBox.shrink();
    }

    final questions = _activeAssessment.questions;
    if (questions.isEmpty) {
      return _buildEmptyAssessment('No questions are available for this assessment.');
    }

    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: controller.pageController,
            onPageChanged: (_) => setState(() {}),
            itemCount: questions.length,
            itemBuilder: (context, index) {
              return QuestionWidget(
                question: questions[index],
                onAnswer: (answer) => controller.saveAnswer(index, answer),
                initialAnswer: controller.getAnswer(index),
              );
            },
          ),
        ),
        _buildNavigationButtons(controller),
      ],
    );
  }

  Widget _buildEmptyAssessment(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox_outlined, size: 48),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() => _canPop = true);
                Future.delayed(Duration.zero, () {
                  if (mounted) Navigator.of(context).pop();
                });
              },
              child: const Text('Go back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(AssessmentController controller) {
    final questions = _activeAssessment.questions;
    final index = controller.pageController.hasClients
        ? controller.pageController.page?.round() ?? 0
        : 0;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Flag for review',
            icon: Icon(
              _flagged.contains(index) ? Icons.flag : Icons.outlined_flag,
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
                ? () => controller.goToQuestion(index - 1)
                : null,
            child: const Text('Previous'),
          ),
          const Spacer(),
          if (index < questions.length - 1)
            ElevatedButton(
              onPressed: _submitting
                  ? null
                  : () => controller.goToQuestion(index + 1),
              child: const Text('Next'),
            )
          else
            ElevatedButton(
              onPressed: _submitting ? null : _submitAssessment,
              child: _submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Submit'),
            ),
        ],
      ),
    );
  }
}
