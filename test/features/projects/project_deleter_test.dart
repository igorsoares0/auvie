import 'dart:io';

import 'package:auvie/core/storage/app_paths.dart';
import 'package:auvie/core/storage/database.dart';
import 'package:auvie/core/storage/project_repository.dart';
import 'package:auvie/features/projects/project_deleter.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_media_engine.dart';
import '../../helpers/fixtures.dart';

void main() {
  late AuvieDatabase db;
  late ProjectRepository repository;
  late FakeMediaEngine engine;
  late Directory root;
  late ProjectDeleter deleter;
  var nextId = 0;

  setUp(() {
    db = AuvieDatabase(NativeDatabase.memory());
    repository = ProjectRepository(db, newId: () => 'p${nextId++}');
    engine = FakeMediaEngine();
    root = Directory.systemTemp.createTempSync('deleter_');
    deleter = ProjectDeleter(
      repository: repository,
      engine: engine,
      paths: Future.value(AppPaths(root)),
    );
  });

  tearDown(() async {
    await db.close();
    root.deleteSync(recursive: true);
  });

  test(
    'deletes the project, its thumbnail and its hold on the original',
    () async {
      final project = await repository.create(photoMedia);
      final thumbnail = AppPaths(root).previewFor(project.id)
        ..createSync(recursive: true);

      await deleter.delete(id: project.id, mediaUri: photoMedia.uri);

      expect(await repository.find(project.id), isNull);
      expect(thumbnail.existsSync(), isFalse);
      expect(engine.released, [photoMedia.uri]);
    },
  );

  test('keeps the hold while another edit uses the same original', () async {
    final a = await repository.create(photoMedia);
    final b = await repository.create(photoMedia);

    await deleter.delete(id: a.id, mediaUri: photoMedia.uri);
    expect(engine.released, isEmpty);

    await deleter.delete(id: b.id, mediaUri: photoMedia.uri);
    expect(engine.released, [photoMedia.uri]);
  });
}
