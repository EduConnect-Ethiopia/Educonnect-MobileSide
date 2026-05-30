import 'package:dio/dio.dart';

import '../../core/constants/api_endpoints.dart';
import '../../core/utils/json_map.dart';
import '../models/course_models.dart';

abstract class EnrollmentRemoteDataSource {
  Future<EnrollmentModel?> enroll(String courseId);
  Future<void> unenroll(String courseId);
  Future<List<EnrollmentModel>> getMyEnrollments();
}

class DioEnrollmentRemoteDataSource implements EnrollmentRemoteDataSource {
  const DioEnrollmentRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<EnrollmentModel?> enroll(String courseId) async {
    final response = await _dio.post<dynamic>(
      ApiEndpoints.enroll,
      data: {'courseId': courseId},
    );

    final data = _unwrapApiData(response.data);
    if (data is Map<String, dynamic>) {
      return EnrollmentModel.fromJson(data);
    }

    return null;
  }

  @override
  Future<void> unenroll(String courseId) async {
    await _dio.delete<dynamic>(
      ApiEndpoints.unenroll,
      data: {'courseId': courseId},
    );
  }

  @override
  Future<List<EnrollmentModel>> getMyEnrollments() async {
    final response = await _dio.get<dynamic>(ApiEndpoints.myEnrollments);
    final data = _unwrapApiData(response.data);

    if (data is! List) {
      return const [];
    }

    return data
        .whereType<Map<String, dynamic>>()
        .map(EnrollmentModel.fromJson)
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
