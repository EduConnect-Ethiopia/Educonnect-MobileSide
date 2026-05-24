import 'package:dio/dio.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/utils/json_map.dart';
import '../../models/recommendation_models.dart';

abstract class RecommendationRemoteDataSource {
  Future<List<RecommendedCourseDto>> getRecommendations({int topN = 8});
  Future<void> trackInteraction({
    String? courseId,
    String? category,
    String interactionType = 'View',
  });
}

class DioRecommendationRemoteDataSource
    implements RecommendationRemoteDataSource {
  const DioRecommendationRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<List<RecommendedCourseDto>> getRecommendations({int topN = 8}) async {
    final response = await _dio.get<dynamic>(
      ApiEndpoints.recommendations,
      queryParameters: {'topN': topN},
    );
    return _unwrapList(response.data)
        .map((json) => RecommendedCourseDto.fromJson(castJsonMap(json)))
        .toList();
  }

  @override
  Future<void> trackInteraction({
    String? courseId,
    String? category,
    String interactionType = 'View',
  }) async {
    await _dio.post<dynamic>(
      ApiEndpoints.trackRecommendation,
      data: {
        if (courseId != null) 'courseId': courseId,
        if (category != null) 'category': category,
        'interactionType': interactionType,
      },
    );
  }

  List<Map<String, dynamic>> _unwrapList(Object? value) {
    if (value is List) {
      return value.whereType<Map<String, dynamic>>().toList();
    }
    if (value is Map) {
      final map = castJsonMap(value);
      final data = map['data'];
      if (data is List) {
        return data.whereType<Map<String, dynamic>>().toList();
      }
    }
    return const [];
  }
}
