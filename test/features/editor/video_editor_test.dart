import 'dart:async';

import 'package:auvie/app/router/routes.dart';
import 'package:auvie/core/models/elements.dart';
import 'package:auvie/core/models/project.dart';
import 'package:auvie/core/storage/storage_providers.dart';
import 'package:auvie/features/editor/elements/elements_painter.dart';
import 'package:auvie/features/editor/shell/editor_controller.dart';
import 'package:auvie/features/editor/shell/editor_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/pump_app.dart';

void main() {
  late TestApp app;
  late Project project;

  Future<void> openEditor(WidgetTester tester) async {
    app = (await tester.runAsync(TestApp.create))!;
    project = (await tester.runAsync(
      () => app.container
          .read(projectRepositoryProvider)
          .create(videoMedia, name: 'Film 012'),
    ))!;
    await tester.pumpTestApp(app);
    unawaited(app.router.push(AppRoutes.videoEditor(project.id)));
    await tester.pumpAndSettle();
  }

  EditorSession session() =>
      app.container.read(editorControllerProvider(project.id)).requireValue;

  Future<void> tapKey(WidgetTester tester, String key) async {
    await tester.tap(find.byKey(Key(key)));
    await tester.pumpAndSettle();
  }

  Future<void> settle(WidgetTester tester) =>
      tester.pump(EditorController.saveDelay); // Let the autosave run.

  String timecode(WidgetTester tester) => tester
      .widget<RichText>(
        find.descendant(
          of: find.byKey(const Key('timecode')),
          matching: find.byType(RichText),
        ),
      )
      .text
      .toPlainText();

  /// Moves the playhead as the player would.
  Future<void> playheadAt(WidgetTester tester, int ms) async {
    app.engine.emitPlayback(1, ms);
    await tester.pumpAndSettle();
  }

  testWidgets('opens on TRIM with the six tools and the video', (tester) async {
    await openEditor(tester);

    expect(session().tool, EditorTool.trim);
    for (final tool in EditorTool.values) {
      expect(find.byKey(Key('tool-${tool.name}')), findsOneWidget);
    }
    expect(
      app.engine.calls.where((c) => c.startsWith('createVideoPreview')),
      hasLength(1),
    );
    // The player loops over the whole clip, with sound.
    expect(app.engine.player, containsAll(['range(0, 10000)', 'muted(false)']));
    expect(find.byKey(const Key('timeline-film')), findsOneWidget);
    expect(timecode(tester), '00:00.00  OF 00:10');
    await settle(tester);
  });

  testWidgets('play / pause and the timecode follow the player', (
    tester,
  ) async {
    await openEditor(tester);

    await tapKey(tester, 'transport-play');
    expect(app.engine.player.last, 'play');
    app.engine.emitPlayback(1, 4120, playing: true);
    await tester.pumpAndSettle();
    expect(timecode(tester), '00:04.12  OF 00:10');

    await tapKey(tester, 'transport-play');
    expect(app.engine.player.last, 'pause');
    await settle(tester);
  });

  testWidgets('tapping the FILM strip seeks there', (tester) async {
    await openEditor(tester);
    final strip = tester.getRect(find.byKey(const Key('timeline-film')));

    await tester.tapAt(strip.centerLeft + Offset(strip.width / 2, 0));
    await tester.pump();

    expect(app.engine.player.last, 'seek(5000, true)');
    await settle(tester);
  });

  testWidgets('dragging a trim handle trims, as one undo step', (tester) async {
    await openEditor(tester);
    final strip = tester.getRect(find.byKey(const Key('timeline-film')));

    // From the start handle to 20% of the clip.
    await tester.dragFrom(
      strip.centerLeft + const Offset(4, 0),
      Offset(strip.width * 0.2 - 4, 0),
    );
    await tester.pumpAndSettle();

    final start = session().timeline.trimStartMs;
    expect(start, closeTo(2000, 50));
    expect(app.engine.player, contains('range($start, 10000)'));
    expect(timecode(tester), endsWith('OF 00:08'));

    await tapKey(tester, 'editor-undo');
    expect(session().timeline.trimStartMs, 0);
    await settle(tester);
  });

  testWidgets('SOUND mutes the video and its export', (tester) async {
    await openEditor(tester);

    await tapKey(tester, 'transport-sound');

    expect(session().timeline.muted, isTrue);
    expect(app.engine.player.last, 'muted(true)');
    expect(find.text('MUTED'), findsOneWidget);
    await settle(tester);
  });

  testWidgets('a text added at the playhead shows from there to the end', (
    tester,
  ) async {
    await openEditor(tester);
    await playheadAt(tester, 3000);

    await tapKey(tester, 'tool-type');
    await tapKey(tester, 'elements-gestures');
    await tester.enterText(find.byKey(const Key('text-input')), 'After rain');
    await tester.pump();
    await tapKey(tester, 'typing-done');

    final text = session().edit.elements.single;
    expect(text.time, const TimeRange(startMs: 3000, endMs: 10000));

    // It is a bar on the TYPE lane, and hidden before its start.
    await tapKey(tester, 'tool-trim');
    expect(find.byKey(const Key('bar-e1')), findsOneWidget);
    expect(find.text('AFTER RAIN'), findsOneWidget);
    ElementsPainter painter() =>
        tester
                .widget<CustomPaint>(find.byKey(const Key('elements-paint')))
                .painter!
            as ElementsPainter;
    expect(painter().elements, hasLength(1));
    await playheadAt(tester, 1000);
    expect(painter().elements, isEmpty);
    await settle(tester);
  });

  testWidgets('dragging a lane bar changes when the element shows', (
    tester,
  ) async {
    await openEditor(tester);
    await playheadAt(tester, 2000);
    await tapKey(tester, 'tool-brush');
    await tester.drag(
      find.byKey(const Key('elements-draw')),
      const Offset(60, 40),
    );
    await tester.pumpAndSettle();
    expect(
      session().edit.elements.single.time,
      const TimeRange(startMs: 2000, endMs: 10000),
    );

    await tapKey(tester, 'tool-trim');
    final strip = tester.getRect(find.byKey(const Key('timeline-film')));
    final bar = tester.getRect(find.byKey(const Key('bar-e1')));
    // Selecting it, then dragging its start handle a tenth of the clip on.
    await tester.tapAt(bar.center);
    await tester.pump();
    expect(session().selectedElementId, 'e1');
    await tester.dragFrom(
      bar.centerLeft + const Offset(2, 0),
      Offset(strip.width / 10, 0),
    );
    await tester.pumpAndSettle();

    final time = session().edit.elements.single.time!;
    expect(time.startMs, closeTo(3000, 60));
    expect(time.endMs, 10000);
    await tapKey(tester, 'editor-undo');
    expect(
      session().edit.elements.single.time,
      const TimeRange(startMs: 2000, endMs: 10000),
    );
    await settle(tester);
  });

  testWidgets('editing pauses a playing video', (tester) async {
    await openEditor(tester);
    await tapKey(tester, 'transport-play');
    app.engine.emitPlayback(1, 1000, playing: true);
    await tester.pumpAndSettle();
    app.engine.player.clear();

    await tapKey(tester, 'transport-sound');

    expect(app.engine.player, contains('pause'));
    await settle(tester);
  });
}
