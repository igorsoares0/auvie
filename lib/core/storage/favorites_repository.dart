import 'package:auvie/core/storage/database.dart';
import 'package:drift/drift.dart';

/// Locally stored favorites (spec §30).
class FavoritesRepository {
  new(this._db, {this._clock = DateTime.now});

  final AuvieDatabase _db;
  final DateTime Function() _clock;

  /// Adds or removes [itemId] and returns whether it is now a favorite.
  Future<bool> toggle(FavoriteKind kind, String itemId) {
    return _db.transaction(() async {
      final removed = await (_db.delete(
        _db.favorites,
      )..where((f) => f.kind.equalsValue(kind) & f.itemId.equals(itemId))).go();
      if (removed > 0) return false;
      await _db
          .into(_db.favorites)
          .insert(
            FavoritesCompanion.insert(
              kind: kind,
              itemId: itemId,
              createdAt: _clock().toUtc(),
            ),
          );
      return true;
    });
  }

  /// Ids of [kind], most recently added first.
  Stream<List<String>> watch(FavoriteKind kind) {
    final query = _db.select(_db.favorites)
      ..where((f) => f.kind.equalsValue(kind))
      ..orderBy([(f) => OrderingTerm.desc(f.createdAt)]);
    return query.watch().map((rows) => [for (final r in rows) r.itemId]);
  }
}
