import '../entities/course.dart';

abstract class RecommendationRepository {
  Future<List<Course>> getRecommendations({int topN = 8});
  Future<void> trackBehavior({
    String? courseId,
    String? category,
    String interactionType = 'View',
  });
}
