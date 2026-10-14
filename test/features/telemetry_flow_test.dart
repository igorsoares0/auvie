import 'dart:async';

import 'package:auvie/app/router/routes.dart';
import 'package:auvie/app/widgets/error_block.dart';
import 'package:auvie/core/storage/storage_providers.dart';
import 'package:auvie/core/telemetry/telemetry.dart';
import 'package:auvie/features/editor/shell/editor_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fixtures.dart';
import '../helpers/pump_app.dart';

void main() {
  Future<void> tapKey(WidgetTester tester, String key) async {
    await tester.tap(find.byKey(Key(key)));
    await tester.pumpAndSettle();
  }

  testWidgets('films, exports and the paywall are counted anonymously', (
    tester,
  ) async {
    final app = (await tester.runAsync(TestApp.create))!;
    final project = (await tester.runAsync(
      () => app.container
          .read(projectRepositoryProvider)
          .create(photoMedia, name: 'Roll 014 · 07'),
    ))!;
    await tester.pumpTestApp(app);
    unawaited(app.router.push(AppRoutes.photoEditor(project.id)));
    await tester.pumpAndSettle();

    await tapKey(tester, 'preset-ektar_02');
    await tapKey(tester, 'editor-export');
    await tapKey(tester, 'export-save');

    final telemetry = app.telemetry;
    expect(telemetry.of(TelemetryEvent.presetApplied), [
      {'preset': 'ektar_02', 'source': 'film'},
    ]);
    expect(telemetry.of(TelemetryEvent.exportFinished), [
      {'media': 'photo', 'size': 'original'},
    ]);

    // A Pro film, then the paywall from the export notice, then a purchase.
    await tapKey(tester, 'export-back-to-edit');
    await tapKey(tester, 'category-night');
    await tapKey(tester, 'preset-nocturne_19');
    await tapKey(tester, 'editor-export');
    await tapKey(tester, 'export-see-pro');
    await tapKey(tester, 'pro-purchase');
    expect(telemetry.of(TelemetryEvent.paywallViewed), [
      {'source': 'export_notice'},
    ]);
    expect(telemetry.of(TelemetryEvent.purchaseFinished), [
      {'plan': 'yearly', 'outcome': 'done'},
    ]);
    await tester.pump(EditorController.saveDelay);
  });

  testWidgets('a broken screen shows a quiet note', (tester) async {
    await tester.pumpWidget(const ErrorBlock());
    expect(
      find.text('Something went wrong here. Your edits are safe.'),
      findsOneWidget,
    );
  });
}
