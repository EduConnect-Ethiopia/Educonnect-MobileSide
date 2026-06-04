import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/assessment.dart';
import 'assessment_player_screen.dart';

class AssessmentResultScreen extends StatelessWidget {
  const AssessmentResultScreen({
    required this.assessment,
    required this.result,
    super.key,
  });

  final Assessment assessment;
  final AssessmentResult result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Results')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              result.isPendingGrade
                  ? Icons.hourglass_empty
                  : (result.passed ? Icons.check_circle : Icons.cancel),
              size: 80,
              color: result.isPendingGrade
                  ? Colors.orange
                  : (result.passed ? Colors.green : Colors.red),
            ),
            const SizedBox(height: 16),
            Text(
              result.isPendingGrade
                  ? 'Pending Grade'
                  : (result.passed ? 'Passed!' : 'Not passed'),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            if (!result.isPendingGrade)
              Text(
                'Score: ${result.score} / ${result.maxScore} '
                '(${result.percentage.toStringAsFixed(0)}%)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            if (!result.isPendingGrade)
              const SizedBox(height: 16),
            Text(result.feedback, textAlign: TextAlign.center),
            const Spacer(),
            if (!result.isPendingGrade && !result.passed && result.attemptNumber < assessment.attemptLimit)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => AssessmentPlayerScreen(
                          assessment: assessment,
                        ),
                      ),
                    );
                  },
                  child: const Text('Retake'),
                ),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
