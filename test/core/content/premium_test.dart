import 'package:auvie/core/content/catalog.dart';
import 'package:auvie/core/content/premium.dart';
import 'package:auvie/core/models/edit_state.dart';
import 'package:auvie/core/models/elements.dart';
import 'package:auvie/core/models/preset.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const catalog = Catalog(
    catalogVersion: 1,
    collections: [PresetCollection(id: 'night', name: 'Night')],
    presets: [
      Preset(id: 'ektar', name: 'Ektar 02', collectionId: 'night'),
      Preset(
        id: 'nocturne',
        name: 'Nocturne 19',
        collectionId: 'night',
        isPremium: true,
      ),
    ],
    assets: [
      ContentAsset(id: 'star', type: ContentAssetType.sticker, name: 'Star'),
      ContentAsset(
        id: 'stamp',
        type: ContentAssetType.sticker,
        name: 'Stamp',
        isPremium: true,
      ),
      ContentAsset(
        id: 'burn',
        type: ContentAssetType.overlay,
        name: 'Film burn',
        isPremium: true,
      ),
      ContentAsset(
        id: 'film35',
        type: ContentAssetType.frame,
        name: '35 mm',
        isPremium: true,
      ),
    ],
  );

  test('a free edit uses no Pro content', () {
    final edit = const EditState()
        .withPreset('ektar')
        .addElement(const EditElement.sticker(id: 's', assetId: 'star'));
    expect(premiumContent(edit, catalog), isEmpty);
    expect(premiumContent(const EditState(), catalog), isEmpty);
  });

  test('lists the Pro preset first, then Pro stickers, overlays, frames', () {
    final edit = const EditState()
        .withPreset('nocturne')
        .addElement(const EditElement.frame(id: 'f', assetId: 'film35'))
        .addElement(const EditElement.sticker(id: 's', assetId: 'stamp'))
        .addElement(const EditElement.overlay(id: 'o', assetId: 'burn'));
    expect(premiumContent(edit, catalog), [
      (kind: PremiumKind.preset, id: 'nocturne', name: 'Nocturne 19'),
      (kind: PremiumKind.frame, id: 'film35', name: '35 mm'),
      (kind: PremiumKind.sticker, id: 'stamp', name: 'Stamp'),
      (kind: PremiumKind.overlay, id: 'burn', name: 'Film burn'),
    ]);
  });

  test('each item is listed once', () {
    final edit = const EditState()
        .addElement(const EditElement.sticker(id: 'a', assetId: 'stamp'))
        .addElement(const EditElement.sticker(id: 'b', assetId: 'stamp'));
    expect(premiumContent(edit, catalog), hasLength(1));
  });

  test('text and brush are never Pro; unknown content never locks', () {
    final edit = const EditState()
        .withPreset('gone')
        .addElement(const EditElement.text(id: 't', text: 'Hi'))
        .addElement(const EditElement.brush(id: 'b'))
        .addElement(const EditElement.sticker(id: 's', assetId: 'removed'));
    expect(premiumContent(edit, catalog), isEmpty);
  });
}
