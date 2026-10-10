import 'dart:async';

import 'package:auvie/app/router/routes.dart';
import 'package:auvie/app/theme/app_theme.dart';
import 'package:auvie/app/theme/spacing.dart';
import 'package:auvie/app/widgets/caps_link.dart';
import 'package:auvie/features/editor/add/add_panel.dart';
import 'package:auvie/features/editor/adjustments/adjust_panel.dart';
import 'package:auvie/features/editor/brush/brush_panel.dart';
import 'package:auvie/features/editor/presets/film_panel.dart';
import 'package:auvie/features/editor/shell/edit_caption.dart';
import 'package:auvie/features/editor/shell/editor_chrome.dart';
import 'package:auvie/features/editor/shell/editor_controller.dart';
import 'package:auvie/features/editor/shell/editor_preview.dart';
import 'package:auvie/features/editor/shell/editor_session.dart';
import 'package:auvie/features/editor/text/text_edit_overlay.dart';
import 'package:auvie/features/editor/text/type_panel.dart';
import 'package:auvie/features/editor/video/timeline_panel.dart';
import 'package:auvie/features/editor/video/video_playback.dart';
import 'package:auvie/features/editor/video/video_transport.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The editor (handoffs "Photo editor" and 05 "Video"): the media fills
/// the space, the tool panel cross-fades below it and the media never
/// moves. Videos add the transport row and the TRIM timeline.
class EditorScreen extends ConsumerStatefulWidget {
  const new({required this.projectId, super.key});

  final String projectId;

  /// Fixed so switching tools doesn't move the photo.
  static const panelHeight = 280.0;

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  late final AppLifecycleListener _lifecycle;
  bool _closing = false;

  EditorController get _controller =>
      ref.read(editorControllerProvider(widget.projectId).notifier);

  @override
  void initState() {
    super.initState();
    // Leaving the app saves immediately instead of waiting for the debounce,
    // and stops a playing video.
    _lifecycle = AppLifecycleListener(
      onPause: () {
        ref.read(videoPlaybackProvider(widget.projectId).notifier).pause();
        unawaited(_save());
      },
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (ref.read(editorControllerProvider(widget.projectId)).hasValue) {
      await _controller.save();
    }
  }

  Future<void> _close() async {
    if (_closing) return;
    _closing = true;
    if (ref.read(editorControllerProvider(widget.projectId)).hasValue) {
      await _controller.close();
    }
    if (!mounted) return;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  Future<void> _export() async {
    await _save();
    if (mounted) await context.push(AppRoutes.export(widget.projectId));
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(editorControllerProvider(widget.projectId));
    // Editing a video (drawing, typing, dragging) stops it playing.
    ref.listen(editorControllerProvider(widget.projectId), (previous, next) {
      final before = previous?.value;
      final now = next.value;
      if (now == null || !now.isVideo || before == null) return;
      if (before.edit != now.edit || now.editingElementId != null) {
        ref.read(videoPlaybackProvider(widget.projectId).notifier).pause();
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        final typing = ref
            .read(editorControllerProvider(widget.projectId))
            .value
            ?.editingElementId;
        if (typing != null) {
          _controller.cancelTyping();
        } else {
          unawaited(_close());
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: switch (async) {
            AsyncData(value: final session) => _Editor(
              session: session,
              controller: _controller,
              onClose: _close,
              onExport: _export,
            ),
            AsyncError() => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("This edit can't be opened.", style: context.type.body),
                  CapsLink('Close', onTap: _close),
                ],
              ),
            ),
            _ => const SizedBox.shrink(),
          },
        ),
      ),
    );
  }
}

class _Editor extends ConsumerWidget {
  const new({
    required this.session,
    required this.controller,
    required this.onClose,
    required this.onExport,
  });

  final EditorSession session;
  final EditorController controller;
  final VoidCallback onClose;
  final VoidCallback onExport;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = session.project.id;
    final panel = switch (session.tool) {
      EditorTool.trim => TimelinePanel(
        key: const ValueKey('trim'),
        projectId: id,
      ),
      EditorTool.film => FilmPanel(key: const ValueKey('film'), projectId: id),
      EditorTool.adjust => AdjustPanel(
        key: const ValueKey('adjust'),
        projectId: id,
      ),
      EditorTool.type => TypePanel(key: const ValueKey('type'), projectId: id),
      EditorTool.brush => BrushPanel(
        key: const ValueKey('brush'),
        projectId: id,
      ),
      EditorTool.add => AddPanel(key: const ValueKey('add'), projectId: id),
    };
    final typing = session.editingElementId != null;

    final editor = Column(
      children: [
        if (typing)
          EditorHeader.typing(
            title: session.project.name,
            onCancel: controller.cancelTyping,
            onDone: controller.finishTyping,
          )
        else
          EditorHeader(
            title: session.project.name,
            onClose: onClose,
            onExport: onExport,
          ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AuvieSpacing.gutter,
              4,
              AuvieSpacing.gutter,
              0,
            ),
            child: EditorPreview(projectId: id),
          ),
        ),
        const SizedBox(height: AuvieSpacing.s8),
        if (session.isVideo)
          VideoTransport(projectId: id)
        else
          EditorCaption(
            caption: describeEdit(session.edit, controller.preset),
            canUndo: session.history.canUndo,
            canRedo: session.history.canRedo,
            onUndo: controller.undo,
            onRedo: controller.redo,
            showCompareHint: session.tool == EditorTool.film,
          ),
        SizedBox(
          height: EditorScreen.panelHeight,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeOut,
            child: panel,
          ),
        ),
        EditorToolbar(
          tools: EditorTool.forMedia(session.project.media.type),
          active: session.tool,
          onSelect: controller.selectTool,
        ),
      ],
    );
    // Always a Stack, so opening the keyboard keeps the preview (and a
    // video's player) alive.
    return Stack(
      children: [
        editor,
        if (typing)
          Positioned.fill(
            top: AuvieSpacing.headerHeight,
            child: TextEditOverlay(projectId: id),
          ),
      ],
    );
  }
}
