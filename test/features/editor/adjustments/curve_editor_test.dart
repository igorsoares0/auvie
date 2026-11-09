import 'package:auvie/app/router/routes.dart';
import 'package:auvie/core/models/project.dart';
import 'package:auvie/core/models/tone_curve.dart';
import 'package:auvie/core/storage/storage_providers.dart';
import 'package:auvie/features/editor/shell/editor_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fixtures.dart';
import '../../../helpers/pump_app.dart';
import '../photo_editor_test.dart' show unawaitedPush;

void main() {
  late TestApp app;
  late Project project;

  Future<void> tapKey(WidgetTester tester, String key) async {
    await tester.tap(find.byKey(Key(key)));
    await tester.pumpAndSettle();
  }

  Future<void> openCurve(WidgetTester tester) async {
    app = (await tester.runAsync(TestApp.create))!;
    project = (await tester.runAsync(
      () => app.container
          .read(projectRepositoryProvider)
          .create(photoMedia, name: 'Roll 014 · 07'),
    ))!;
    await tester.pumpTestApp(app);
    unawaitedPush(app, AppRoutes.photoEditor(project.id));
    await tester.pumpAndSettle();
    await tapKey(tester, 'tool-adjust');
    await tapKey(tester, 'family-curve');
  }

  ToneCurves curves() => app.container
      .read(editorControllerProvider(project.id))
      .requireValue
      .edit
      .curves;

  Rect area(WidgetTester tester) =>
      tester.getRect(find.byKey(const Key('curve-area')));

  /// A quick finger: the first move already lands 40 px away, as real
  /// touch events do when the finger moves fast.
  Future<void> flick(WidgetTester tester, Offset from, Offset by) async {
    final gesture = await tester.startGesture(from);
    await tester.pump(const Duration(milliseconds: 16));
    await gesture.moveBy(by * 0.5);
    await tester.pump(const Duration(milliseconds: 16));
    await gesture.moveBy(by * 0.5);
    await tester.pump(const Duration(milliseconds: 16));
    await gesture.up();
    await tester.pumpAndSettle();
  }

  testWidgets('the curve fills the panel width', (tester) async {
    await openCurve(tester);
    expect(area(tester).width, greaterThan(300));
    expect(find.byKey(const Key('curve-area')).hitTestable(), findsOneWidget);
    await tester.pump(EditorController.saveDelay);
  });

  testWidgets('a quick drag on a point moves it', (tester) async {
    await openCurve(tester);
    final rect = area(tester);
    // The bottom-left end point (black).
    await flick(
      tester,
      rect.bottomLeft + const Offset(2, -2),
      const Offset(0, -80),
    );

    expect(curves().master.points.first.y, greaterThan(0.2));
    expect(app.engine.updates.last.$2.curveLut[0], greaterThan(40));
    await tester.pump(EditorController.saveDelay);
  });

  testWidgets('dragging the line where there is no point bends it', (
    tester,
  ) async {
    await openCurve(tester);
    final rect = area(tester);
    // The middle of the diagonal: no point there yet.
    await flick(tester, rect.center, const Offset(0, -80));

    final master = curves().master;
    expect(master.points, hasLength(3));
    expect(master.evaluate(0.5), greaterThan(0.6));
    // The engine gets a brighter mid-tone.
    expect(app.engine.updates.last.$2.curveLut[128 * 4], greaterThan(150));
    // One undo step back to the straight line.
    await tapKey(tester, 'editor-undo');
    expect(curves().isIdentity, isTrue);
    await tester.pump(EditorController.saveDelay);
  });
}
