import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/assessment_provider.dart';
import 'assignment_submission_screen.dart';
import 'assessment_player_screen.dart';

class AssessmentsListScreen extends ConsumerWidget {
  const AssessmentsListScreen({required this.courseId, super.key});

  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assessmentsAsync =
        ref.watch(upcomingAssessmentsProvider(courseId));

    return Scaffold(
      appBar: AppBar(title: const Text('Assessments')),
      body: assessmentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(child: Text('Failed to load assessments')),
        data: (assessments) {
          if (assessments.isEmpty) {
            return const Center(child: Text('No upcoming assessments'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: assessments.length,
            itemBuilder: (context, index) {
              final a = assessments[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.quiz),
                  title: Text(a.title),
                  subtitle: Text(
                    a.dueDate != null
                        ? 'Due ${a.dueDate!.day}/${a.dueDate!.month}/${a.dueDate!.year}'
                        : '${a.durationMinutes} minutes',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => a.isAssignment
                            ? AssignmentSubmissionScreen(assessment: a)
                            : AssessmentPlayerScreen(assessment: a),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
