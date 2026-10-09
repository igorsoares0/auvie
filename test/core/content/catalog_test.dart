import 'dart:convert';

import 'package:auvie/core/content/catalog.dart';
import 'package:auvie/core/content/catalog_source.dart';
import 'package:auvie/core/models/adjustment.dart';
import 'package:auvie/core/models/preset.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Serves one string for every key.
class _StringBundle extends CachingAssetBundle {
  new(this.content);

  final String content;

  @override
  Future<ByteData> load(String key) async =>
      ByteData.sublistView(Uint8List.fromList(utf8.encode(content)));
}

Map<String, dynamic> sampleJson() => {
  'catalogVersion': 12,
  'collections': [
    {'id': 'night', 'name': 'Night', 'order': 2},
    {'id': 'film', 'name': 'Film', 'order': 0, 'isPremium': false},
  ],
  'presets': [
    {
      'id': 'ektar_02',
      'name': 'Ektar 02',
      'collectionId': 'film',
      'iso': 100,
      'tone': {'highlight': '#e9c9a0', 'mid': '#b4674a', 'shadow': '#3b2a22'},
      'settings': {'exposure': 0.05, 'grain': 0.25},
    },
    {
      'id': 'nocturne_19',
      'name': 'Nocturne 19',
      'collectionId': 'night',
      'isPremium': true,
    },
  ],
  'assets': [
    {
      'id': 'star',
      'type': 'sticker',
      'name': 'Star',
      'file': 'stickers/star.webp',
      'collectionId': 'film',
    },
    {
      'id': 'leak_01',
      'type': 'overlay',
      'name': 'Leak',
      'params': {'generator': 'leak', 'blend': 'screen'},
    },
  ],
};

void main() {
  group('Catalog', () {
    final catalog = Catalog.fromJson(sampleJson());

    test('parses collections, presets and assets', () {
      expect(catalog.catalogVersion, 12);
      expect(catalog.collections, hasLength(2));
      expect(catalog.presets, hasLength(2));
      expect(catalog.assets, hasLength(2));
      expect(catalog.validate(), isEmpty);
    });

    test('parses preset settings, tone strip and premium flag', () {
      final ektar = catalog.presetById('ektar_02')!;
      expect(ektar.settings[Adjustment.grain], 0.25);
      expect(ektar.tone!.highlight, 0xFFE9C9A0);
      expect(ektar.isPremium, isFalse);
      expect(catalog.presetById('nocturne_19')!.isPremium, isTrue);
      expect(catalog.presetById('missing'), isNull);
    });

    test('sorts collections by order', () {
      expect(catalog.sortedCollections.map((c) => c.id), ['film', 'night']);
    });

    test('finds presets and assets', () {
      expect(catalog.presetsIn('night').single.id, 'nocturne_19');
      expect(catalog.assetById('star')!.type, ContentAssetType.sticker);
      expect(catalog.assetById('nope'), isNull);
      expect(
        catalog.assetsOfType(ContentAssetType.overlay).single.id,
        'leak_01',
      );
    });

    test('round-trips through JSON text', () {
      final json = jsonDecode(jsonEncode(catalog)) as Map<String, dynamic>;
      expect(Catalog.fromJson(json), catalog);
    });

    test('reports overlays and frames the app cannot draw', () {
      final json = sampleJson();
      (json['assets'] as List)
        ..add({
          'id': 'blob',
          'type': 'overlay',
          'name': 'Blob',
          'params': {'generator': 'lava'},
        })
        ..add({
          'id': 'gold',
          'type': 'frame',
          'name': 'Gold',
          'params': {'style': 'baroque'},
        })
        ..add({'id': 'nofile', 'type': 'sticker', 'name': 'Nothing'});
      expect(Catalog.fromJson(json).validate(), [
        'Overlay "blob" has an unknown generator',
        'Frame "gold" has an unknown style',
        'Asset "nofile" has no file',
      ]);
    });

    test('reports duplicate ids and unknown collections', () {
      final json = sampleJson();
      (json['presets'] as List).add({
        'id': 'ektar_02',
        'name': 'Copy',
        'collectionId': 'summer',
      });
      (json['assets'] as List).add({
        'id': 'star',
        'type': 'sticker',
        'name': 'Star 2',
        'file': 'x',
        'collectionId': 'travel',
      });
      (json['collections'] as List).add({'id': 'film', 'name': 'Film 2'});

      expect(Catalog.fromJson(json).validate(), [
        'Duplicate collection id "film"',
        'Duplicate preset id "ektar_02"',
        'Duplicate asset id "star"',
        'Preset "ektar_02" is in unknown collection "summer"',
        'Asset "star" is in unknown collection "travel"',
      ]);
    });
  });

  group('HexColorConverter', () {
    const converter = HexColorConverter();

    test('reads #rrggbb as an opaque color', () {
      expect(converter.fromJson('#e9c9a0'), 0xFFE9C9A0);
      expect(converter.fromJson('3b2a22'), 0xFF3B2A22);
    });

    test('writes #rrggbb', () {
      expect(converter.toJson(0xFF0A0B0C), '#0a0b0c');
    });

    test('rejects other formats', () {
      expect(() => converter.fromJson('#fff'), throwsFormatException);
    });
  });

  test('outOfRangeSettings flags values the app would clamp', () {
    expect(outOfRangeSettings({'exposure': 1.5, 'grain': -0.1, 'fade': 0.2}), [
      'exposure=1.5',
      'grain=-0.1',
    ]);
  });

  group('BundledCatalogSource', () {
    TestWidgetsFlutterBinding.ensureInitialized();

    test('the shipped catalog is valid', () async {
      final catalog = await BundledCatalogSource(rootBundle).load();

      expect(catalog.presets.map((p) => p.id), [
        'ektar_02',
        'portra_04',
        'cendre_11',
        'vitrine',
        'portra_fade',
        'nocturne_19',
      ]);
      expect(catalog.presets.every((p) => p.tone != null), isTrue);
      expect(catalog.presets.where((p) => p.isPremium).map((p) => p.id), [
        'portra_fade',
        'nocturne_19',
      ]);
      expect(catalog.presetById('portra_fade')!.curves, isNotNull);
    });

    test('every shipped sticker file exists', () async {
      final catalog = await BundledCatalogSource(rootBundle).load();
      final stickers = catalog.assetsOfType(ContentAssetType.sticker);
      expect(stickers, hasLength(12));
      for (final sticker in stickers) {
        final svg = await rootBundle.loadString(sticker.file);
        expect(svg, contains('currentColor'), reason: sticker.id);
      }
      expect(catalog.assetsOfType(ContentAssetType.overlay), hasLength(6));
      expect(catalog.assetsOfType(ContentAssetType.frame), hasLength(4));
    });

    test('the shipped catalog has no out-of-range settings', () async {
      final raw = jsonDecode(
        await rootBundle.loadString(BundledCatalogSource.defaultPath),
      ) as Map<String, dynamic>;
      for (final preset
          in (raw['presets'] as List).cast<Map<String, dynamic>>()) {
        expect(
          outOfRangeSettings(preset['settings'] as Map<String, dynamic>),
          isEmpty,
          reason: preset['id'] as String,
        );
      }
    });

    test('fails clearly on malformed JSON', () {
      expect(
        BundledCatalogSource(_StringBundle('{oops')).load(),
        throwsA(isA<CatalogLoadException>()),
      );
    });

    test('fails clearly on an invalid catalog', () {
      final json = sampleJson()..['collections'] = <Object>[];
      expect(
        BundledCatalogSource(_StringBundle(jsonEncode(json))).load(),
        throwsA(
          isA<CatalogLoadException>().having(
            (e) => e.toString(),
            'message',
            contains('unknown collection'),
          ),
        ),
      );
    });
  });
}
