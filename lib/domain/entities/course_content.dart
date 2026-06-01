import 'course.dart';

class Module {
  const Module({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.orderIndex,
    this.lessons = const [],
  });

  final String id;
  final String courseId;
  final String title;
  final String description;
  final int orderIndex;
  final List<Lesson> lessons;

  Module copyWith({
    String? id,
    String? courseId,
    String? title,
    String? description,
    int? orderIndex,
    List<Lesson>? lessons,
  }) {
    return Module(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      description: description ?? this.description,
      orderIndex: orderIndex ?? this.orderIndex,
      lessons: lessons ?? this.lessons,
    );
  }
}

class Lesson {
  const Lesson({
    required this.id,
    required this.moduleId,
    required this.title,
    required this.summary,
    required this.orderIndex,
    this.materials = const [],
    this.isCompleted = false,
  });

  final String id;
  final String moduleId;
  final String title;
  final String summary;
  final int orderIndex;
  final List<Material> materials;
  final bool isCompleted;

  Lesson copyWith({
    String? id,
    String? moduleId,
    String? title,
    String? summary,
    int? orderIndex,
    List<Material>? materials,
    bool? isCompleted,
  }) {
    return Lesson(
      id: id ?? this.id,
      moduleId: moduleId ?? this.moduleId,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      orderIndex: orderIndex ?? this.orderIndex,
      materials: materials ?? this.materials,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class Material {
  const Material({
    required this.id,
    required this.lessonId,
    required this.type,
    required this.description,
    this.textContent,
    this.contentUrl,
    required this.orderIndex,
  });

  final String id;
  final String lessonId;
  final int type; // 0=Article, 1=File, 2=Image, 3=Quiz, 4=Video
  final String description;
  final String? textContent;
  final String? contentUrl;
  final int orderIndex;

  String get fullContentUrl {
    if (contentUrl == null || contentUrl!.isEmpty) return '';
    return contentUrl!;
  }

  bool get isVideo => type == 4;
  bool get isArticle => type == 0;
  bool get isFile => type == 1;
  bool get isImage => type == 2;
  bool get isQuiz => type == 3;
}

class CourseContent {
  const CourseContent({
    required this.course,
    required this.modules,
  });

  final Course course;
  final List<Module> modules;

  Module? getModuleById(String moduleId) {
    try {
      return modules.firstWhere((m) => m.id == moduleId);
    } catch (_) {
      return null;
    }
  }

  Lesson? getLessonById(String lessonId) {
    for (final module in modules) {
      try {
        return module.lessons.firstWhere((l) => l.id == lessonId);
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  Material? getMaterialById(String materialId) {
    for (final module in modules) {
      for (final lesson in module.lessons) {
        try {
          return lesson.materials.firstWhere((m) => m.id == materialId);
        } catch (_) {
          continue;
        }
      }
    }
    return null;
  }
}
