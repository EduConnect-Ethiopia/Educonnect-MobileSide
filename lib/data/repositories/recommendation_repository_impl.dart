import '../../domain/entities/course.dart';
import '../../domain/repositories/recommendation_repository.dart';
import '../datasources/remote/recommendation_remote_data_source.dart';

class RecommendationRepositoryImpl implements RecommendationRepository {
  RecommendationRepositoryImpl(this._remote);

  final RecommendationRemoteDataSource _remote;

  @override
  Future<List<Course>> getRecommendations({int topN = 8}) async {
    final dtos = await _remote.getRecommendations(topN: topN);
    return dtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<void> trackBehavior({
    String? courseId,
    String? category,
    String interactionType = 'View',
  }) {
    return _remote.trackInteraction(
      courseId: courseId,
      category: category,
      interactionType: interactionType,
    );
  }
}
