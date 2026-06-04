import 'package:educonnect_mobile/core/utils/youtube_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('extractVideoId handles standard YouTube watch URLs', () {
    const url = 'https://www.youtube.com/watch?v=w9xKj5PsCnI&t=12s';

    expect(YouTubeUtils.extractVideoId(url), 'w9xKj5PsCnI');
  });

  test('extractVideoId handles youtu.be short links', () {
    const url = 'https://youtu.be/w9xKj5PsCnI';

    expect(YouTubeUtils.extractVideoId(url), 'w9xKj5PsCnI');
  });

  test('extractVideoId handles youtube.com shorts URLs', () {
    const url = 'https://www.youtube.com/shorts/w9xKj5PsCnI';

    expect(YouTubeUtils.extractVideoId(url), 'w9xKj5PsCnI');
  });
}
