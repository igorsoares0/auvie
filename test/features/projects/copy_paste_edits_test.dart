import 'dart:async';

import 'package:auvie/app/router/routes.dart';
import 'package:auvie/core/models/adjustment.dart';
import 'package:auvie/core/models/adjustments.dart';
import 'package:auvie/core/models/edit_state.dart';
import 'package:auvie/core/models/preset.dart';
import 'package:auvie/core/storage/storage_providers.dart';
import 'package:auvie/features/editor/shell/editor_controller.dart';
import 'package:auvie/features/projects/edits_clipboard.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/pump_app.dart';

void main() {
  Future<void> tapKey(WidgetTester tester, String key) async {
    await tester.tap(find.byKey(Key(key)));
    await tester.pumpAndSettle();
  }

  String caption(WidgetTester tester) =>
      tester.widget<Text>(find.byKey(const Key('editor-caption'))).data!;

  testWidgets('copies a look in one editor and pastes it in another', (
    tester,
  ) async {
    final app = (await tester.runAsync(TestApp.create))!;
    final repository = app.container.read(projectRepositoryProvider);
    final first = (await tester.runAsync(
      () => repository.create(photoMedia, name: 'Roll 014 · 07'),
    ))!;
    final second = (await tester.runAsync(
      () => repository.create(photoMedia, name: 'Roll 014 · 08'),
    ))!;
    await tester.pumpTestApp(app);

    unawaited(app.router.push(AppRoutes.photoEditor(first.id)));
    await tester.pumpAndSettle();
    await tapKey(tester, 'preset-ektar_02');

    // Nothing copied yet: PASTE is off.
    await tapKey(tester, 'editor-title');
    expect(find.byKey(const Key('edit-actions-sheet')), findsOneWidget);
    expect(find.byKey(const Key('edit-action-delete')), findsNothing);
    expect(find.text('Copy an edit first.'), findsOneWidget);
    await tapKey(tester, 'edit-action-copy');
    expect(find.text('Edits copied.'), findsOneWidget);
    expect(app.prefs.getString('auvie.copiedEdits'), contains('ektar_02'));

    unawaited(app.router.push(AppRoutes.photoEditor(second.id)));
    await tester.pumpAndSettle();
    expect(caption(tester), 'Original');
    await tapKey(tester, 'editor-title');
    expect(find.text('Ektar, at 100%'), findsOneWidget);
    await tapKey(tester, 'edit-action-paste');
    expect(caption(tester), 'Ektar, at 100%');

    // One undo step.
    await tapKey(tester, 'editor-undo');
    expect(caption(tester), 'Original');
    await tester.pump(EditorController.saveDelay); // Let the autosave run.
  });

  testWidgets('pasting on a saved edit keeps its crop and elements', (
    tester,
  ) async {
    final app = (await tester.runAsync(TestApp.create))!;
    addTearDown(() => tester.runAsync(app.dispose));
    final repository = app.container.read(projectRepositoryProvider);
    final clipboard = app.container.read(editsClipboardProvider.notifier);
    final target = (await tester.runAsync(() async {
      final created = await repository.create(videoMedia, name: 'Roll 014');
      return await repository.save(created.copyWith(edit: richEdit()));
    }))!;
    final copied = CopiedEdits(
      adjustments: Adjustments.of(const {Adjustment.fade: 0.4}),
      preset: const PresetRef(presetId: 'portra_04', intensity: 0.5),
    );

    final pasted = (await tester.runAsync(() async {
      await clipboard.copy(copied);
      return await clipboard.pasteInto(target.id);
    }))!;

    expect(pasted, isTrue);
    final saved = (await tester.runAsync(() => repository.find(target.id)))!;
    expect(saved.edit.copyEdits(), copied);
    expect(saved.edit.crop, richEdit().crop);
    expect(saved.edit.elements, richEdit().elements);
    expect(saved.edit.video, richEdit().video);
    expect(app.thumbnails.refreshed.single.$1.id, target.id);
    expect(app.thumbnails.refreshed.single.$2?.id, 'portra_04');
  });

  testWidgets('copying from Home takes the saved edit', (tester) async {
    final app = (await tester.runAsync(TestApp.create))!;
    addTearDown(() => tester.runAsync(app.dispose));
    final repository = app.container.read(projectRepositoryProvider);
    final clipboard = app.container.read(editsClipboardProvider.notifier);
    final source = (await tester.runAsync(() async {
      final created = await repository.create(photoMedia);
      return await repository.save(created.copyWith(edit: richEdit()));
    }))!;

    expect(await tester.runAsync(() => clipboard.copyFrom(source.id)), isTrue);
    expect(app.container.read(editsClipboardProvider), richEdit().copyEdits());
    expect(await tester.runAsync(() => clipboard.copyFrom('gone')), isFalse);
  });

  testWidgets('copied edits survive a restart; unreadable ones are dropped', (
    tester,
  ) async {
    final app = (await tester.runAsync(TestApp.create))!;
    addTearDown(() => tester.runAsync(app.dispose));
    final clipboard = app.container.read(editsClipboardProvider.notifier);
    await tester.runAsync(() => clipboard.copy(richEdit().copyEdits()));

    app.container.invalidate(editsClipboardProvider);
    expect(app.container.read(editsClipboardProvider), richEdit().copyEdits());

    await tester.runAsync(
      () => app.prefs.setString('auvie.copiedEdits', '{not json'),
    );
    app.container.invalidate(editsClipboardProvider);
    expect(app.container.read(editsClipboardProvider), isNull);
  });
}
