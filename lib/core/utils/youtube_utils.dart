class YouTubeUtils {
  YouTubeUtils._();

  static String? extractVideoId(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return null;

    final directId = _extractDirectVideoId(trimmed);
    if (directId != null) return directId;

    final uri = Uri.tryParse(trimmed);
    if (uri != null) {
      final host = uri.host.toLowerCase();

      if (host.contains('youtu.be')) {
        final pathSegments = uri.pathSegments;
        for (final segment in pathSegments) {
          if (_looksLikeVideoId(segment)) return segment;
        }
      }

      if (host.contains('youtube.com') || host.contains('m.youtube.com')) {
        final queryVideoId = uri.queryParameters['v'];
        if (_looksLikeVideoId(queryVideoId)) return queryVideoId;

        final pathSegments = uri.pathSegments;
        for (final segment in <String>['embed', 'shorts', 'live', 'watch']) {
          final index = pathSegments.indexOf(segment);
          if (index >= 0 && index + 1 < pathSegments.length) {
            final candidate = pathSegments[index + 1];
            if (_looksLikeVideoId(candidate)) return candidate;
          }
        }
      }
    }

    final fallbackRegExp = RegExp(
      "(?:https?://)?(?:www\\.|m\\.)?(?:youtube\\.com/[^\\s\"']*?[?&]v=|youtube\\.com/(?:embed|shorts|live)/|youtu\\.be/)([a-zA-Z0-9_-]{11})",
      caseSensitive: false,
    );
    final match = fallbackRegExp.firstMatch(trimmed);
    if (match != null && match.groupCount >= 1) {
      return match.group(1);
    }

    return null;
  }

  static String? _extractDirectVideoId(String value) {
    final candidate = value.trim();
    if (_looksLikeVideoId(candidate)) return candidate;

    final shorthand = candidate.replaceFirst(RegExp(r'^(?:https?:\/\/)?(?:www\.|m\.)?youtu\.be\/'), '');
    if (_looksLikeVideoId(shorthand)) return shorthand;

    return null;
  }

  static bool _looksLikeVideoId(String? value) {
    return value != null && RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(value.trim());
  }
}