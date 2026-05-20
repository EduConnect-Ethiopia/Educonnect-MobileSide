import 'package:dio/dio.dart';

import '../../core/constants/api_endpoints.dart';
import '../../core/utils/json_map.dart';
import '../models/course_models.dart';
import '../models/session_models.dart';

abstract class CourseRemoteDataSource {
  Future<CourseModel> getCourseById(String courseId);
  Future<List<CourseModel>> getPublishedCourses();
  Future<CourseContentModel> getCourseContent(String courseId);
  Future<List<EnrollmentModel>> getLearnerEnrollments(String userId);
  Future<List<CourseSessionModel>> getCourseSessions(String courseId);
}

class DioCourseRemoteDataSource implements CourseRemoteDataSource {
  const DioCourseRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<CourseModel> getCourseById(String courseId) async {
    final response = await _dio.get<dynamic>(ApiEndpoints.course(courseId));
    return CourseModel.fromJson(castJsonMap(_unwrapApiData(response.data)));
  }

  @override
  Future<List<CourseModel>> getPublishedCourses() async {
    final response = await _dio.get<dynamic>(ApiEndpoints.publishedCourses);
    final data = _unwrapApiData(response.data);

    if (data is! List) {
      return const [];
    }

    return data
        .whereType<Map<String, dynamic>>()
        .map(CourseModel.fromJson)
        .toList();
  }

  @override
  Future<CourseContentModel> getCourseContent(String courseId) async {
    final response = await _dio.get<dynamic>(ApiEndpoints.courseContent(courseId));
    return CourseContentModel.fromJson(castJsonMap(_unwrapApiData(response.data)));
  }

  @override
  Future<List<EnrollmentModel>> getLearnerEnrollments(String userId) async {
    final response = await _dio.get<dynamic>(
      ApiEndpoints.learnerEnrollments(userId),
    );
    final data = _unwrapApiData(response.data);

    if (data is! List) {
      return const [];
    }

    return data
        .whereType<Object>()
        .map(castJsonMap)
        .map(EnrollmentModel.fromJson)
        .toList();
  }

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
