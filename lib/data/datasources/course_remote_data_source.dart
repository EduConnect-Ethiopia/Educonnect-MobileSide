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
    try {
      final response = await _dio.get<dynamic>(
        ApiEndpoints.courseContent(courseId),
      );
      final data = _unwrapApiData(response.data);
      if (data is Map<String, dynamic>) {
        final model = CourseContentModel.fromJson(castJsonMap(data));
        if (model.modules.isNotEmpty) {
          return model;
        }
      }
    } on DioException catch (error) {
      if (error.response?.statusCode != 404) {
        rethrow;
      }
    }

    return _buildCourseContentFromModules(courseId);
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

  Future<CourseContentModel> _buildCourseContentFromModules(
    String courseId,
  ) async {
    final courseResponse = await _dio.get<dynamic>(
      ApiEndpoints.course(courseId),
    );
    final courseData = _unwrapApiData(courseResponse.data);
    final courseModel = CourseModel.fromJson(castJsonMap(courseData));

    final modules = await _fetchModules(courseId);
    final modulesWithLessons = await Future.wait(
      modules.map((module) async {
        final lessons = await _fetchLessons(module.moduleId);
        final lessonsWithMaterials = await Future.wait(
          lessons.map((lesson) async {
            final materials = await _fetchMaterials(lesson.lessonId);
            return lesson.copyWithMaterials(materials);
          }),
        );
        return module.copyWithLessons(lessonsWithMaterials);
      }),
    );

    return CourseContentModel(course: courseModel, modules: modulesWithLessons);
  }

  Future<List<ModuleModel>> _fetchModules(String courseId) async {
    final response = await _dio.get<dynamic>(
      ApiEndpoints.courseModules(courseId),
    );
    final data = _unwrapApiData(response.data);
    if (data is! List) {
      return const [];
    }
    return data
        .whereType<Map<String, dynamic>>()
        .map(ModuleModel.fromJson)
        .toList();
  }

  Future<List<LessonModel>> _fetchLessons(String moduleId) async {
    final response = await _dio.get<dynamic>(
      ApiEndpoints.moduleLessons(moduleId),
    );
    final data = _unwrapApiData(response.data);
    if (data is! List) {
      return const [];
    }
    return data
        .whereType<Map<String, dynamic>>()
        .map(LessonModel.fromJson)
        .toList();
  }

  Future<List<MaterialModel>> _fetchMaterials(String lessonId) async {
    final response = await _dio.get<dynamic>(
      ApiEndpoints.lessonMaterials(lessonId),
    );
    final data = _unwrapApiData(response.data);
    if (data is! List) {
      return const [];
    }
    return data
        .whereType<Map<String, dynamic>>()
        .map(MaterialModel.fromJson)
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
