import 'dart:async';

import 'package:auvie/app/theme/app_theme.dart';
import 'package:auvie/core/native/media_engine.dart';
import 'package:auvie/core/native/media_engine_provider.dart';
import 'package:auvie/core/native/preview_size.dart';
import 'package:auvie/core/native/render_params.dart';
import 'package:auvie/features/editor/photo/photo_editor_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The developed photo, rendered by the engine at its on-screen size.
/// Hold it to see the original.
class EditorPreview extends ConsumerStatefulWidget {
  const new({required this.projectId, super.key});

  final String projectId;

  @override
  ConsumerState<EditorPreview> createState() => _EditorPreviewState();
}

class _EditorPreviewState extends ConsumerState<EditorPreview> {
  late final MediaEngine _engine;
  PhotoPreview? _preview;
  bool _creating = false;
  MediaEngineException? _error;
  RenderParams? _sent;

  @override
  void initState() {
    super.initState();
    _engine = ref.read(mediaEngineProvider);
  }

  @override
  void dispose() {
    final preview = _preview;
    if (preview != null) unawaited(_engine.disposePreview(preview.textureId));
    super.dispose();
  }

  Future<void> _create(Size box) async {
    if (_preview != null || _creating || box.isEmpty) return;
    final session = ref.read(photoEditorProvider(widget.projectId)).value;
    if (session == null) return;
    _creating = true;
    try {
      final preview = await _engine.createPhotoPreview(
        session.project.media.uri,
        maxPx: previewMaxPx(
          media: session.project.media,
          box: box,
          devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
        ),
      );
      if (!mounted) {
        unawaited(_engine.disposePreview(preview.textureId));
        return;
      }
      setState(() => _preview = preview);
      _push();
    } on MediaEngineException catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      _creating = false;
    }
  }

  /// Sends the current edit to the engine, skipping unchanged params.
  void _push() {
    final preview = _preview;
    final provider = photoEditorProvider(widget.projectId);
    final session = ref.read(provider).value;
    if (preview == null || session == null) return;
    final params = RenderParams.fromEdit(
      session.edit,
      ref.read(provider.notifier).preset,
    );
    if (params == _sent) return;
    _sent = params;
    unawaited(_engine.updateEdit(preview.textureId, params));
  }

  void _compare({required bool original}) {
    final preview = _preview;
    if (preview == null) return;
    unawaited(_engine.setShowOriginal(preview.textureId, original: original));
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(photoEditorProvider(widget.projectId), (_, _) => _push());

    return LayoutBuilder(
      builder: (context, constraints) {
        final preview = _preview;
        if (preview == null) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => unawaited(_create(constraints.biggest)),
          );
          return Center(
            child: _error == null
                ? const SizedBox.shrink()
                : Text(
                    "This photo can't be opened. Your edit is safe.",
                    style: context.type.body,
                    textAlign: TextAlign.center,
                  ),
          );
        }
        return Center(
          child: AspectRatio(
            aspectRatio: preview.width / preview.height,
            child: GestureDetector(
              key: const Key('editor-preview'),
              onLongPressStart: (_) => _compare(original: true),
              onLongPressEnd: (_) => _compare(original: false),
              onLongPressCancel: () => _compare(original: false),
              child: Texture(textureId: preview.textureId),
            ),
          ),
        );
      },
    );
  }
}
