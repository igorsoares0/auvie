import 'package:auvie/core/models/adjustment.dart';
import 'package:auvie/core/models/project.dart';
import 'package:auvie/core/models/video_timeline.dart';
import 'package:auvie/core/storage/database.dart';
import 'package:auvie/core/storage/project_codec.dart';
import 'package:auvie/core/storage/project_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fixtures.dart';

void main() {
  late AuvieDatabase db;
  late ProjectRepository repository;
  late DateTime now;
  late int nextId;

  setUp(() {
    db = AuvieDatabase(NativeDatabase.memory());
    now = DateTime.utc(2026, 10, 8, 9);
    nextId = 0;
    repository = ProjectRepository(
      db,
      clock: () => now,
      newId: () => 'p${nextId++}',
    );
  });

  tearDown(() => db.close());

  test('creates a photo project and finds it again', () async {
    final created = await repository.create(photoMedia);

    expect(created.id, 'p0');
    expect(created.media, photoMedia);
    expect(created.createdAt, now);
    expect(created.edit.isUnedited, isTrue);
    expect(created.edit.video, isNull);
    expect(await repository.find('p0'), created);
  });

  test('video projects start with an untrimmed timeline', () async {
    final created = await repository.create(videoMedia);
    expect(created.edit.video, const VideoTimeline());
  });

  test('uses unique ids by default', () async {
    final real = ProjectRepository(db);
    final a = await real.create(photoMedia);
    final b = await real.create(photoMedia);
    expect(a.id, isNot(b.id));
  });

  test('saves edits and bumps updatedAt', () async {
    final created = await repository.create(photoMedia);
    now = now.add(const Duration(minutes: 5));

    final saved = await repository.save(
      created.copyWith(
        edit: created.edit.withAdjustment(Adjustment.exposure, 0.4),
      ),
    );

    expect(saved.updatedAt, now);
    expect(saved.createdAt, created.createdAt);
    expect(await repository.find(created.id), saved);
  });

  test('returns null for unknown projects', () async {
    expect(await repository.find('missing'), isNull);
  });

  test('deletes projects', () async {
    final created = await repository.create(photoMedia);
    await repository.delete(created.id);
    expect(await repository.find(created.id), isNull);
  });

  test('reports unreadable stored edits', () async {
    await db
        .into(db.projects)
        .insert(
          ProjectsCompanion.insert(
            id: 'broken',
            mediaUri: 'content://x',
            mediaType: MediaType.photo,
            data: '{"schemaVersion": 1}',
            createdAt: now,
            updatedAt: now,
          ),
        );
    expect(
      () => repository.find('broken'),
      throwsA(isA<ProjectFormatException>()),
    );
  });

  group('watchRecent', () {
    test('lists most recently edited first, with thumbnails', () async {
      final first = await repository.create(photoMedia);
      now = now.add(const Duration(minutes: 1));
      final second = await repository.create(videoMedia);
      now = now.add(const Duration(minutes: 1));
      await repository.save(first);
      await repository.setThumbnail(first.id, '/previews/p0.jpg');

      final recent = await repository.watchRecent().first;

      expect(recent.map((p) => p.id), [first.id, second.id]);
      expect(recent.first.thumbnailPath, '/previews/p0.jpg');
      expect(recent.first.updatedAt, now);
      expect(recent.last.mediaType, MediaType.video);
      expect(recent.last.mediaUri, videoMedia.uri);
      expect(recent.last.durationMs, videoMedia.durationMs);
    });

    test('lists the name and applied preset', () async {
      final created = await repository.create(
        photoMedia,
        name: 'Roll 001 · 01',
      );
      await repository.save(
        created.copyWith(edit: created.edit.withPreset('ektar_02')),
      );

      final summary = (await repository.watchRecent().first).single;
      expect(summary.name, 'Roll 001 · 01');
      expect(summary.presetId, 'ektar_02');
    });

    test('still lists projects whose edit is unreadable', () async {
      await db
          .into(db.projects)
          .insert(
            ProjectsCompanion.insert(
              id: 'broken',
              mediaUri: 'content://x',
              mediaType: MediaType.photo,
              data: 'not json',
              createdAt: now,
              updatedAt: now,
            ),
          );
      final summary = (await repository.watchRecent().first).single;
      expect(summary.id, 'broken');
      expect(summary.name, isNull);
    });

    test('respects the limit', () async {
      for (var i = 0; i < 5; i++) {
        now = now.add(const Duration(seconds: 1));
        await repository.create(photoMedia);
      }
      final recent = await repository.watchRecent(limit: 3).first;
      expect(recent.map((p) => p.id), ['p4', 'p3', 'p2']);
    });

    test('emits again when projects change', () async {
      final emissions = repository.watchRecent().map((l) => l.length);
      final expectation = expectLater(emissions, emitsInOrder([0, 1]));
      await pumpEventQueue();
      await repository.create(photoMedia);
      await expectation;
    });
  });
}
