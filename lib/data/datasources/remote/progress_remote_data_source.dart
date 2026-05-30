import 'package:dio/dio.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/utils/json_map.dart';
import '../../models/progress_models.dart';

abstract class ProgressRemoteDataSource {
  Future<CourseProgressDto> getCourseProgress(String courseId);
  Future<void> markLessonComplete({
    required String courseId,
    required String lessonId,
  });
}

class DioProgressRemoteDataSource implements ProgressRemoteDataSource {
  const DioProgressRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<CourseProgressDto> getCourseProgress(String courseId) async {
    final response = await _dio.get<dynamic>(
      ApiEndpoints.courseProgress(courseId),
    );
    return CourseProgressDto.fromJson(castJsonMap(response.data));
  }

  @override
  Future<void> markLessonComplete({
    required String courseId,
    required String lessonId,
  }) async {
    await _dio.post<dynamic>(
      ApiEndpoints.markLessonComplete,
      data: {
        'courseId': courseId,
        'lessonId': lessonId,
      },
    );
  }
}
