String normalizeMeetingUrl(String rawUrl) {
  final trimmed = rawUrl.trim();
  if (trimmed.isEmpty) return '';

  final uri = Uri.tryParse(trimmed);
  if (uri != null && uri.hasScheme) {
    if (uri.scheme == 'http' || uri.scheme == 'https') {
      return uri.toString();
    }
    return trimmed;
  }

  if (trimmed.startsWith('www.')) {
    return 'https://$trimmed';
  }

  return 'https://$trimmed';
}
