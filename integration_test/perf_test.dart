import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:auvie/app/app.dart';
import 'package:auvie/app/router/router.dart';
import 'package:auvie/app/router/routes.dart';
import 'package:auvie/app/settings/app_settings.dart';
import 'package:auvie/core/native/media_engine_provider.dart';
import 'package:auvie/core/storage/storage_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Frame timings of the photo editor on a real phone, with the real engine
/// (spec §56: sliders without perceptible lag). Run in profile mode, see
/// test_driver/perf_driver.dart.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// A 4000 × 3000 test photo (12 MP, a typical phone photo).
  Future<String> testPhoto() async {
    final dir = await getApplicationSupportDirectory();
    final file = File('${dir.path}/perf_photo.png');
    if (!file.existsSync()) {
      final recorder = ui.PictureRecorder();
      const size = Size(4000, 3000);
      Canvas(recorder).drawRect(
        Offset.zero & size,
        Paint()
          ..shader = ui.Gradient.linear(
            Offset.zero,
            size.bottomRight(Offset.zero),
            const [Color(0xFF2B3A55), Color(0xFFE9C9A0), Color(0xFF3B2A22)],
            const [0, 0.5, 1],
          ),
      );
      final image = await recorder.endRecording().toImage(4000, 3000);
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      await file.writeAsBytes(png!.buffer.asUint8List());
    }
    return Uri.file(file.path).toString();
  }

  testWidgets('photo editor: EXPOSURE ruler and FILM cards', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auvie.onboardingSeen', true);
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);
    final media = await container
        .read(mediaEngineProvider)
        .probe(await testPhoto());
    final project = await container
        .read(projectRepositoryProvider)
        .create(media, name: 'Perf · 01');

    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const AuvieApp()),
    );
    await tester.pumpAndSettle();
    // push completes when the route pops: don't wait for it.
    unawaited(
      container.read(routerProvider).push(AppRoutes.photoEditor(project.id)),
    );
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // FILM: scroll the cards (each renders the photo with its film).
    await binding.watchPerformance(() async {
      final cards = find.byKey(const Key('preset-original'));
      for (var i = 0; i < 3; i++) {
        await tester.drag(cards, const Offset(-300, 0));
        await tester.pump(const Duration(milliseconds: 400));
        await tester.drag(cards, const Offset(300, 0));
        await tester.pump(const Duration(milliseconds: 400));
      }
    }, reportKey: 'film_cards');

    // ADJUST: drag the EXPOSURE ruler back and forth, frame by frame.
    await tester.tap(find.byKey(const Key('tool-adjust')));
    await tester.pumpAndSettle();
    await binding.watchPerformance(() async {
      final ruler = find.byKey(const Key('lens-ruler'));
      for (var i = 0; i < 4; i++) {
        final gesture = await tester.startGesture(tester.getCenter(ruler));
        for (var step = 0; step < 30; step++) {
          await gesture.moveBy(Offset(i.isEven ? -6 : 6, 0));
          await tester.pump(const Duration(milliseconds: 16));
        }
        await gesture.up();
        await tester.pump(const Duration(milliseconds: 300));
      }
    }, reportKey: 'exposure_ruler');

    await container.read(projectRepositoryProvider).delete(project.id);
  });
}
