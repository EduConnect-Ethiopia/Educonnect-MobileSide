import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/course_content.dart';
import '../../domain/entities/course_session.dart';
import '../../domain/entities/lesson_play_type.dart';
import '../widgets/html_content_widget.dart';
import '../widgets/youtube_player_widget.dart';
import '../screens/assessments/assessment_player_screen.dart';
import '../../domain/entities/assessment.dart';

abstract class LessonPlayerController {
  Widget buildPlayer(BuildContext context);
  void dispose();
}

class VideoLessonController implements LessonPlayerController {
  VideoLessonController({
    required this.lesson,
    required this.onComplete,
    this.initialPositionSeconds = 0,
    this.onPositionChanged,
  });

  final Lesson lesson;
  final VoidCallback onComplete;
  final int initialPositionSeconds;
  final void Function(int positionSeconds)? onPositionChanged;

  @override
  Widget buildPlayer(BuildContext context) {
    return YouTubePlayerWidget(
      videoUrl: lesson.videoUrl ?? '',
      title: lesson.title,
      initialPositionSeconds: initialPositionSeconds,
      onVideoComplete: onComplete,
      onPositionChanged: onPositionChanged,
    );
  }

  @override
  void dispose() {}
}

class LiveLessonController implements LessonPlayerController {
  LiveLessonController({required this.session});

  final CourseSession session;

  @override
  Widget buildPlayer(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.video_call, size: 64),
            const SizedBox(height: 24),
            Text(
              'Live Class: ${session.title}',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text('Scheduled: ${_formatDateTime(session.startTime)}'),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.open_in_browser),
              label: const Text('Join Live Class'),
              onPressed: _joinLiveClass,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _joinLiveClass() async {
    final url = session.meetingUrl;
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
        '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {}
}

class ArticleLessonController implements LessonPlayerController {
  ArticleLessonController({
    required this.lesson,
    required this.onOpenFile,
  });

  final Lesson lesson;
  final Future<void> Function(String materialId) onOpenFile;

  @override
  Widget buildPlayer(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HtmlContentWidget(htmlContent: lesson.articleHtml ?? lesson.summary),
          if (lesson.hasAttachments) ...[
            const SizedBox(height: 24),
            Text(
              'Attachments',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...lesson.materials
                .where((m) => m.isFile)
                .map(
                  (m) => ListTile(
                    leading: const Icon(Icons.attach_file),
                    title: Text(m.description),
                    onTap: () => onOpenFile(m.id),
                  ),
                ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {}
}

class QuizLessonController implements LessonPlayerController {
  QuizLessonController({
    required this.lesson,
    required this.assessment,
    required this.onComplete,
  });

  final Lesson lesson;
  final Assessment assessment;
  final VoidCallback onComplete;

  @override
  Widget buildPlayer(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.quiz, size: 64),
            const SizedBox(height: 16),
            Text(
              lesson.title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(assessment.description),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => AssessmentPlayerScreen(
                      assessment: assessment,
                      onPassed: onComplete,
                    ),
                  ),
                );
              },
              child: const Text('Start Quiz'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {}
}

class AssignmentLessonController implements LessonPlayerController {
  AssignmentLessonController({
    required this.lesson,
    required this.onOpenFile,
  });

  final Lesson lesson;
  final Future<void> Function(String materialId) onOpenFile;

  @override
  Widget buildPlayer(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(lesson.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Text(lesson.summary),
          const SizedBox(height: 16),
          ...lesson.materials.where((m) => m.isFile).map(
                (m) => ListTile(
                  leading: const Icon(Icons.assignment),
                  title: Text(m.description),
                  subtitle: const Text('Tap to open'),
                  onTap: () => onOpenFile(m.id),
                ),
              ),
        ],
      ),
    );
  }

  @override
  void dispose() {}
}

class LessonPlayerControllerFactory {
  static LessonPlayerController create({
    required Lesson lesson,
    required VoidCallback onComplete,
    CourseSession? liveSession,
    Assessment? quizAssessment,
    int initialVideoPosition = 0,
    void Function(int positionSeconds)? onPositionChanged,
    required Future<void> Function(String materialId) onOpenFile,
  }) {
    if (liveSession != null) {
      return LiveLessonController(session: liveSession);
    }

    switch (lesson.playType) {
      case LessonPlayType.video:
        return VideoLessonController(
          lesson: lesson,
          onComplete: onComplete,
          initialPositionSeconds: initialVideoPosition,
          onPositionChanged: onPositionChanged,
        );
      case LessonPlayType.live:
        throw StateError('Live lessons require a CourseSession');
      case LessonPlayType.article:
        return ArticleLessonController(lesson: lesson, onOpenFile: onOpenFile);
      case LessonPlayType.quiz:
        if (quizAssessment == null) {
          throw StateError('Quiz lessons require an Assessment');
        }
        return QuizLessonController(
          lesson: lesson,
          assessment: quizAssessment,
          onComplete: onComplete,
        );
      case LessonPlayType.assignment:
        return AssignmentLessonController(lesson: lesson, onOpenFile: onOpenFile);
      case LessonPlayType.unknown:
        return ArticleLessonController(lesson: lesson, onOpenFile: onOpenFile);
    }
  }
}
