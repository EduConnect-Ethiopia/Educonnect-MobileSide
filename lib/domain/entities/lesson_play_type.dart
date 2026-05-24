import 'course_content.dart';

enum LessonPlayType { video, article, quiz, assignment, live, unknown }

extension LessonPlayTypeExtension on Lesson {
  LessonPlayType get playType {
    if (materials.any((m) => m.isVideo)) return LessonPlayType.video;
    if (materials.any((m) => m.isQuiz)) return LessonPlayType.quiz;
    if (materials.any((m) => m.isArticle)) return LessonPlayType.article;
    if (materials.any((m) => m.isFile)) return LessonPlayType.assignment;
    return LessonPlayType.unknown;
  }

  Material? get primaryMaterial {
    if (materials.isEmpty) return null;
    final sorted = List<Material>.from(materials)
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    return sorted.first;
  }

  String? get videoUrl {
    final video = materials.where((m) => m.isVideo).toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    if (video.isEmpty) return null;
    return video.first.fullContentUrl;
  }

  String? get articleHtml {
    final articles = materials.where((m) => m.isArticle).toList();
    if (articles.isEmpty) return summary;
    return articles.first.textContent ?? articles.first.description;
  }

  bool get hasAttachments =>
      materials.any((m) => m.isFile && m.fullContentUrl.isNotEmpty);
}
