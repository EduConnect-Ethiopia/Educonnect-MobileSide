import 'package:dio/dio.dart';

import '../../core/constants/api_endpoints.dart';
import '../../core/utils/json_map.dart';
import '../models/course_models.dart';
import '../models/session_models.dart';

abstract class CourseRemoteDataSource {
  Future<CourseModel> getCourseById(String courseId);
  Future<List<CourseModel>> getPublishedCourses();
  Future<List<CourseModel>> searchCourses(String query, {int page = 1, int pageSize = 20});
  Future<CourseContentModel> getCourseContent(String courseId);
  Future<List<ModuleModel>> getCourseModules(String courseId);
  Future<List<LessonModel>> getModuleLessons(String moduleId);
  Future<List<MaterialModel>> getLessonMaterials(String lessonId);
  Future<List<EnrollmentModel>> getLearnerEnrollments(String userId);
  Future<List<CourseSessionModel>> getCourseSessions(String courseId);
  Future<String> getMaterialAccessUrl(String materialId);
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

    if (data is! List) return const [];

    return data.whereType<Map<String, dynamic>>().map(CourseModel.fromJson).toList();
  }

  @override
  Future<List<CourseModel>> searchCourses(String query, {int page = 1, int pageSize = 20}) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return getPublishedCourses();
    }

    final response = await _dio.get<dynamic>(
      ApiEndpoints.searchCourses,
      queryParameters: {
        'query': trimmed,
        'q': trimmed,
        'page': page,
        'pageSize': pageSize,
      },
    );

    final data = _unwrapApiData(response.data);

    if (data is List) {
      return data.whereType<Map<String, dynamic>>().map(CourseModel.fromJson).toList();
    }

    if (data is Map) {
      final map = castJsonMap(data);
      final items = map['items'];
      if (items is List) {
        return items.whereType<Map<String, dynamic>>().map(CourseModel.fromJson).toList();
      }
    }

    return const [];
  }

  @override
  Future<String> getMaterialAccessUrl(String materialId) async {
    final response = await _dio.post<dynamic>(ApiEndpoints.materialAccess(materialId));
    final data = _unwrapApiData(response.data);
    if (data is String) return data;
    if (data is Map) {
      final map = castJsonMap(data);
      return (map['url'] ?? map['accessUrl'] ?? '').toString();
    }
    return '';
  }

  @override
  Future<CourseContentModel> getCourseContent(String courseId) async {
    // Try the dedicated endpoint first; if not available, assemble from modules
    try {
      final response = await _dio.get<dynamic>(ApiEndpoints.courseContent(courseId));
      final data = _unwrapApiData(response.data);
      if (data is Map) {
        var model = CourseContentModel.fromJson(castJsonMap(data));
        if (model.modules.isNotEmpty && !_hasAnyMaterials(model)) {
          model = await _hydrateMaterials(model);
        }
        if (model.modules.isNotEmpty) return model;
      }
    } on DioException catch (error) {
      if (error.response?.statusCode != 404) rethrow;
    }

    final course = await getCourseById(courseId);
    final modules = await getCourseModules(courseId);

    final modulesWithChildren = await Future.wait(
      modules.map((module) async {
        final lessons = await getModuleLessons(module.moduleId);
        final lessonsWithMaterials = await Future.wait(
          lessons.map((lesson) async {
            final materials = await getLessonMaterials(lesson.lessonId);
            return lesson.copyWith(materials: materials);
          }),
        );
        return module.copyWith(lessons: lessonsWithMaterials);
      }),
    );

    return CourseContentModel.fromStructure(course: course, modules: modulesWithChildren);
  }

  @override
  Future<List<ModuleModel>> getCourseModules(String courseId) async {
    final response = await _dio.get<dynamic>(ApiEndpoints.courseModules(courseId));
    final data = _unwrapApiData(response.data);
    if (data is! List) return const [];
    return data.whereType<Map<String, dynamic>>().map(ModuleModel.fromJson).toList();
  }

  @override
  Future<List<LessonModel>> getModuleLessons(String moduleId) async {
    final response = await _dio.get<dynamic>(ApiEndpoints.moduleLessons(moduleId));
    final data = _unwrapApiData(response.data);
    if (data is! List) return const [];
    return data.whereType<Map<String, dynamic>>().map(LessonModel.fromJson).toList();
  }

  @override
  Future<List<MaterialModel>> getLessonMaterials(String lessonId) async {
    final response = await _dio.get<dynamic>(ApiEndpoints.lessonMaterials(lessonId));
    final data = _unwrapApiData(response.data);
    final items = unwrapJsonList(data);
    if (items.isEmpty) return const [];
    return items.map(MaterialModel.fromJson).toList();
  }

  bool _hasAnyMaterials(CourseContentModel model) {
    for (final module in model.modules) {
      for (final lesson in module.lessons) {
        if (lesson.materials.isNotEmpty) return true;
      }
    }
    return false;
  }

  Future<CourseContentModel> _hydrateMaterials(CourseContentModel model) async {
    final modules = await Future.wait(
      model.modules.map((module) async {
        if (module.lessons.isEmpty) return module;
        final lessons = await Future.wait(
          module.lessons.map((lesson) async {
            if (lesson.materials.isNotEmpty) return lesson;
            try {
              final materials = await getLessonMaterials(lesson.lessonId);
              return lesson.copyWith(materials: materials);
            } on Object {
              return lesson;
            }
          }),
        );
        return module.copyWith(lessons: lessons);
      }),
    );

    return CourseContentModel.fromStructure(course: model.course, modules: modules);
  }

  @override
  Future<List<EnrollmentModel>> getLearnerEnrollments(String userId) async {
    final response = await _dio.get<dynamic>(ApiEndpoints.learnerEnrollments(userId));
    final data = _unwrapApiData(response.data);
    if (data is! List) return const [];
    return data.whereType<Object>().map(castJsonMap).map(EnrollmentModel.fromJson).toList();
  }

  @override
  Future<List<CourseSessionModel>> getCourseSessions(String courseId) async {
    final response = await _dio.get<dynamic>(ApiEndpoints.courseSessions(courseId));
    final data = _unwrapApiData(response.data);
    if (data is! List) return const [];
    return data.whereType<Map<String, dynamic>>().map(CourseSessionModel.fromJson).toList();
  }
}

Object? _unwrapApiData(Object? value) {
  if (value is Map) {
    final map = castJsonMap(value);
    return map.containsKey('data') ? map['data'] : map;
  }
  return value;
}
