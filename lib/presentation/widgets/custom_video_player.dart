import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../../core/di/app_providers.dart';

class CustomVideoPlayerWidget extends ConsumerStatefulWidget {
  const CustomVideoPlayerWidget({
    required this.videoUrl,
    this.initialPositionSeconds = 0,
    this.onPositionChanged,
    this.onVideoComplete,
    super.key,
  });

  final String videoUrl;
  final int initialPositionSeconds;
  final void Function(int positionSeconds)? onPositionChanged;
  final VoidCallback? onVideoComplete;

  @override
  ConsumerState<CustomVideoPlayerWidget> createState() =>
      _CustomVideoPlayerWidgetState();
}

class _CustomVideoPlayerWidgetState
    extends ConsumerState<CustomVideoPlayerWidget> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      final tokenStorage = ref.read(tokenStorageProvider);
      final token = tokenStorage.accessToken;

      final headers = <String, String>{};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
        httpHeaders: headers,
      );

      await _videoPlayerController!.initialize();

      if (widget.initialPositionSeconds > 0) {
        await _videoPlayerController!
            .seekTo(Duration(seconds: widget.initialPositionSeconds));
      }

      _videoPlayerController!.addListener(_videoListener);

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: false,
        looping: false,
        allowFullScreen: true,
        allowPlaybackSpeedChanging: true,
        showControls: true,
      );

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  void _videoListener() {
    final controller = _videoPlayerController;
    if (controller == null || !controller.value.isInitialized) return;

    if (widget.onPositionChanged != null) {
      widget.onPositionChanged!(controller.value.position.inSeconds);
    }

    if (controller.value.position == controller.value.duration &&
        controller.value.duration > Duration.zero) {
      if (widget.onVideoComplete != null) {
        widget.onVideoComplete!();
      }
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.removeListener(_videoListener);
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        height: 250,
        color: Colors.black87,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Failed to load video.',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _hasError = false;
                  });
                  _initializePlayer();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_chewieController != null &&
        _chewieController!.videoPlayerController.value.isInitialized) {
      return AspectRatio(
        aspectRatio: _chewieController!.videoPlayerController.value.aspectRatio,
        child: Chewie(
          controller: _chewieController!,
        ),
      );
    } else {
      return Container(
        height: 250,
        color: Colors.black87,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }
}
