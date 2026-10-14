import 'dart:io';

import 'package:auvie/core/storage/app_paths.dart';
import 'package:auvie/core/storage/cache_cleaner.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory root;
  late AppPaths paths;
  final now = DateTime(2026, 10, 14, 12);

  setUp(() {
    root = Directory.systemTemp.createTempSync('cache_cleaner_');
    paths = AppPaths(root);
  });

  tearDown(() => root.deleteSync(recursive: true));

  File file(String relative, int bytes, Duration age) {
    return File(p.join(root.path, relative))
      ..createSync(recursive: true)
      ..writeAsBytesSync(List.filled(bytes, 1))
      ..setLastModifiedSync(now.subtract(age));
  }

  CacheCleaner cleaner() => CacheCleaner(Future.value(paths), clock: () => now);

  test('measures exports and leftover layers only', () async {
    file('exports/a.jpg', 100, const Duration(days: 2));
    file('cache/layers/job/0.png', 50, const Duration(hours: 1));
    file('previews/p1.jpg', 999, const Duration(days: 9));
    file('projects/media/x.jpg', 999, const Duration(days: 9));
    expect(await cleaner().size(), 150);
  });

  test('clearing spares files an export may still be writing', () async {
    final old = file('exports/old.jpg', 100, const Duration(hours: 2));
    final running = file('exports/new.mp4', 70, const Duration(minutes: 2));
    final layer = file('cache/layers/job/0.png', 30, const Duration(hours: 1));
    final thumbnail = file('previews/p1.jpg', 10, const Duration(days: 9));

    expect(await cleaner().clear(), 130);

    expect(old.existsSync(), isFalse);
    expect(layer.existsSync(), isFalse);
    expect(
      Directory(p.join(root.path, 'cache/layers/job')).existsSync(),
      isFalse,
    );
    expect(running.existsSync(), isTrue);
    expect(thumbnail.existsSync(), isTrue);
  });

  test('startup housekeeping only takes what is over a day old', () async {
    final stale = file('cache/layers/a/0.png', 10, const Duration(days: 2));
    final fresh = file('exports/b.jpg', 10, const Duration(hours: 3));
    expect(await cleaner().cleanStale(), 10);
    expect(stale.existsSync(), isFalse);
    expect(fresh.existsSync(), isTrue);
  });

  test('missing folders are nothing to clear', () async {
    expect(await cleaner().size(), 0);
    expect(await cleaner().clear(), 0);
  });
}
