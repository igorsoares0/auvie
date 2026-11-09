import 'package:auvie/app/router/routes.dart';
import 'package:auvie/core/models/color_mix.dart';
import 'package:auvie/core/models/project.dart';
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

  Future<void> openHsl(WidgetTester tester) async {
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
    await tapKey(tester, 'family-hsl');
  }

  ColorMix mix() => app.container
      .read(editorControllerProvider(project.id))
      .requireValue
      .edit
      .colorMix;

  String value(WidgetTester tester) =>
      tester.widget<Text>(find.byKey(const Key('hsl-value'))).data!;

  testWidgets('changes one channel of one color range', (tester) async {
    await openHsl(tester);
    expect(find.text('HUE'), findsOneWidget);
    expect(find.text('SATURATION'), findsOneWidget);
    expect(find.text('LUMINANCE'), findsOneWidget);
    expect(value(tester), '0.00');

    await tapKey(tester, 'hsl-band-blue');
    await tapKey(tester, 'hsl-channel-saturation');
    await tester.drag(
      find.byKey(const Key('lens-ruler')),
      const Offset(-60, 0),
    );
    await tester.pumpAndSettle();

    final saturation = mix()(ColorBand.blue, ColorChannel.saturation);
    expect(saturation, lessThan(0));
    expect(mix()(ColorBand.blue, ColorChannel.hue), 0);
    expect(mix()(ColorBand.red, ColorChannel.saturation), 0);
    expect(value(tester), startsWith('−'));
    // The engine gets the table for it.
    expect(app.engine.updates.last.$2.colorLut, buildColorLut(mix()));
    // Changed ranges and channels are marked.
    expect(find.byKey(const Key('hsl-band-blue-edited')), findsOneWidget);
    expect(find.byKey(const Key('hsl-band-red-edited')), findsNothing);

    // Another range starts from its own value.
    await tapKey(tester, 'hsl-band-red');
    expect(value(tester), '0.00');
    await tester.pump(EditorController.saveDelay);
  });

  testWidgets('counts as one adjustment and undoes as one step', (
    tester,
  ) async {
    await openHsl(tester);
    await tapKey(tester, 'hsl-band-orange');
    await tester.drag(find.byKey(const Key('lens-ruler')), const Offset(40, 0));
    await tester.pumpAndSettle();
    await tapKey(tester, 'hsl-channel-luminance');
    await tester.drag(find.byKey(const Key('lens-ruler')), const Offset(40, 0));
    await tester.pumpAndSettle();

    final caption = find.byKey(const Key('editor-caption'));
    expect(tester.widget<Text>(caption).data, 'One adjustment');
    await tapKey(tester, 'editor-undo');
    expect(mix()(ColorBand.orange, ColorChannel.luminance), 0);
    expect(mix()(ColorBand.orange, ColorChannel.hue), greaterThan(0));
    await tester.pump(EditorController.saveDelay);
  });

  testWidgets('double-tap resets the channel', (tester) async {
    await openHsl(tester);
    await tester.drag(find.byKey(const Key('lens-ruler')), const Offset(60, 0));
    await tester.pumpAndSettle();
    expect(mix().isNeutral, isFalse);

    final ruler = find.byKey(const Key('lens-ruler'));
    await tester.tap(ruler);
    await tester.pump(const Duration(milliseconds: 60));
    await tester.tap(ruler);
    await tester.pumpAndSettle();
    expect(mix().isNeutral, isTrue);
    await tester.pump(EditorController.saveDelay);
  });

  testWidgets('swiping the value moves between channels', (tester) async {
    await openHsl(tester);
    await tester.fling(
      find.byKey(const Key('hsl-header')),
      const Offset(-200, 0),
      1000,
    );
    await tester.pumpAndSettle();
    final session = app.container
        .read(editorControllerProvider(project.id))
        .requireValue;
    expect(session.parameter, ColorChannel.saturation.index);
  });
}

Future<void> tapKey(WidgetTester tester, String key) async {
  await tester.tap(find.byKey(Key(key)));
  await tester.pumpAndSettle();
}
