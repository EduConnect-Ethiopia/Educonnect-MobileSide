import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/app_providers.dart';
import '../../domain/entities/course.dart';

final recommendationsProvider = FutureProvider<List<Course>>((ref) async {
  return ref.watch(recommendationRepositoryProvider).getRecommendations();
});

final recommendationControllerProvider =
    Provider<RecommendationTracker>((ref) {
  return RecommendationTracker(ref);
});

class RecommendationTracker {
  RecommendationTracker(this._ref);

  final Ref _ref;

  Future<void> trackView(String courseId, {String? category}) async {
    try {
      await _ref.read(recommendationRepositoryProvider).trackBehavior(
            courseId: courseId,
            category: category,
            interactionType: 'View',
          );
    } on Object {
      // Non-blocking analytics.
    }
  }
}
