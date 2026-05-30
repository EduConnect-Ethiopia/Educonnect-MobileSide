import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../core/di/app_providers.dart';
import '../../core/utils/youtube_utils.dart';

class YouTubePlayerWidget extends ConsumerStatefulWidget {
  const YouTubePlayerWidget({
    required this.videoUrl,
    required this.title,
    required this.onVideoComplete,
    this.initialPositionSeconds = 0,
    this.onPositionChanged,
    super.key,
  });

  final String videoUrl;
  final String title;
  final VoidCallback onVideoComplete;
  final int initialPositionSeconds;
  final void Function(int positionSeconds)? onPositionChanged;

  @override
  ConsumerState<YouTubePlayerWidget> createState() =>
      _YouTubePlayerWidgetState();
}

class _YouTubePlayerWidgetState extends ConsumerState<YouTubePlayerWidget> {
  YoutubePlayerController? _controller;
  Timer? _progressTimer;
  bool _completedFired = false;
  double _playbackSpeed = 1;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    final videoId = YouTubeUtils.extractVideoId(widget.videoUrl);
    if (videoId == null) return;

    final controller = YoutubePlayerController(
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        enableCaption: true,
        strictRelatedVideos: true,
      ),
    );

    await controller.cueVideoById(
      videoId: videoId,
      startSeconds: widget.initialPositionSeconds.toDouble(),
    );

    if (!mounted) return;
    setState(() => _controller = controller);
    _startProgressTracking(controller);
  }

  void _startProgressTracking(YoutubePlayerController controller) {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      final current = await controller.currentTime;
      final duration = await controller.duration;
      if (!mounted) return;

      final position = current.floor();
      widget.onPositionChanged?.call(position);

      if (duration > 0 && !_completedFired) {
        final progress = current / duration;
        if (progress >= 0.9) {
          _completedFired = true;
          widget.onVideoComplete();
        }
      }
    });
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _controller?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videoId = YouTubeUtils.extractVideoId(widget.videoUrl);

    if (videoId == null) {
      return Center(
        child: Text('Invalid video URL: ${widget.videoUrl}'),
      );
    }

    if (_controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: YoutubePlayer(
            controller: _controller!,
            aspectRatio: 16 / 9,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Text('Speed:'),
              const SizedBox(width: 8),
              DropdownButton<double>(
                value: _playbackSpeed,
                items: const [0.5, 0.75, 1.0, 1.25, 1.5, 2.0]
                    .map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Text('${s}x'),
                      ),
                    )
                    .toList(),
                onChanged: (speed) async {
                  if (speed == null) return;
                  setState(() => _playbackSpeed = speed);
                  await _controller!.setPlaybackRate(speed);
                },
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Download for offline (metadata)',
                icon: const Icon(Icons.download_outlined),
                onPressed: () => _saveOfflineBookmark(videoId),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            widget.title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ],
    );
  }

  Future<void> _saveOfflineBookmark(String videoId) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString('offline_video_${widget.title}', videoId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Video bookmarked for offline reference.')),
    );
  }
}
