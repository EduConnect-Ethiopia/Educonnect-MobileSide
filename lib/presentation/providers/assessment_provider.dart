import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/app_providers.dart';
import '../../domain/entities/assessment.dart';

final upcomingAssessmentsProvider =
    FutureProvider.family<List<Assessment>, String>((ref, courseId) {
  return ref.read(assessmentRepositoryProvider).getUpcomingAssessments(courseId);
});
