import 'dart:async';

import 'package:auvie/app/theme/app_theme.dart';
import 'package:auvie/core/native/media_engine.dart';
import 'package:auvie/core/native/media_engine_provider.dart';
import 'package:auvie/core/native/preview_size.dart';
import 'package:auvie/core/native/render_params.dart';
import 'package:auvie/features/editor/adjustments/adjustment_family.dart';
import 'package:auvie/features/editor/crop/crop_overlay.dart';
import 'package:auvie/features/editor/elements/elements_layer.dart';
import 'package:auvie/features/editor/shell/editor_controller.dart';
import 'package:auvie/features/editor/shell/editor_session.dart';
import 'package:auvie/features/editor/video/video_playback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The developed photo or video, rendered by the engine at its on-screen
/// size. Hold it to see the original. A video preview plays through
/// [VideoPlayback], looping inside the trim.
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
  ({int width, int height})? _sentSize;
  ({int start, int end, bool muted})? _sentTimeline;
  VideoPlayback? _playback;

  @override
  void initState() {
    super.initState();
    _engine = ref.read(mediaEngineProvider);
  }

  @override
  void dispose() {
    final preview = _preview;
    if (preview != null) {
      _playback?.detach(preview.textureId);
      unawaited(_engine.disposePreview(preview.textureId));
    }
    super.dispose();
  }

  Future<PhotoPreview> _open(EditorSession session, int maxPx) async {
    final uri = session.project.media.uri;
    if (!session.isVideo) {
      return await _engine.createPhotoPreview(uri, maxPx: maxPx);
    }
    final video = await _engine.createVideoPreview(uri, maxPx: maxPx);
    if (mounted) {
      final playback = ref.read(
        videoPlaybackProvider(widget.projectId).notifier,
      );
      _playback = playback;
      playback.attach(video);
    }
    return (
      textureId: video.textureId,
      width: video.width,
      height: video.height,
    );
  }

  Future<void> _create(Size box) async {
    if (_preview != null || _creating || box.isEmpty) return;
    final session = ref.read(editorControllerProvider(widget.projectId)).value;
    if (session == null) return;
    _creating = true;
    try {
      final preview = await _open(
        session,
        previewMaxPx(
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

  /// While the CROP family is open the whole frame is shown, with the crop
  /// drawn over it.
  static bool _cropping(EditorSession s) =>
      s.tool == EditorTool.adjust && s.family == AdjustmentFamily.crop;

  /// Width / height of what the preview shows.
  static double _shownRatio(EditorSession s) {
    final ratio = s.project.media.aspectRatio;
    return _cropping(s)
        ? s.edit.crop.orientedRatio(ratio)
        : s.edit.crop.outputRatio(ratio);
  }

  /// Keeps the engine's preview at the size it is shown at.
  void _resize(Size box) {
    final preview = _preview;
    final session = ref.read(editorControllerProvider(widget.projectId)).value;
    if (preview == null || session == null || box.isEmpty) return;
    final size = previewPixelSize(
      aspectRatio: _shownRatio(session),
      box: box,
      devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
    );
    if (size == _sentSize) return;
    _sentSize = size;
    unawaited(
      _engine.resizePreview(
        preview.textureId,
        width: size.width,
        height: size.height,
      ),
    );
  }

  /// Sends the current edit to the engine, skipping unchanged params.
  void _push() {
    final preview = _preview;
    final provider = editorControllerProvider(widget.projectId);
    final session = ref.read(provider).value;
    if (preview == null || session == null) return;
    final params = RenderParams.fromEdit(
      session.edit,
      ref.read(provider.notifier).preset,
      mediaRatio: session.project.media.aspectRatio,
      cropping: _cropping(session),
    );
    if (params != _sent) {
      _sent = params;
      unawaited(_engine.updateEdit(preview.textureId, params));
    }
    if (session.isVideo) _pushTimeline(preview.textureId, session);
  }

  /// Keeps the player looping inside the trim, with the sound as edited.
  void _pushTimeline(int textureId, EditorSession session) {
    final duration = session.durationMs;
    if (duration <= 0) return;
    final timeline = session.timeline;
    final next = (
      start: timeline.trimStartMs,
      end: timeline.endMs(duration),
      muted: timeline.muted,
    );
    final sent = _sentTimeline;
    if (next == sent) return;
    _sentTimeline = next;
    if (sent == null || sent.start != next.start || sent.end != next.end) {
      unawaited(
        _engine.setPlaybackRange(
          textureId,
          startMs: next.start,
          endMs: next.end,
        ),
      );
    }
    if (sent == null || sent.muted != next.muted) {
      unawaited(_engine.setVideoMuted(textureId, muted: next.muted));
    }
  }

  void _compare({required bool original}) {
    final preview = _preview;
    if (preview == null) return;
    unawaited(_engine.setShowOriginal(preview.textureId, original: original));
  }

  @override
  Widget build(BuildContext context) {
    final provider = editorControllerProvider(widget.projectId);
    ref.listen(provider, (_, _) => _push());
    final session = ref.watch(provider).value;

    return LayoutBuilder(
      builder: (context, constraints) {
        final preview = _preview;
        final box = constraints.biggest;
        if (preview == null || session == null) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => unawaited(_create(box)),
          );
          return Center(
            child: _error == null
                ? const SizedBox.shrink()
                : Text(
                    session?.isVideo ?? false
                        ? "This video can't be played. Your edit is safe."
                        : "This photo can't be opened. Your edit is safe.",
                    style: context.type.body,
                    textAlign: TextAlign.center,
                  ),
          );
        }
        WidgetsBinding.instance.addPostFrameCallback((_) => _resize(box));
        final cropping = _cropping(session);
        final controller = ref.read(provider.notifier);
        final ratio = session.project.media.aspectRatio;
        final crop = session.edit.crop;
        return Center(
          child: AspectRatio(
            aspectRatio: _shownRatio(session),
            child: Stack(
              fit: StackFit.expand,
              children: [
                GestureDetector(
                  key: const Key('editor-preview'),
                  onLongPressStart: cropping
                      ? null
                      : (_) => _compare(original: true),
                  onLongPressEnd: cropping
                      ? null
                      : (_) => _compare(original: false),
                  onLongPressCancel: cropping
                      ? null
                      : () => _compare(original: false),
                  child: Texture(textureId: preview.textureId),
                ),
                if (!cropping)
                  Positioned.fill(
                    child: ElementsLayer(projectId: widget.projectId),
                  ),
                if (cropping)
                  CropOverlay(
                    rect: crop.rect,
                    onMove: (dx, dy) => controller.preview(
                      session.edit.copyWith(
                        crop: controller.currentCrop.moved(
                          dx,
                          dy,
                          mediaRatio: ratio,
                        ),
                      ),
                    ),
                    onResize: (corner, dx, dy) => controller.preview(
                      session.edit.copyWith(
                        crop: controller.currentCrop.resizedFromCorner(
                          corner,
                          dx,
                          dy,
                          mediaRatio: ratio,
                        ),
                      ),
                    ),
                    onEnd: controller.commit,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
