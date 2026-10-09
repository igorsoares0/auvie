import 'dart:convert';

import 'package:auvie/core/models/project.dart';
import 'package:auvie/core/storage/project_codec.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fixtures.dart';

void main() {
  const codec = ProjectCodec();

  test('round-trips a project with every kind of edit', () {
    final project = richProject();
    expect(codec.decode(codec.encode(project)), project);
  });

  test('keeps UTC timestamps with milliseconds', () {
    final decoded = codec.decode(codec.encode(richProject()));
    expect(decoded.updatedAt.isUtc, isTrue);
    expect(decoded.updatedAt.millisecond, 250);
  });

  test('writes the schema version', () {
    final json = jsonDecode(codec.encode(richProject())) as Map;
    expect(json['schemaVersion'], projectSchemaVersion);
  });

  group('migrations', () {
    Map<String, dynamic> v1Json() {
      final json = richProject().toJson()
        ..['schemaVersion'] = 1
        ..['title'] = 'Old title';
      return json..remove('name');
    }

    final calls = <int>[];
    final migrating = ProjectCodec(
      currentVersion: 3,
      migrations: {
        1: (json) {
          calls.add(1);
          return {...json, 'name': json.remove('title')};
        },
        2: (json) {
          calls.add(2);
          return json;
        },
      },
    );

    setUp(calls.clear);

    test('upgrades step by step from an older version', () {
      final project = migrating.decode(jsonEncode(v1Json()));
      expect(project.name, 'Old title');
      expect(calls, [1, 2]);
    });

    test('runs only the steps a version needs', () {
      final json = richProject().toJson()..['schemaVersion'] = 2;
      migrating.decode(jsonEncode(json));
      expect(calls, [2]);
    });

    test('fails when a step is missing', () {
      const gap = ProjectCodec(currentVersion: 2);
      expect(
        () => gap.decode(jsonEncode(v1Json())),
        throwsA(isA<ProjectFormatException>()),
      );
    });
  });

  group('rejects', () {
    void expectRejected(String source) => expect(
      () => codec.decode(source),
      throwsA(isA<ProjectFormatException>()),
    );

    test('projects saved by a newer app', () {
      final json = richProject().toJson()..['schemaVersion'] = 99;
      expectRejected(jsonEncode(json));
    });

    test('a missing or invalid schema version', () {
      expectRejected(jsonEncode(richProject().toJson()));
      expectRejected(
        jsonEncode(richProject().toJson()..['schemaVersion'] = 'one'),
      );
    });

    test('text that is not a JSON object', () {
      expectRejected('not json');
      expectRejected('[1, 2]');
    });

    test('missing required fields', () {
      expectRejected(jsonEncode({'schemaVersion': 1, 'id': 'x'}));
    });
  });

  test('exception message names the cause', () {
    const e = ProjectFormatException('bad', 'cause');
    expect(e.toString(), 'ProjectFormatException: bad (cause)');
    expect(
      const ProjectFormatException('bad').toString(),
      'ProjectFormatException: bad',
    );
  });

  test('photo projects have no video timeline in JSON', () {
    final photo = Project(
      id: 'p',
      media: photoMedia,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
    expect(codec.decode(codec.encode(photo)).edit.video, isNull);
  });
}
