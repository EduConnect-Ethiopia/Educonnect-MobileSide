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
  double _playbackSpeed = 1.0;
  bool _isReady = false;
  String? _videoId;
  String? _initError;

  @override
  void initState() {
    super.initState();
    _videoId = YouTubeUtils.extractVideoId(widget.videoUrl);
    if (_videoId != null) {
      _initPlayer(_videoId!);
    } else {
      setState(() {
        _initError = 'Failed to extract video ID from URL';
      });
    }
  }

  Future<void> _initPlayer(String videoId) async {
    // Clean up any existing controller
    _progressTimer?.cancel();
    await _controller?.close();

    try {
      final controller = YoutubePlayerController.fromVideoId(
        videoId: videoId,
        startSeconds: widget.initialPositionSeconds > 0
            ? widget.initialPositionSeconds.toDouble()
            : 0.0,
        autoPlay: true,
        params: const YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: true,
          enableCaption: true,
          strictRelatedVideos: true,
          mute: false,
        ),
      );

      // Listen for player state changes to track readiness
      controller.listen((event) {
        if (!mounted) return;
        
        // Mark as ready when video starts playing or is at any playable state
        if ((event.playerState == PlayerState.playing ||
            event.playerState == PlayerState.paused) && !_isReady) {
          setState(() => _isReady = true);
        }
        
        // Handle video end
        if (event.playerState == PlayerState.ended && !_completedFired) {
          _completedFired = true;
          widget.onVideoComplete();
        }
      });

      if (!mounted) {
        await controller.close();
        return;
      }

      setState(() {
        _controller = controller;
        _isReady = false;
        _completedFired = false;
        _initError = null;
      });

      _startProgressTracking(controller);
    } on Object catch (error) {
      if (mounted) {
        setState(() {
          _initError = 'Error initializing video player: ${error.toString()}';
        });
      }
    }
  }

  void _startProgressTracking(YoutubePlayerController controller) {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(milliseconds: 500), (_) async {
      if (!mounted) return;
      try {
        final current = await controller.currentTime;
        final duration = await controller.duration;

        if (current >= 0) {
          final positionSeconds = current.floor();
          widget.onPositionChanged?.call(positionSeconds);
        }

        // Only fire completion callback when reaching 90% of video
        if (duration > 0 && !_completedFired) {
          final progress = current / duration;
          if (progress >= 0.9) {
            _completedFired = true;
            // No need to call onVideoComplete here since we listen to PlayerState.ended
          }
        }
      } catch (_) {
        // Silently ignore errors from polling — player may have been disposed
      }
    });
  }

  @override
  void didUpdateWidget(YouTubePlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reinitialize if the URL changed
    if (oldWidget.videoUrl != widget.videoUrl) {
      _completedFired = false;
      final newVideoId = YouTubeUtils.extractVideoId(widget.videoUrl);
      if (newVideoId != null && newVideoId != _videoId) {
        _videoId = newVideoId;
        _initPlayer(newVideoId);
      }
    }
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _controller?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videoId = _videoId;

    if (videoId == null || _initError != null) {
      return Container(
        height: 220,
        color: Colors.black,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.link_off, color: Colors.white60, size: 40),
                const SizedBox(height: 12),
                Text(
                  _initError ?? 'Invalid YouTube URL:\n${widget.videoUrl}',
                  style: const TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final controller = _controller;
    if (controller == null) {
      return Container(
        height: 220,
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 12),
              Text('Loading video...', style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            YoutubePlayerControllerProvider(
              controller: controller,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: YoutubePlayer(controller: controller, aspectRatio: 16 / 9),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Speed:',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 8),
                      DropdownButton<double>(
                        value: _playbackSpeed,
                        underline: const SizedBox.shrink(),
                        items: const [0.5, 0.75, 1.0, 1.25, 1.5, 2.0]
                            .map(
                              (s) => DropdownMenuItem(value: s, child: Text('${s}x')),
                            )
                            .toList(),
                        onChanged: (speed) async {
                          if (speed == null) return;
                          setState(() => _playbackSpeed = speed);
                          await controller.setPlaybackRate(speed);
                        },
                      ),
                    ],
                  ),
                  IconButton(
                    tooltip: 'Bookmark video',
                    icon: const Icon(Icons.bookmark_outline),
                    onPressed: () => _saveOfflineBookmark(videoId),
                  ),
                ],
              ),
            ),
            if (widget.title.isNotEmpty)
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
