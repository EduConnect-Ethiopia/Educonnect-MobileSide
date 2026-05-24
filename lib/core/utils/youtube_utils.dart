class YouTubeUtils {
  YouTubeUtils._();

  static String? extractVideoId(String url) {
    if (url.isEmpty) return null;

    final uri = Uri.tryParse(url);
    if (uri == null) return null;

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
    final match = regExp.firstMatch(url);
    return match?.group(1);
  }
}
