typedef JsonMap = Map<String, dynamic>;

JsonMap castJsonMap(Object? value) {
  if (value is JsonMap) {
    return value;
  }

  if (value is Map) {
    return value.map((key, dynamic mapValue) {
      return MapEntry(key.toString(), mapValue);
    });
  }

  throw const FormatException('Expected a JSON object.');
}

JsonMap? findMap(JsonMap source, List<String> keys) {
  for (final key in keys) {
    final value = source[key];
    if (value is Map) {
      return castJsonMap(value);
    }
  }

  return null;
}

String? findString(JsonMap source, List<String> keys) {
  for (final key in keys) {
    final value = source[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
  }

  return null;
}

DateTime? parseDateTime(Object? value) {
  if (value is String) {
    return DateTime.tryParse(value);
  }

  if (value is int) {
    final milliseconds = value > 1000000000000 ? value : value * 1000;
    return DateTime.fromMillisecondsSinceEpoch(milliseconds, isUtc: true);
  }

  return null;
}
