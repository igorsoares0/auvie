import 'dart:io';

import 'package:auvie/app/settings/app_settings.dart';
import 'package:auvie/core/content/catalog.dart';
import 'package:auvie/core/models/project.dart';
import 'package:auvie/core/storage/app_paths.dart';
import 'package:auvie/core/storage/database.dart';
import 'package:auvie/core/storage/project_repository.dart';
import 'package:auvie/features/editor/elements/element_assets.dart';
import 'package:auvie/features/projects/project_starter.dart';
import 'package:auvie/features/projects/project_thumbnails.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fake_media_engine.dart';
import '../../helpers/fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory root;
  late AuvieDatabase db;
  late ProjectRepository repository;
  late FakeMediaEngine engine;
  late ProjectStarter starter;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('auvie_starter_');
    final paths = AppPaths(root);
    await paths.ensureCreated();
    db = AuvieDatabase(NativeDatabase.memory());
    repository = ProjectRepository(db);
    engine = FakeMediaEngine(picked: photoMedia);
    SharedPreferences.setMockInitialValues({});
    starter = ProjectStarter(
      engine: engine,
      repository: repository,
      thumbnails: ProjectThumbnails(
        engine: engine,
        repository: repository,
        paths: Future.value(paths),
        assets: Future.value(
          const ElementAssets(catalog: Catalog(catalogVersion: 1)),
        ),
      ),
      settings: AppSettings(await SharedPreferences.getInstance()),
    );
  });

  tearDown(() async {
    await db.close();
    await root.delete(recursive: true);
  });

  test('a cancelled pick creates nothing', () async {
    engine.picked = null;
    expect(await starter.start(MediaType.photo), isNull);
    expect(await repository.watchRecent().first, isEmpty);
  });

  test('creates a named project with a developed thumbnail', () async {
    final project = await starter.start(MediaType.photo);

    expect(project!.name, 'Roll 001 · 01');
    expect(project.media, photoMedia);
    expect(engine.calls, contains('renderPhoto(${photoMedia.uri}, 360)'));

    final summary = (await repository.watchRecent().first).single;
    expect(summary.name, 'Roll 001 · 01');
    expect(File(summary.thumbnailPath!).existsSync(), isTrue);
  });

  test('videos use the first frame as thumbnail', () async {
    engine.picked = videoMedia;
    final project = await starter.start(MediaType.video);
    expect(project!.edit.video, isNotNull);
    expect(
      engine.calls,
      contains('renderVideoFrame(${videoMedia.uri}, 360, 0)'),
    );
  });

  test('frames keep counting', () async {
    await starter.start(MediaType.photo);
    final second = await starter.start(MediaType.photo);
    expect(second!.name, 'Roll 001 · 02');
  });
}
