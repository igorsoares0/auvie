import 'dart:convert';

import 'package:auvie/core/models/project.dart';

/// Version of the serialized project format. Bump it and add a migration to
/// [projectMigrations] whenever a change would break reading older JSON.
const projectSchemaVersion = 1;

typedef JsonMigration = Map<String, dynamic> Function(Map<String, dynamic>);

/// Migrations keyed by the version they upgrade *from*.
const Map<int, JsonMigration> projectMigrations = {};

class ProjectFormatException implements Exception {
  const new(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() =>
      'ProjectFormatException: $message'
      '${cause == null ? '' : ' ($cause)'}';
}

/// Serializes projects to JSON with a schema version and upgrades older
/// versions on read.
class ProjectCodec {
  const new({
    this.currentVersion = projectSchemaVersion,
    this.migrations = projectMigrations,
  });

  final int currentVersion;
  final Map<int, JsonMigration> migrations;

  String encode(Project project) =>
      jsonEncode({'schemaVersion': currentVersion, ...project.toJson()});

  Project decode(String source) {
    final Map<String, dynamic> json;
    try {
      json = jsonDecode(source) as Map<String, dynamic>;
    } on Object catch (e) {
      throw ProjectFormatException('Not a project JSON object', e);
    }

    final storedVersion = json.remove('schemaVersion');
    if (storedVersion is! int || storedVersion < 1) {
      throw ProjectFormatException(
        'Missing or invalid schemaVersion: $storedVersion',
      );
    }
    var version = storedVersion;
    if (version > currentVersion) {
      throw ProjectFormatException(
        'Project was saved by a newer app (v$version > v$currentVersion)',
      );
    }

    var upgraded = json;
    while (version < currentVersion) {
      final migrate = migrations[version];
      if (migrate == null) {
        throw ProjectFormatException('No migration from v$version');
      }
      upgraded = migrate(upgraded);
      version++;
    }

    try {
      return Project.fromJson(upgraded);
    } on Object catch (e) {
      throw ProjectFormatException('Invalid project fields', e);
    }
  }
}
