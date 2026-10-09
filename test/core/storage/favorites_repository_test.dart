import 'package:auvie/core/storage/database.dart';
import 'package:auvie/core/storage/favorites_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AuvieDatabase db;
  late FavoritesRepository favorites;
  late DateTime now;

  setUp(() {
    db = AuvieDatabase(NativeDatabase.memory());
    now = DateTime.utc(2026);
    favorites = FavoritesRepository(db, clock: () => now);
  });

  tearDown(() => db.close());

  test('toggle adds, then removes', () async {
    expect(await favorites.toggle(FavoriteKind.preset, 'ektar_02'), isTrue);
    expect(await favorites.watch(FavoriteKind.preset).first, ['ektar_02']);

    expect(await favorites.toggle(FavoriteKind.preset, 'ektar_02'), isFalse);
    expect(await favorites.watch(FavoriteKind.preset).first, isEmpty);
  });

  test('lists the most recently added first', () async {
    await favorites.toggle(FavoriteKind.preset, 'a');
    now = now.add(const Duration(seconds: 1));
    await favorites.toggle(FavoriteKind.preset, 'b');

    expect(await favorites.watch(FavoriteKind.preset).first, ['b', 'a']);
  });

  test('kinds are independent', () async {
    await favorites.toggle(FavoriteKind.preset, 'film');
    await favorites.toggle(FavoriteKind.collection, 'film');
    await favorites.toggle(FavoriteKind.preset, 'film');

    expect(await favorites.watch(FavoriteKind.preset).first, isEmpty);
    expect(await favorites.watch(FavoriteKind.collection).first, ['film']);
    expect(await favorites.watch(FavoriteKind.sticker).first, isEmpty);
  });
}
