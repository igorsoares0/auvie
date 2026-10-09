import 'dart:convert';

import 'package:auvie/core/models/edit_state.dart';
import 'package:auvie/core/models/project.dart';
import 'package:auvie/core/models/video_timeline.dart';
import 'package:auvie/core/storage/database.dart';
import 'package:auvie/core/storage/project_codec.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// What the Home "recent" grid needs.
typedef ProjectSummary = ({
  String id,
  MediaType mediaType,
  String mediaUri,
  String? thumbnailPath,
  DateTime updatedAt,
  String? name,
  String? presetId,
  int? durationMs,
});

/// Local projects (spec §9, §37). Times are stored in UTC.
class ProjectRepository {
  new(
    this._db, {
    this._codec = const ProjectCodec(),
    this._clock = DateTime.now,
    String Function()? newId,
  }) : _newId = newId ?? const Uuid().v4;

  final AuvieDatabase _db;
  final ProjectCodec _codec;
  final DateTime Function() _clock;
  final String Function() _newId;

  /// Creates a project for freshly picked [media]. Videos get a timeline.
  Future<Project> create(MediaRef media, {String? name}) async {
    final now = _clock().toUtc();
    final project = Project(
      id: _newId(),
      media: media,
      name: name,
      createdAt: now,
      updatedAt: now,
      edit: EditState(
        video: media.type == MediaType.video ? const VideoTimeline() : null,
      ),
    );
    await _db.into(_db.projects).insert(_toRow(project));
    return project;
  }

  /// Throws [ProjectFormatException] if the stored edit can't be read.
  Future<Project?> find(String id) async {
    final row = await (_db.select(
      _db.projects,
    )..where((p) => p.id.equals(id))).getSingleOrNull();
    return row == null ? null : _codec.decode(row.data);
  }

  /// Saves [project] with a new `updatedAt` and returns what was saved.
  Future<Project> save(Project project) async {
    final saved = project.copyWith(updatedAt: _clock().toUtc());
    await (_db.update(
      _db.projects,
    )..where((p) => p.id.equals(project.id))).write(
      ProjectsCompanion(
        data: Value(_codec.encode(saved)),
        updatedAt: Value(saved.updatedAt),
      ),
    );
    return saved;
  }

  Future<void> setThumbnail(String id, String? path) =>
      (_db.update(_db.projects)..where((p) => p.id.equals(id))).write(
        ProjectsCompanion(thumbnailPath: Value(path)),
      );

  Future<void> delete(String id) =>
      (_db.delete(_db.projects)..where((p) => p.id.equals(id))).go();

  /// Most recently edited first.
  Stream<List<ProjectSummary>> watchRecent({int limit = 30}) {
    final query = _db.select(_db.projects)
      ..orderBy([(p) => OrderingTerm.desc(p.updatedAt)])
      ..limit(limit);
    return query.watch().map((rows) => [for (final row in rows) _summary(row)]);
  }

  /// Reads the few edit fields the grid shows straight from the JSON, so an
  /// unreadable edit still lists (and can be opened to see the error).
  static ProjectSummary _summary(ProjectRow row) {
    String? name;
    String? presetId;
    int? durationMs;
    try {
      final json = jsonDecode(row.data) as Map<String, dynamic>;
      name = json['name'] as String?;
      durationMs =
          (json['media'] as Map<String, dynamic>?)?['durationMs'] as int?;
      final edit = json['edit'] as Map<String, dynamic>?;
      presetId =
          (edit?['preset'] as Map<String, dynamic>?)?['presetId'] as String?;
    } on Object {
      // Listed without the extras.
    }
    return (
      id: row.id,
      mediaType: row.mediaType,
      mediaUri: row.mediaUri,
      thumbnailPath: row.thumbnailPath,
      updatedAt: row.updatedAt.toUtc(),
      name: name,
      presetId: presetId,
      durationMs: durationMs,
    );
  }

  ProjectsCompanion _toRow(Project project) => ProjectsCompanion.insert(
    id: project.id,
    mediaUri: project.media.uri,
    mediaType: project.media.type,
    data: _codec.encode(project),
    createdAt: project.createdAt,
    updatedAt: project.updatedAt,
  );
}
