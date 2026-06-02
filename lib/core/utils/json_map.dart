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

Object? readJsonValue(JsonMap source, List<String> keys) {
  for (final key in keys) {
    if (source.containsKey(key)) {
      return source[key];
    }
    for (final entry in source.entries) {
      if (entry.key.toLowerCase() == key.toLowerCase()) {
        return entry.value;
      }
    }
  }
  return null;
}

String? findString(JsonMap source, List<String> keys) {
  for (final key in keys) {
    final value = readJsonValue(source, [key]);
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    if (value != null) {
      final text = value.toString().trim();
      if (text.isNotEmpty) {
        return text;
      }
    }
  }

  return null;
}

/// Unwraps API list payloads; Dio often returns `Map<dynamic, dynamic>` entries
/// that fail [Iterable.whereType] on [Map<String, dynamic>].
List<JsonMap> unwrapJsonList(Object? value) {
  if (value is List) {
    return value
        .where((item) => item is Map)
        .map((item) => castJsonMap(item))
        .toList();
  }

  if (value is Map) {
    final map = castJsonMap(value);
    for (final key in const ['data', 'items', 'results']) {
      final nested = map[key];
      if (nested is List) {
        return unwrapJsonList(nested);
      }
    }
  }

  return const [];
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
