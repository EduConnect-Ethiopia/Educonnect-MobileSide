import 'dart:async';

import 'package:flutter/foundation.dart';

class SearchDebouncer {
  Timer? _timer;

  void run(VoidCallback action, {Duration duration = const Duration(milliseconds: 400)}) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  void dispose() => _timer?.cancel();
}
