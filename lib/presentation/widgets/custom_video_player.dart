import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../core/di/app_providers.dart';

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
  VideoPlayerController? _vpc;
  ChewieController? _chewie;
  bool _isInitializing = true;
  String? _errorMessage;
  bool _completeFired = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    if (!mounted) return;
    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });

    try {
      final tokenStorage = ref.read(tokenStorageProvider);
      final token = tokenStorage.accessToken;

      final headers = <String, String>{};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      // Dispose previous controllers before creating new ones
      await _disposeControllers();

      final vpc = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
        httpHeaders: headers,
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: false,
          allowBackgroundPlayback: false,
        ),
      );

      await vpc.initialize();

      if (!mounted) {
        await vpc.dispose();
        return;
      }

      if (widget.initialPositionSeconds > 0) {
        final duration = vpc.value.duration;
        final target = Duration(seconds: widget.initialPositionSeconds);
        if (duration > Duration.zero && target < duration - const Duration(seconds: 1)) {
          await vpc.seekTo(target);
        }
      }

      vpc.addListener(_onVideoProgress);

      final chewie = ChewieController(
        videoPlayerController: vpc,
        autoPlay: false,
        looping: false,
        allowFullScreen: true,
        allowPlaybackSpeedChanging: true,
        showControls: true,
        showOptions: true,
        hideControlsTimer: const Duration(seconds: 3),
        // Ensures controls are shown on first render
        autoInitialize: false,
        placeholder: Container(color: Colors.black),
        errorBuilder: (context, errorMessage) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 48),
                const SizedBox(height: 12),
                Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );

      if (!mounted) {
        await vpc.dispose();
        chewie.dispose();
        return;
      }

      setState(() {
        _vpc = vpc;
        _chewie = chewie;
        _isInitializing = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _errorMessage =
              'Failed to load video. Please check your connection and try again.\n\nDetails: $e';
        });
      }
    }
  }

  void _onVideoProgress() {
    final vpc = _vpc;
    if (vpc == null || !vpc.value.isInitialized) return;

    final position = vpc.value.position;
    final duration = vpc.value.duration;

    widget.onPositionChanged?.call(position.inSeconds);

    if (!_completeFired &&
        duration > Duration.zero &&
        position >= duration - const Duration(seconds: 1)) {
      _completeFired = true;
      widget.onVideoComplete?.call();
    }
  }

  Future<void> _disposeControllers() async {
    _vpc?.removeListener(_onVideoProgress);
    _chewie?.dispose();
    await _vpc?.dispose();
    _chewie = null;
    _vpc = null;
  }

  @override
  void dispose() {
    _vpc?.removeListener(_onVideoProgress);
    _chewie?.dispose();
    _vpc?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return Container(
        height: 220,
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text('Loading video...', style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Container(
        height: 220,
        color: Colors.black87,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.redAccent,
                  size: 48,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Video failed to load',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  onPressed: _initializePlayer,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final chewie = _chewie;
    final vpc = _vpc;

    if (chewie == null || vpc == null || !vpc.value.isInitialized) {
      return Container(
        height: 220,
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    final aspectRatio = vpc.value.aspectRatio;
    return LayoutBuilder(
      builder: (context, constraints) {
        return AspectRatio(
          aspectRatio: aspectRatio > 0 ? aspectRatio : 16 / 9,
          child: Chewie(controller: _chewie!),
        );
      }
    );
  }
}
