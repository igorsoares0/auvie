import 'package:auvie/core/models/project.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

/// Project metadata (spec §37). The edit itself is the serialized project in
/// [data]; the other columns exist for listing without decoding it.
@DataClassName('ProjectRow')
class Projects extends Table {
  TextColumn get id => text()();
  TextColumn get mediaUri => text()();
  TextColumn get mediaType => textEnum<MediaType>()();
  TextColumn get data => text()();
  TextColumn get thumbnailPath => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

enum FavoriteKind { preset, collection, sticker }

/// Local favorites (spec §30).
@DataClassName('FavoriteRow')
class Favorites extends Table {
  TextColumn get kind => textEnum<FavoriteKind>()();
  TextColumn get itemId => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {kind, itemId};
}

@DriftDatabase(tables: [Projects, Favorites])
class AuvieDatabase extends _$AuvieDatabase {
  new(super.e);

  /// The on-device database in the app support directory.
  factory open() => AuvieDatabase(
    driftDatabase(
      name: 'auvie',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    ),
  );

  @override
  int get schemaVersion => 1;
}
