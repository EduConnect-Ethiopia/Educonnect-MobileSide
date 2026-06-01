import '../../core/constants/backend_enum_values.dart';
import '../../core/config/app_environment.dart';
import '../../core/utils/json_map.dart';
import '../../domain/entities/course.dart';
import '../../domain/entities/enrollment.dart';
import '../../domain/entities/course_content.dart';

class CourseModel {
  const CourseModel({
    required this.courseId,
    required this.title,
    required this.description,
    required this.category,
    required this.mode,
    required this.price,
    required this.courseStatus,
    this.thumbnailUrl,
    this.createdAt,
    this.updatedAt,
  });

  final String courseId;
  final String title;
  final String description;
  final String category;
  final int mode;
  final double price;
  final int courseStatus;
  final String? thumbnailUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory CourseModel.fromJson(JsonMap json) {
    final data = findMap(json, const ['data', 'result']) ?? json;
    return CourseModel(
      courseId: findString(data, const ['courseId', 'id']) ?? '',
      title: findString(data, const ['title']) ?? 'Untitled course',
      description: findString(data, const ['description']) ?? '',
      category: findString(data, const ['category']) ?? 'General',
      mode: _readInt(data['mode']) ?? BackendEnumValues.modeSelfPaced,
      price: _readDouble(data['price']) ?? 0,
      courseStatus: _readInt(data['courseStatus']) ?? BackendEnumValues.courseStatusDraft,
      createdAt: parseDateTime(data['createdAt']),
      updatedAt: _parseBackendDate(data['updatedAt']),
    );
  }

  Course toEntity({double progress = 0, DateTime? enrolledAt}) {
    return Course(
      id: courseId,
      title: title,
      description: description,
      category: category,
      mode: mode,
      status: courseStatus,
      price: price,
      instructor: 'EduConnect Instructor',
      thumbnailUrl: thumbnailUrl,
      progress: progress,
      enrolledAt: enrolledAt,
    );
  }
}

class EnrollmentModel {
  const EnrollmentModel({
    required this.enrollmentId,
    required this.learnerId,
    required this.courseId,
    required this.enrollmentStatus,
    this.enrolledAt,
  });

  final String enrollmentId;
  final String learnerId;
  final String courseId;
  final int enrollmentStatus;
  final DateTime? enrolledAt;

  factory EnrollmentModel.fromJson(JsonMap json) {
    final data = findMap(json, const ['data', 'result']) ?? json;
    return EnrollmentModel(
      enrollmentId: findString(data, const ['enrollmentId', 'id']) ?? '',
      learnerId: findString(data, const ['learnerId', 'userId']) ?? '',
      courseId: findString(data, const ['courseId']) ?? '',
      enrollmentStatus: _readInt(data['enrollmentStatus']) ?? BackendEnumValues.enrollmentDropped,
      enrolledAt: parseDateTime(data['enrolledAt']),
    );
  }

  Enrollment toEntity() {
    return Enrollment(
      id: enrollmentId,
      learnerId: learnerId,
      courseId: courseId,
      status: enrollmentStatus,
      enrolledAt: enrolledAt,
    );
  }
}

class ModuleModel {
  const ModuleModel({
    required this.moduleId,
    required this.courseId,
    required this.title,
    required this.description,
    required this.orderIndex,
    required this.moduleStatus,
    this.lessons = const [],
    this.createdAt,
    this.updatedAt,
  });

  final String moduleId;
  final String courseId;
  final String title;
  final String description;
  final int orderIndex;
  final int moduleStatus;
  final List<LessonModel> lessons;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory ModuleModel.fromJson(JsonMap json) {
    final data = findMap(json, const ['data', 'result']) ?? json;
    return ModuleModel(
      moduleId: findString(data, const ['moduleId', 'id']) ?? '',
      courseId: findString(data, const ['courseId']) ?? '',
      title: findString(data, const ['title']) ?? 'Untitled module',
      description: findString(data, const ['description']) ?? '',
      orderIndex: _readInt(data['orderIndex']) ?? 0,
      moduleStatus: _readInt(data['moduleStatus']) ?? 0,
      lessons: const [],
      createdAt: parseDateTime(data['createdAt']),
      updatedAt: _parseBackendDate(data['updatedAt']),
    );
  }

  Module toEntity() {
    return Module(
      id: moduleId,
      courseId: courseId,
      title: title,
      description: description,
      orderIndex: orderIndex,
      lessons: lessons.map((l) => l.toEntity()).toList(),
    );
  }

  ModuleModel copyWith({
    String? moduleId,
    String? courseId,
    String? title,
    String? description,
    int? orderIndex,
    int? moduleStatus,
    List<LessonModel>? lessons,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ModuleModel(
      moduleId: moduleId ?? this.moduleId,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      description: description ?? this.description,
      orderIndex: orderIndex ?? this.orderIndex,
      moduleStatus: moduleStatus ?? this.moduleStatus,
      lessons: lessons ?? this.lessons,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class LessonModel {
  const LessonModel({
    required this.lessonId,
    required this.moduleId,
    required this.title,
    required this.summary,
    required this.orderIndex,
    required this.lessonStatus,
    this.materials = const [],
    this.createdAt,
    this.updatedAt,
  });

  final String lessonId;
  final String moduleId;
  final String title;
  final String summary;
  final int orderIndex;
  final int lessonStatus;
  final List<MaterialModel> materials;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory LessonModel.fromJson(JsonMap json) {
    final data = findMap(json, const ['data', 'result']) ?? json;
    return LessonModel(
      lessonId: findString(data, const ['lessonId', 'id']) ?? '',
      moduleId: findString(data, const ['moduleId']) ?? '',
      title: findString(data, const ['title']) ?? 'Untitled lesson',
      summary: findString(data, const ['summary', 'description']) ?? '',
      orderIndex: _readInt(data['orderIndex']) ?? 0,
      lessonStatus: _readInt(data['lessonStatus']) ?? 0,
      materials: const [],
      createdAt: parseDateTime(data['createdAt']),
      updatedAt: _parseBackendDate(data['updatedAt']),
    );
  }

  Lesson toEntity() {
    return Lesson(
      id: lessonId,
      moduleId: moduleId,
      title: title,
      summary: summary,
      orderIndex: orderIndex,
      materials: materials.map((m) => m.toEntity()).toList(),
    );
  }

  LessonModel copyWith({
    String? lessonId,
    String? moduleId,
    String? title,
    String? summary,
    int? orderIndex,
    int? lessonStatus,
    List<MaterialModel>? materials,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LessonModel(
      lessonId: lessonId ?? this.lessonId,
      moduleId: moduleId ?? this.moduleId,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      orderIndex: orderIndex ?? this.orderIndex,
      lessonStatus: lessonStatus ?? this.lessonStatus,
      materials: materials ?? this.materials,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class MaterialModel {
  const MaterialModel({
    required this.materialId,
    required this.lessonId,
    required this.materialType,
    required this.description,
    this.textContent,
    this.contentUrl,
    required this.orderIndex,
    required this.materialStatus,
    this.createdAt,
    this.updatedAt,
  });

  final String materialId;
  final String lessonId;
  final int materialType;
  final String description;
  final String? textContent;
  final String? contentUrl;
  final int orderIndex;
  final int materialStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory MaterialModel.fromJson(JsonMap json) {
    final data = findMap(json, const ['data', 'result']) ?? json;
    return MaterialModel(
      materialId: findString(data, const ['materialId', 'id']) ?? '',
      lessonId: findString(data, const ['lessonId']) ?? '',
      materialType: _readInt(data['materialType']) ?? 0,
      description: findString(data, const ['description']) ?? '',
      textContent: findString(data, const ['textContent', 'content']),
      contentUrl: findString(data, const ['contentUrl', 'url', 'filePath']),
      orderIndex: _readInt(data['orderIndex']) ?? 0,
      materialStatus: _readInt(data['materialStatus']) ?? 0,
      createdAt: parseDateTime(data['createdAt']),
      updatedAt: _parseBackendDate(data['updatedAt']),
    );
  }

  Material toEntity() {
    return Material(
      id: materialId,
      lessonId: lessonId,
      type: materialType,
      description: description,
      textContent: textContent,
      contentUrl: contentUrl,
      orderIndex: orderIndex,
    );
  }
}

class CourseContentModel {
  const CourseContentModel({required this.course, required this.modules});

  final CourseModel course;
  final List<ModuleModel> modules;

  factory CourseContentModel.fromJson(JsonMap json) {
    final data = findMap(json, const ['data', 'result']) ?? json;
    final courseData = findMap(data, const ['course']) ?? data;
    final modulesRaw = data['modules'];
    final modulesData = modulesRaw is List ? modulesRaw : const [];

    return CourseContentModel(
      course: CourseModel.fromJson(castJsonMap(courseData)),
      modules: modulesData
          .whereType<Map<String, dynamic>>()
          .map(ModuleModelJson.fromJsonWithNested)
          .toList(),
    );
  }

  factory CourseContentModel.fromStructure({required CourseModel course, required List<ModuleModel> modules}) {
    return CourseContentModel(course: course, modules: modules);
  }

  CourseContent toEntity() {
    return CourseContent(
      course: course.toEntity(),
      modules: modules.map((m) => m.toEntityWithLessons()).toList(),
    );
  }
}

extension ModuleModelLessons on ModuleModel {
  Module toEntityWithLessons() {
    return Module(
      id: moduleId,
      courseId: courseId,
      title: title,
      description: description,
      orderIndex: orderIndex,
      lessons: lessons.map((l) => l.toEntityWithMaterials()).toList(),
    );
  }
}

extension ModuleModelJson on ModuleModel {
  static ModuleModel fromJsonWithNested(JsonMap json) {
    final base = ModuleModel.fromJson(json);
    final lessonsRaw = json['lessons'];
    if (lessonsRaw is! List) return base.copyWith(lessons: const []);
    final lessons = lessonsRaw.whereType<Map<String, dynamic>>().map(LessonModelJson.fromJsonWithNested).toList();
    return base.copyWith(lessons: lessons);
  }
}

extension LessonModelJson on LessonModel {
  static LessonModel fromJsonWithNested(JsonMap json) {
    final base = LessonModel.fromJson(json);
    final materialsRaw = json['materials'];
    if (materialsRaw is! List) return base.copyWith(materials: const []);
    final materials = materialsRaw.whereType<Map<String, dynamic>>().map(MaterialModel.fromJson).toList();
    return base.copyWith(materials: materials);
  }

  Lesson toEntityWithMaterials() {
    return Lesson(
      id: lessonId,
      moduleId: moduleId,
      title: title,
      summary: summary,
      orderIndex: orderIndex,
      materials: materials.map((m) => m.toEntity()).toList(),
    );
  }
}

DateTime? _parseBackendDate(Object? value) {
  final parsed = parseDateTime(value);
  if (parsed == null || parsed.year <= 1) return null;
  return parsed;
}

int? _readInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

double? _readDouble(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
