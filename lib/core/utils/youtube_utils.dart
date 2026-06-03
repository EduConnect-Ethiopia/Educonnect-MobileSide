class YouTubeUtils {
  YouTubeUtils._();

  static String? extractVideoId(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return null;
    if (_looksLikeVideoId(trimmed)) return trimmed;

    final uri = Uri.tryParse(trimmed);
    if (uri == null) return null;

    if (!uri.hasScheme) {
      final candidate = uri.pathSegments.isNotEmpty
          ? uri.pathSegments.last
          : uri.path;
      if (_looksLikeVideoId(candidate)) return candidate;
    }

    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    }

    if (uri.host.contains('youtube.com')) {
      final v = uri.queryParameters['v'];
      if (v != null && v.isNotEmpty) return v;
      final segments = uri.pathSegments;
      if (segments.contains('embed') && segments.length > 1) {
        return segments[segments.indexOf('embed') + 1];
      }
      if (segments.contains('shorts') && segments.length > 1) {
        return segments.last;
      }
    }

    final regExp = RegExp(
      r'(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})',
    );
    final match = regExp.firstMatch(trimmed);
    return match?.group(1);
  }

  static bool _looksLikeVideoId(String value) {
    return RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(value.trim());
  }
}
