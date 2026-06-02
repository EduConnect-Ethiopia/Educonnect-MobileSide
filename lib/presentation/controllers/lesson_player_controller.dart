import 'package:flutter/material.dart' hide Material;
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/course_content.dart';
import '../../domain/entities/course_session.dart';
import '../widgets/html_content_widget.dart';
import '../widgets/youtube_player_widget.dart';

abstract class LessonPlayerController {
  Widget buildPlayer(BuildContext context);
  void dispose();
}

typedef MaterialAccessResolver = Future<String?> Function(String materialId);

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

class SequentialLessonController implements LessonPlayerController {
  SequentialLessonController({
    required this.lesson,
    required this.resolveMaterialAccessUrl,
    required this.onOpenFile,
    required this.onComplete,
    this.initialVideoPositionSeconds = 0,
    this.onPositionChanged,
  }) {
    sortedMaterials = List<Material>.from(lesson.materials)
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
  }

  final Lesson lesson;
  final MaterialAccessResolver resolveMaterialAccessUrl;
  final Future<void> Function(String materialId) onOpenFile;
  final VoidCallback onComplete;
  final int initialVideoPositionSeconds;
  final void Function(int positionSeconds)? onPositionChanged;
  late final List<Material> sortedMaterials;

  @override
  Widget buildPlayer(BuildContext context) {
    if (sortedMaterials.isEmpty) {
      return const Center(child: Text('No lesson materials available yet.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: sortedMaterials.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 24),
      itemBuilder: (context, index) {
        if (index == sortedMaterials.length) {
           return const SizedBox(height: 48);
        }
        final material = sortedMaterials[index];
        return _buildMaterialWidget(context, material);
      },
    );
  }

  Widget _buildMaterialWidget(BuildContext context, Material material) {
    if (material.isArticle) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (material.description.isNotEmpty) ...[
            Text(material.description, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
          ],
          HtmlContentWidget(htmlContent: material.textContent ?? ''),
        ],
      );
    }
    
    if (material.isImage) {
      return _buildImageMaterial(context, material);
    }

    if (material.isYouTubeVideo) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (material.description.isNotEmpty) ...[
            Text(material.description, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
          ],
          YouTubePlayerWidget(
            videoUrl: material.fullContentUrl,
            title: material.description,
            initialPositionSeconds: initialVideoPositionSeconds,
            onPositionChanged: onPositionChanged,
            onVideoComplete: () {}, 
          ),
        ],
      );
    }

    if (material.isVideo) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (material.description.isNotEmpty) ...[
            Text(material.description, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
          ],
          Card(
            child: ListTile(
              leading: const Icon(Icons.video_library),
              title: Text(material.description.isEmpty ? 'Video Content' : material.description),
              subtitle: const Text('Tap to view video in native player'),
              onTap: () async {
                 final accessUrl = await resolveMaterialAccessUrl(material.id);
                 if (accessUrl != null && accessUrl.isNotEmpty) {
                    final uri = Uri.parse(accessUrl);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                 }
              },
            )
          )
        ],
      );
    }

    if (material.isFile) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.picture_as_pdf),
          title: Text(material.description.isEmpty ? 'Document/PDF' : material.description),
          subtitle: const Text('Tap to view or download'),
          onTap: () => onOpenFile(material.id),
        ),
      );
    }

    if (material.isExternalLink) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.link),
          title: Text(material.description.isEmpty ? 'External Resource' : material.description),
          subtitle: Text(material.fullContentUrl),
          trailing: const Icon(Icons.open_in_browser),
          onTap: () async {
            if (material.fullContentUrl.isNotEmpty) {
               final uri = Uri.parse(material.fullContentUrl);
               if (await canLaunchUrl(uri)) {
                 await launchUrl(uri, mode: LaunchMode.externalApplication);
               }
            }
          },
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildImageMaterial(BuildContext context, Material material) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (material.description.isNotEmpty) ...[
          Text(material.description, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
        ],
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: EdgeInsets.zero,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    InteractiveViewer(
                      panEnabled: true,
                      minScale: 0.5,
                      maxScale: 4,
                      child: Image.network(
                        material.fullContentUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.error, color: Colors.white)),
                      ),
                    ),
                    Positioned(
                      top: 40,
                      right: 20,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 30),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              material.fullContentUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (_, __, ___) => Container(
                width: double.infinity,
                height: 200,
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {}
}

class LessonPlayerControllerFactory {
  static LessonPlayerController create({
    required Lesson lesson,
    required VoidCallback onComplete,
    required MaterialAccessResolver resolveMaterialAccessUrl,
    CourseSession? liveSession,
    int initialVideoPosition = 0,
    void Function(int positionSeconds)? onPositionChanged,
    required Future<void> Function(String materialId) onOpenFile,
  }) {
    if (liveSession != null) {
      return LiveLessonController(session: liveSession);
    }

    return SequentialLessonController(
      lesson: lesson,
      resolveMaterialAccessUrl: resolveMaterialAccessUrl,
      onOpenFile: onOpenFile,
      onComplete: onComplete,
      initialVideoPositionSeconds: initialVideoPosition,
      onPositionChanged: onPositionChanged,
    );
  }
}
