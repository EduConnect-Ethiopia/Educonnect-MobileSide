class YouTubeUtils {
  YouTubeUtils._();

  static String? extractVideoId(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return null;
    if (_looksLikeVideoId(trimmed)) return trimmed;

    // A comprehensive regex to find the 11 character YouTube ID.
    // Matches standard watch links, youtu.be shortlinks, shorts, live, embed, and v/ links.
    // It also safely ignores surrounding text, e.g. if the user pasted an iframe embed code.
    final regExp = RegExp(
      r'(?:youtu\.be\/|youtube\.com\/(?:embed\/|v\/|shorts\/|live\/|watch\?[^>]*v=))([a-zA-Z0-9_-]{11})',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(trimmed);
    if (match != null && match.groupCount >= 1) {
      return match.group(1);
    }

    // Fallback: Try parsing as URI to catch unusual query params formats
    final uri = Uri.tryParse(trimmed);
    if (uri != null && uri.host.contains('youtube.com')) {
      final v = uri.queryParameters['v'];
      if (v != null && _looksLikeVideoId(v)) {
        return v;
      }
    }

    return null;
  }

  static bool _looksLikeVideoId(String value) {
    return RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(value.trim());
  }
}
