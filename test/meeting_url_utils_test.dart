import 'package:flutter_test/flutter_test.dart';

import 'package:educonnect_mobile/core/utils/meeting_url_utils.dart';

void main() {
  test('normalizes bare meeting links to https', () {
    expect(normalizeMeetingUrl('meet.google.com/abc-def-ghi'),
        'https://meet.google.com/abc-def-ghi');
    expect(normalizeMeetingUrl('zoom.us/j/12345'), 'https://zoom.us/j/12345');
    expect(normalizeMeetingUrl('www.zoom.us/j/12345'), 'https://www.zoom.us/j/12345');
  });

  test('keeps explicit https links untouched', () {
    expect(normalizeMeetingUrl('https://us05web.zoom.us/j/12345'),
        'https://us05web.zoom.us/j/12345');
  });
}
