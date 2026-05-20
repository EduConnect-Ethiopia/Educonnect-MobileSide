import 'package:dio/dio.dart';

import '../../core/constants/api_endpoints.dart';
import '../../core/utils/json_map.dart';
import '../models/session_models.dart';

abstract class SessionRemoteDataSource {
  Future<List<CourseSessionModel>> getCourseSessions(String courseId);
}

class DioSessionRemoteDataSource implements SessionRemoteDataSource {
  const DioSessionRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<List<CourseSessionModel>> getCourseSessions(String courseId) async {
    final response = await _dio.get<dynamic>(ApiEndpoints.courseSessions(courseId));
    final data = _unwrapApiData(response.data);

    if (data is! List) {
      return const [];
    }

    return data
        .whereType<Map<String, dynamic>>()
        .map(CourseSessionModel.fromJson)
        .toList();
  }
}

Object? _unwrapApiData(Object? value) {
  if (value is Map) {
    final map = castJsonMap(value);
    return map.containsKey('data') ? map['data'] : map;
  }

  return value;
}
