import 'dart:io';

import 'package:auvie/core/storage/app_paths.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory root;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('auvie_paths_');
  });

  tearDown(() => root.delete(recursive: true));

  test('creates the storage layout of spec §36', () async {
    final paths = AppPaths(root);
    await paths.ensureCreated();

    final names = root.listSync().map((e) => p.basename(e.path)).toSet();
    expect(names, {
      'projects',
      'previews',
      'cache',
      'downloaded_content',
      'exports',
    });
  });

  test('is safe to call twice', () async {
    final paths = AppPaths(root);
    await paths.ensureCreated();
    await paths.ensureCreated();
    expect(paths.all.every((d) => d.existsSync()), isTrue);
  });

  test('places project previews in previews/', () {
    final file = AppPaths(root).previewFor('abc');
    expect(file.path, p.join(root.path, 'previews', 'abc.jpg'));
  });
}
