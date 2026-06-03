import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/app_providers.dart';
import '../../../domain/entities/assessment.dart';
import '../../../domain/entities/course.dart';
import '../../../domain/entities/course_content.dart';
import '../../../domain/entities/course_session.dart';
import '../../../domain/entities/lesson_play_type.dart';
import '../../controllers/lesson_player_controller.dart';
import '../../providers/assessment_provider.dart';
import '../../providers/course_detail_provider.dart';
import '../../providers/progress_provider.dart';
import '../../widgets/course_navigation_drawer.dart';

class CoursePlayerScreen extends ConsumerStatefulWidget {
  const CoursePlayerScreen({
    required this.course,
    required this.enrollmentId,
    required this.initialLesson,
    this.liveSession,
    super.key,
  });

  final Course course;
  final String enrollmentId;
  final Lesson initialLesson;
  final CourseSession? liveSession;

  @override
  ConsumerState<CoursePlayerScreen> createState() =>
      _CoursePlayerScreenState();
}

class _CoursePlayerScreenState extends ConsumerState<CoursePlayerScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late Lesson _currentLesson;
  LessonPlayerController? _playerController;
  Map<String, int> _videoPositions = {};

  @override
  void initState() {
    super.initState();
    _currentLesson = widget.initialLesson;
    _loadProgressAndPlayer();
  }

  Future<void> _loadProgressAndPlayer() async {
    final progressRepo = ref.read(progressRepositoryProvider);
    final positions = <String, int>{};
    
    // Also fetch the legacy lesson position in case they are upgrading
    positions[_currentLesson.id] = await progressRepo.getVideoPosition(_currentLesson.id);

    for (final material in _currentLesson.materials) {
      if (material.isVideo || material.isYouTubeVideo) {
        positions[material.id] = await progressRepo.getVideoPosition(material.id);
      }
    }
    
    _videoPositions = positions;

    final content = await ref.read(
      courseContentAsyncProvider(widget.course.id).future,
    );
    if (!mounted) return;

    await ref
        .read(progressControllerProvider.notifier)
        .loadCourseProgress(
          courseId: widget.course.id,
          enrollmentId: widget.enrollmentId,
          content: content,
        );

    _initPlayer(content);
  }

  Future<void> _initPlayer(CourseContent content) async {
    _playerController?.dispose();

    if (!mounted) return;

    setState(() {
      _playerController = LessonPlayerControllerFactory.create(
        lesson: _currentLesson,
        onComplete: _markLessonComplete,
        resolveMaterialAccessUrl: (materialId) async {
          try {
            return ref
                .read(fileAccessRepositoryProvider)
                .createMaterialAccessUrl(materialId);
          } on Object {
            return null;
          }
        },
        liveSession: widget.liveSession,
        getInitialPosition: (materialId) => _videoPositions[materialId] ?? _videoPositions[_currentLesson.id] ?? 0,
        onPositionChanged: (materialId, pos) {
          ref.read(progressRepositoryProvider).saveVideoPosition(
                materialId,
                pos,
              );
          _videoPositions[materialId] = pos;
        },
        onOpenFile: (materialId) async {
          try {
            final accessUrl = await ref
                .read(courseRepositoryProvider)
                .getMaterialAccessUrl(materialId);
            await ref
                .read(materialFileCacheServiceProvider)
                .openOrDownloadMaterial(
                  materialId: materialId,
                  accessUrl: accessUrl,
                );
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to securely access material.')),
              );
            }
          }
        },
      );
    });
  }

  Assessment? _pickAssessmentForLesson(
    List<Assessment> assessments,
    String lessonId,
  ) {
    if (assessments.isEmpty) return null;
    for (final assessment in assessments) {
      if (assessment.lessonId == lessonId) {
        return assessment;
      }
    }
    return assessments.first;
  }

  Future<void> _markLessonComplete() async {
    await ref
        .read(progressControllerProvider.notifier)
        .markLessonComplete(widget.enrollmentId, _currentLesson.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Lesson marked complete!')),
    );
  }

  void _selectLesson(Lesson lesson) {
    setState(() => _currentLesson = lesson);
    ref.read(courseContentAsyncProvider(widget.course.id).future).then(
      (content) {
        if (mounted) _initPlayer(content);
      },
    );
  }

  @override
  void dispose() {
    _playerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contentAsync =
        ref.watch(courseContentAsyncProvider(widget.course.id));
    final progress =
        ref.watch(progressControllerProvider);

    return contentAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: Text(widget.course.title)),
        body: Center(child: Text('Failed to load course: $e')),
      ),
      data: (content) => Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(_currentLesson.title),
          actions: [
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
            ),
          ],
        ),
        endDrawer: CourseNavigationDrawer(
          content: content,
          currentLessonId: _currentLesson.id,
          onLessonSelected: _selectLesson,
          isLessonCompleted: (id) => progress.isLessonCompleted(id),
        ),
        body: _playerController == null
            ? const Center(child: CircularProgressIndicator())
            : _playerController!.buildPlayer(context),
        bottomNavigationBar: _buildBottomBar(progress),
      ),
    );
  }

  Widget? _buildBottomBar(ProgressState progress) {
    final completed = progress.isLessonCompleted(_currentLesson.id);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: ElevatedButton(
          onPressed: completed ? null : _markLessonComplete,
          child: Text(completed ? 'Completed' : 'Mark as Complete'),
        ),
      ),
    );
  }
}
