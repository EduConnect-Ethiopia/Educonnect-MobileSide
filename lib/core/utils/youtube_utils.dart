class YouTubeUtils {
  YouTubeUtils._();

  static String? extractVideoId(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return null;
    if (_looksLikeVideoId(trimmed)) return trimmed;

    final uri = Uri.tryParse(trimmed);
    if (uri != null) {
      if (uri.host.contains('youtu.be')) {
        final pathSegments = uri.pathSegments;
        if (pathSegments.isNotEmpty) {
          final videoId = pathSegments.first;
          if (_looksLikeVideoId(videoId)) return videoId;
        }
      }

      if (uri.host.contains('youtube.com')) {
        final v = uri.queryParameters['v'];
        if (v != null && _looksLikeVideoId(v)) return v;

        final pathSegments = uri.pathSegments;
        final embedIndex = pathSegments.indexOf('embed');
        if (embedIndex >= 0 && embedIndex + 1 < pathSegments.length) {
          final videoId = pathSegments[embedIndex + 1];
          if (_looksLikeVideoId(videoId)) return videoId;
        }

        for (final type in <String>['shorts', 'live', 'v']) {
          final index = pathSegments.indexOf(type);
          if (index >= 0 && index + 1 < pathSegments.length) {
            final videoId = pathSegments[index + 1];
            if (_looksLikeVideoId(videoId)) return videoId;
          }
        }
      }
    }

    final fallbackRegExp = RegExp(
      r'(?:youtu\.be\/|youtube\.com\/(?:embed\/|v\/|shorts\/|live\/)|watch\?[^>]*[?&]v=)([a-zA-Z0-9_-]{11})',
      caseSensitive: false,
    );
    final match = fallbackRegExp.firstMatch(trimmed);
    if (match != null && match.groupCount >= 1) {
      return match.group(1);
    }

    return null;
  }

  static bool _looksLikeVideoId(String value) {
    return RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(value.trim());
  }
}