import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../../../domain/entities/course.dart';
import '../../../domain/entities/course_content.dart';

class CourseCacheLocalDataSource {
  static const _courseContentBoxName = 'course_content_cache';
  static const _materialFileBoxName = 'material_file_cache';

  Box<String> get _courseContentBox => Hive.box<String>(_courseContentBoxName);
  Box<String> get _materialFileBox => Hive.box<String>(_materialFileBoxName);

  Future<void> saveCourseContent(String courseId, CourseContent content) async {
    await _courseContentBox.put(courseId, jsonEncode(_serializeContent(content)));
  }

  CourseContent? getCourseContent(String courseId) {
    final raw = _courseContentBox.get(courseId);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      return _deserializeContent(decoded);
    } on Object {
      return null;
    }
  }

  Future<void> saveMaterialFilePath(String materialId, String filePath) async {
    await _materialFileBox.put(materialId, filePath);
  }

  String? getMaterialFilePath(String materialId) {
    final path = _materialFileBox.get(materialId);
    if (path == null || path.isEmpty) {
      return null;
    }
    return path;
  }

  Future<void> clearCourseContent(String courseId) async {
    await _courseContentBox.delete(courseId);
  }

  Future<void> clearMaterialFilePath(String materialId) async {
    await _materialFileBox.delete(materialId);
  }

  Map<String, dynamic> _serializeContent(CourseContent content) {
    return {
      'course': _serializeCourse(content.course),
      'modules': content.modules.map(_serializeModule).toList(),
    };
  }

  CourseContent _deserializeContent(Map<String, dynamic> json) {
    final courseJson = json['course'];
    final modulesJson = json['modules'];

    final course = _deserializeCourse(
      courseJson is Map<String, dynamic> ? courseJson : const {},
    );
    final modules = modulesJson is List
        ? modulesJson
            .whereType<Map<String, dynamic>>()
            .map(_deserializeModule)
            .toList()
        : <Module>[];

    return CourseContent(course: course, modules: modules);
  }

  Map<String, dynamic> _serializeCourse(Course course) {
    return {
      'id': course.id,
      'title': course.title,
      'description': course.description,
      'category': course.category,
      'mode': course.mode,
      'status': course.status,
      'price': course.price,
      'instructor': course.instructor,
      'thumbnailUrl': course.thumbnailUrl,
      'progress': course.progress,
      'enrolledAt': course.enrolledAt?.toIso8601String(),
      'enrollmentId': course.enrollmentId,
      'enrollmentStatus': course.enrollmentStatus,
    };
  }

  Course _deserializeCourse(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      mode: (json['mode'] as num?)?.toInt() ?? 0,
      status: (json['status'] as num?)?.toInt() ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      instructor: json['instructor'] as String? ?? '',
      thumbnailUrl: json['thumbnailUrl'] as String?,
      progress: (json['progress'] as num?)?.toDouble() ?? 0,
      enrolledAt: _parseDate(json['enrolledAt']),
      enrollmentId: json['enrollmentId'] as String?,
      enrollmentStatus: (json['enrollmentStatus'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> _serializeModule(Module module) {
    return {
      'id': module.id,
      'courseId': module.courseId,
      'title': module.title,
      'description': module.description,
      'orderIndex': module.orderIndex,
      'lessons': module.lessons.map(_serializeLesson).toList(),
    };
  }

  Module _deserializeModule(Map<String, dynamic> json) {
    final lessonsJson = json['lessons'];
    final lessons = lessonsJson is List
        ? lessonsJson
            .whereType<Map<String, dynamic>>()
            .map(_deserializeLesson)
            .toList()
        : <Lesson>[];

    return Module(
      id: json['id'] as String? ?? '',
      courseId: json['courseId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      orderIndex: (json['orderIndex'] as num?)?.toInt() ?? 0,
      lessons: lessons,
    );
  }

  Map<String, dynamic> _serializeLesson(Lesson lesson) {
    return {
      'id': lesson.id,
      'moduleId': lesson.moduleId,
      'title': lesson.title,
      'summary': lesson.summary,
      'orderIndex': lesson.orderIndex,
      'materials': lesson.materials.map(_serializeMaterial).toList(),
      'isCompleted': lesson.isCompleted,
    };
  }

  Lesson _deserializeLesson(Map<String, dynamic> json) {
    final materialsJson = json['materials'];
    final materials = materialsJson is List
        ? materialsJson
            .whereType<Map<String, dynamic>>()
            .map(_deserializeMaterial)
            .toList()
        : <Material>[];

    return Lesson(
      id: json['id'] as String? ?? '',
      moduleId: json['moduleId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      orderIndex: (json['orderIndex'] as num?)?.toInt() ?? 0,
      materials: materials,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> _serializeMaterial(Material material) {
    return {
      'id': material.id,
      'lessonId': material.lessonId,
      'type': material.type,
      'description': material.description,
      'textContent': material.textContent,
      'contentUrl': material.contentUrl,
      'orderIndex': material.orderIndex,
    };
  }

  Material _deserializeMaterial(Map<String, dynamic> json) {
    return Material(
      id: json['id'] as String? ?? '',
      lessonId: json['lessonId'] as String? ?? '',
      type: (json['type'] as num?)?.toInt() ?? 0,
      description: json['description'] as String? ?? '',
      textContent: json['textContent'] as String?,
      contentUrl: json['contentUrl'] as String?,
      orderIndex: (json['orderIndex'] as num?)?.toInt() ?? 0,
    );
  }

  DateTime? _parseDate(Object? value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
