import 'dart:convert';

import 'package:auvie/app/theme/app_theme.dart';
import 'package:auvie/core/content/catalog_providers.dart';
import 'package:auvie/core/content/catalog_source.dart';
import 'package:auvie/core/models/adjustment.dart';
import 'package:auvie/core/models/project.dart';
import 'package:auvie/core/native/media_engine_provider.dart';
import 'package:auvie/features/dev/engine_lab_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_media_engine.dart';
import '../../helpers/fixtures.dart';

void main() {
  late FakeMediaEngine engine;

  setUp(() => engine = FakeMediaEngine(picked: photoMedia));

  Future<void> pumpLab(WidgetTester tester) async {
    final catalog = await tester.runAsync(
      () => BundledCatalogSource(rootBundle).load(),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mediaEngineProvider.overrideWithValue(engine),
          catalogProvider.overrideWith((ref) async => catalog!),
        ],
        child: MaterialApp(
          theme: AuvieTheme.darkroom(),
          home: const EngineLabScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> pick(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('lab-pick')));
    await tester.pumpAndSettle();
  }

  testWidgets('picking a photo shows its preview, developed', (tester) async {
    await pumpLab(tester);
    expect(find.byType(Texture), findsNothing);

    await pick(tester);

    expect(engine.calls, contains('pickMedia(photo)'));
    // Rendered at the size shown on screen, not the 4000 px original.
    final create = engine.calls.firstWhere(
      (c) => c.startsWith('createPhotoPreview'),
    );
    final maxPx = int.parse(RegExp(r', (\d+)\)').firstMatch(create)!.group(1)!);
    expect(maxPx, lessThan(photoMedia.width));
    expect(find.byKey(const Key('lab-texture')), findsOneWidget);
    expect(engine.updates.single.$1, 1);
    expect(engine.updates.single.$2.adjustments.isNeutral, isTrue);
  });

  testWidgets('cancelling the picker keeps the empty state', (tester) async {
    engine.picked = null;
    await pumpLab(tester);
    await pick(tester);
    expect(find.byType(Texture), findsNothing);
    expect(
      engine.calls.where((c) => c.startsWith('createPhotoPreview')),
      isEmpty,
    );
  });

  testWidgets('moving a slider sends the new value', (tester) async {
    await pumpLab(tester);
    await pick(tester);
    await tester.tap(find.text('ADJUST'));
    await tester.pumpAndSettle();

    final slider = find.byKey(const Key('slider-exposure'));
    await tester.ensureVisible(slider);
    await tester.drag(slider, const Offset(60, 0));
    await tester.pumpAndSettle();

    expect(
      engine.updates.last.$2.adjustments[Adjustment.exposure],
      greaterThan(0),
    );
  });

  testWidgets('holding the photo shows the original', (tester) async {
    await pumpLab(tester);
    await pick(tester);

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const Key('lab-texture'))),
    );
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(engine.showOriginal, [true, false]);
  });

  testWidgets('leaving the lab releases the preview', (tester) async {
    await pumpLab(tester);
    await pick(tester);

    await tester.pumpWidget(const SizedBox());
    expect(engine.disposed, [1]);
  });

  testWidgets('editing a film changes what is rendered and the JSON', (
    tester,
  ) async {
    await pumpLab(tester);
    await pick(tester);
    await tester.tap(find.byKey(const Key('lab-film-ektar_02')));
    await tester.pumpAndSettle();

    final slider = find.byKey(const Key('film-grain'));
    await tester.ensureVisible(slider);
    await tester.drag(slider, const Offset(80, 0));
    await tester.pumpAndSettle();

    final grain = engine.updates.last.$2.adjustments[Adjustment.grain];
    expect(grain, greaterThan(0.12));
    await tester.tap(find.byKey(const Key('lab-json')));
    await tester.pumpAndSettle();
    final text = tester.widget<SelectableText>(find.byType(SelectableText));
    final json = jsonDecode(text.data!) as Map<String, dynamic>;
    final presets = json['presets'] as Map<String, dynamic>;
    final ektar = presets['ektar_02'] as Map<String, dynamic>;
    expect(ektar['grain'] as double, closeTo(grain, 0.01));
    expect(json['tuning'], isNotNull);
  });

  testWidgets('tuning changes the engine for every render', (tester) async {
    await pumpLab(tester);
    await pick(tester);
    await tester.tap(find.text('TUNING'));
    await tester.pumpAndSettle();

    await tester.drag(
      find.byKey(const Key('tuning-grain')),
      const Offset(80, 0),
    );
    await tester.pumpAndSettle();

    expect(engine.tuning.grainAmount, greaterThan(0.3));
  });

  test('photoMedia fixture is a photo', () {
    expect(photoMedia.type, MediaType.photo);
  });
}
