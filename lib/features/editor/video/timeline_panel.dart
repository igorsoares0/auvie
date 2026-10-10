import 'dart:math' as math;

import 'package:auvie/app/theme/app_theme.dart';
import 'package:auvie/app/theme/palette.dart';
import 'package:auvie/app/theme/spacing.dart';
import 'package:auvie/app/theme/typography.dart';
import 'package:auvie/app/widgets/auvie_icon.dart';
import 'package:auvie/core/models/elements.dart';
import 'package:auvie/features/editor/shell/editor_controller.dart';
import 'package:auvie/features/editor/shell/editor_session.dart';
import 'package:auvie/features/editor/video/timeline_scale.dart';
import 'package:auvie/features/editor/video/video_media_providers.dart';
import 'package:auvie/features/editor/video/video_playback.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The TRIM tool (handoff 05): the whole clip as a FILM strip with trim
/// handles, the TYPE / BRUSH / ADD lanes with when each element shows, the
/// SOUND waveform, a ruler and the playhead across all of them.
class TimelinePanel extends ConsumerWidget {
  const new({required this.projectId, super.key});

  final String projectId;

  static const labelWidth = 40.0;
  static const filmHeight = 46.0;
  static const laneHeight = 24.0;
  static const laneGap = 6.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(editorControllerProvider(projectId)).requireValue;
    final position = ref.watch(
      videoPlaybackProvider(projectId).select((p) => p.positionMs),
    );
    final duration = session.durationMs;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AuvieSpacing.gutter,
        AuvieSpacing.s14,
        AuvieSpacing.gutter,
        0,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final scale = TimelineScale(
            durationMs: duration,
            width: math.max(0, constraints.maxWidth - labelWidth),
          );
          final lanes = laneBars(session);
          const lanesTop = filmHeight + 10;
          const lanesBottom = lanesTop + 4 * laneHeight + 3 * laneGap;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Row(
                    label: 'FILM',
                    height: filmHeight,
                    child: _FilmStrip(projectId: projectId, scale: scale),
                  ),
                  const SizedBox(height: 10),
                  for (final kind in LaneKind.values) ...[
                    _Row(
                      label: kind.label,
                      height: laneHeight,
                      child: _Lane(
                        key: Key('lane-${kind.name}'),
                        projectId: projectId,
                        kind: kind,
                        bars: lanes[kind]!,
                        selectedId: session.selectedElementId,
                        scale: scale,
                      ),
                    ),
                    const SizedBox(height: laneGap),
                  ],
                  _Row(
                    label: 'SOUND',
                    height: laneHeight,
                    child: _SoundLane(projectId: projectId),
                  ),
                  const SizedBox(height: AuvieSpacing.s6),
                  Padding(
                    padding: const EdgeInsets.only(left: labelWidth),
                    child: _Ruler(scale: scale),
                  ),
                ],
              ),
              Positioned(
                left: labelWidth + scale.xOf(position) - 4,
                top: -7,
                height: lanesBottom + 7,
                width: 8,
                child: IgnorePointer(
                  child: CustomPaint(
                    key: const Key('playhead'),
                    painter: _PlayheadPainter(context.palette.accent),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// The three element lanes.
enum LaneKind {
  type('TYPE'),
  brush('BRUSH'),
  add('ADD');

  new(this.label);

  final String label;

  static LaneKind? of(EditElement element) => switch (element) {
    TextElement() || TextPathElement() => type,
    BrushElement() => brush,
    StickerElement() || OverlayElement() => add,
    FrameElement() => null,
  };
}

/// A lane bar with what it says.
typedef LabeledBar = ({String id, TimeRange range, String label});

/// The bars of each lane, in z-order. Elements without a time span the
/// whole clip.
Map<LaneKind, List<LabeledBar>> laneBars(EditorSession session) {
  final whole = TimeRange(startMs: 0, endMs: math.max(1, session.durationMs));
  final lanes = {for (final kind in LaneKind.values) kind: <LabeledBar>[]};
  var strokes = 0;
  String name(String id) => id.replaceAll(RegExp('[_-]+'), ' ').toUpperCase();
  for (final element in session.edit.elements) {
    final kind = LaneKind.of(element);
    if (kind == null) continue;
    final label = switch (element) {
      TextElement(:final text) || TextPathElement(:final text) =>
        text.trim().isEmpty ? 'TEXT' : text.trim().toUpperCase(),
      BrushElement() => 'STROKE ${++strokes}',
      StickerElement(:final assetId) ||
      OverlayElement(:final assetId) => name(assetId),
      FrameElement() => '',
    };
    lanes[kind]!.add((
      id: element.id,
      range: element.time ?? whole,
      label: label,
    ));
  }
  return lanes;
}

class _Row extends StatelessWidget {
  const new({required this.label, required this.height, required this.child});

  final String label;
  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        children: [
          SizedBox(
            width: TimelinePanel.labelWidth,
            child: Text(
              label,
              style: AuvieTypography.sans(
                9,
                color: context.palette.muted,
                letterSpacingEm: 0.12,
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

enum _FilmDrag { trimStart, trimEnd, scrub }

/// The clip's frames, veiled outside the trim, with the trim handles.
/// Dragging a handle trims; dragging elsewhere scrubs; tapping seeks.
class _FilmStrip extends ConsumerStatefulWidget {
  const new({required this.projectId, required this.scale});

  final String projectId;
  final TimelineScale scale;

  @override
  ConsumerState<_FilmStrip> createState() => _FilmStripState();
}

class _FilmStripState extends ConsumerState<_FilmStrip> {
  static const _handleSlop = 18.0;
  _FilmDrag? _drag;
  int _lastMs = 0;

  EditorController get _controller =>
      ref.read(editorControllerProvider(widget.projectId).notifier);

  VideoPlayback get _player =>
      ref.read(videoPlaybackProvider(widget.projectId).notifier);

  void _start(double x, EditorSession session) {
    final timeline = session.timeline;
    final scale = widget.scale;
    final startX = scale.xOf(timeline.trimStartMs);
    final endX = scale.xOf(timeline.endMs(session.durationMs));
    _player.pause();
    if ((x - startX).abs() <= _handleSlop &&
        (x - startX).abs() <= (x - endX).abs()) {
      _drag = _FilmDrag.trimStart;
    } else if ((x - endX).abs() <= _handleSlop) {
      _drag = _FilmDrag.trimEnd;
    } else {
      _drag = _FilmDrag.scrub;
    }
    _update(x);
  }

  void _update(double x) {
    final ms = widget.scale.msAt(x);
    switch (_drag) {
      case _FilmDrag.trimStart:
        _controller.previewTrim(startMs: ms);
        _lastMs = _session.timeline.trimStartMs;
      case _FilmDrag.trimEnd:
        _controller.previewTrim(endMs: ms);
        _lastMs = _session.timeline.endMs(_session.durationMs);
      case _FilmDrag.scrub:
        _lastMs = ms;
      case null:
        return;
    }
    _player.seek(_lastMs, exact: false);
  }

  void _end() {
    if (_drag == _FilmDrag.trimStart || _drag == _FilmDrag.trimEnd) {
      _controller.commit();
    }
    if (_drag != null) _player.seek(_lastMs);
    _drag = null;
  }

  EditorSession get _session =>
      ref.read(editorControllerProvider(widget.projectId)).requireValue;

  @override
  Widget build(BuildContext context) {
    final session = ref
        .watch(editorControllerProvider(widget.projectId))
        .requireValue;
    final palette = context.palette;
    final scale = widget.scale;
    final count = (scale.width / 34).ceil().clamp(4, 20);
    final frames = ref
        .watch(filmFramesProvider(session.project.media.uri, count))
        .value;
    final left = scale.xOf(session.timeline.trimStartMs);
    final right = scale.xOf(session.timeline.endMs(session.durationMs));

    return GestureDetector(
      key: const Key('timeline-film'),
      behavior: HitTestBehavior.opaque,
      // Handles are told apart by where the finger lands, not where the
      // drag is recognized.
      dragStartBehavior: DragStartBehavior.down,
      onTapUp: (d) {
        _player
          ..pause()
          ..seek(scale.msAt(d.localPosition.dx));
      },
      onHorizontalDragStart: (d) => _start(d.localPosition.dx, session),
      onHorizontalDragUpdate: (d) => _update(d.localPosition.dx),
      onHorizontalDragEnd: (_) => _end(),
      onHorizontalDragCancel: _end,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Row(
              children: [
                for (var i = 0; i < count; i++) ...[
                  if (i > 0) const SizedBox(width: 1),
                  Expanded(
                    child: frames == null || i >= frames.length
                        ? ColoredBox(color: palette.hairline)
                        : Image.memory(
                            frames[i],
                            fit: BoxFit.cover,
                            gaplessPlayback: true,
                          ),
                  ),
                ],
              ],
            ),
          ),
          // Veils outside the trim.
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: left,
            child: ColoredBox(color: palette.veil),
          ),
          Positioned(
            left: right,
            top: 0,
            bottom: 0,
            right: 0,
            child: ColoredBox(color: palette.veil),
          ),
          // The kept part, framed, and its handles.
          Positioned(
            left: left,
            width: math.max(0, right - left),
            top: -3,
            bottom: -3,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.symmetric(
                    horizontal: BorderSide(color: palette.foreground),
                  ),
                ),
              ),
            ),
          ),
          _Handle(key: const Key('trim-start'), x: left - 7, palette: palette),
          _Handle(
            key: const Key('trim-end'),
            x: right,
            palette: palette,
            end: true,
          ),
        ],
      ),
    );
  }
}

class _Handle extends StatelessWidget {
  const new({
    required this.x,
    required this.palette,
    this.end = false,
    super.key,
  });

  final double x;
  final AuviePalette palette;
  final bool end;

  @override
  Widget build(BuildContext context) {
    final side = BorderSide(color: palette.foreground);
    return Positioned(
      left: x,
      top: -3,
      bottom: -3,
      width: 7,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: palette.background,
            border: Border(
              top: side,
              bottom: side,
              left: end ? BorderSide.none : side,
              right: end ? side : BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }
}

/// One element lane: tap a bar to select it, drag to move it, drag the
/// selected bar's ends to change when it starts or ends.
class _Lane extends ConsumerStatefulWidget {
  const new({
    required this.projectId,
    required this.kind,
    required this.bars,
    required this.selectedId,
    required this.scale,
    super.key,
  });

  final String projectId;
  final LaneKind kind;
  final List<LabeledBar> bars;
  final String? selectedId;
  final TimelineScale scale;

  @override
  ConsumerState<_Lane> createState() => _LaneState();
}

class _LaneState extends ConsumerState<_Lane> {
  ({String id, BarDrag drag, TimeRange from, double dx})? _drag;

  EditorController get _controller =>
      ref.read(editorControllerProvider(widget.projectId).notifier);

  VideoPlayback get _player =>
      ref.read(videoPlaybackProvider(widget.projectId).notifier);

  List<LaneBar> get _hitBars => [
    for (final b in widget.bars) (id: b.id, range: b.range),
  ];

  /// Selects [id], moving the playhead into it so it shows in the preview.
  void _select(String id) {
    _controller.selectElement(id);
    final bar = widget.bars.firstWhere((b) => b.id == id);
    final position = ref.read(videoPlaybackProvider(widget.projectId));
    if (!bar.range.contains(position.positionMs)) {
      _player
        ..pause()
        ..seek(bar.range.startMs);
    }
  }

  void _tap(double x) {
    final hit = hitBar(
      _hitBars,
      x,
      widget.scale,
      selectedId: widget.selectedId,
    );
    if (hit != null) _select(hit.id);
  }

  void _dragStart(double x) {
    final hit = hitBar(
      _hitBars,
      x,
      widget.scale,
      selectedId: widget.selectedId,
    );
    if (hit == null) return;
    if (hit.id != widget.selectedId) _select(hit.id);
    final bar = widget.bars.firstWhere((b) => b.id == hit.id);
    _player.pause();
    _drag = (id: hit.id, drag: hit.drag, from: bar.range, dx: 0);
  }

  void _dragUpdate(double dx) {
    final drag = _drag;
    if (drag == null) return;
    final total = drag.dx + dx;
    _drag = (id: drag.id, drag: drag.drag, from: drag.from, dx: total);
    final range = dragRange(drag.from, drag.drag, total, widget.scale);
    _controller.previewElementTime(drag.id, range);
    // Show the frame at the edge being moved.
    _player.seek(
      drag.drag == BarDrag.end ? range.endMs - 1 : range.startMs,
      exact: false,
    );
  }

  void _dragEnd() {
    if (_drag == null) return;
    _drag = null;
    _controller.commit();
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      dragStartBehavior: DragStartBehavior.down,
      onTapUp: (d) => _tap(d.localPosition.dx),
      onHorizontalDragStart: (d) => _dragStart(d.localPosition.dx),
      onHorizontalDragUpdate: (d) => _dragUpdate(d.delta.dx),
      onHorizontalDragEnd: (_) => _dragEnd(),
      onHorizontalDragCancel: _dragEnd,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (final bar in [
            ...widget.bars.where((b) => b.id != widget.selectedId),
            ...widget.bars.where((b) => b.id == widget.selectedId),
          ])
            Positioned(
              key: Key('bar-${bar.id}'),
              left: scale.xOf(bar.range.startMs),
              width: math.max(
                2,
                scale.xOf(bar.range.endMs) - scale.xOf(bar.range.startMs),
              ),
              top: 0,
              bottom: 0,
              child: _Bar(
                kind: widget.kind,
                label: bar.label,
                selected: bar.id == widget.selectedId,
              ),
            ),
        ],
      ),
    );
  }
}

/// TYPE bars are solid with the text; BRUSH bars hatched; ADD bars
/// outlined. The selected bar shows its handles.
class _Bar extends StatelessWidget {
  const new({required this.kind, required this.label, required this.selected});

  final LaneKind kind;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final solid = kind == LaneKind.type;
    final ink = solid ? palette.background : palette.foreground;
    final icon = switch (kind) {
      LaneKind.type => AuvieIcons.type,
      LaneKind.brush => AuvieIcons.brush,
      LaneKind.add => AuvieIcons.add,
    };
    final text = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AuvieIcon(icon, size: 12, color: ink),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.clip,
            softWrap: false,
            style: AuvieTypography.sans(9.5, color: ink, letterSpacingEm: 0.08),
          ),
        ),
      ],
    );
    final handleColor = solid ? palette.background : palette.foreground;
    Widget handle({required bool left}) => Positioned(
      left: left ? 3 : null,
      right: left ? null : 3,
      top: 4,
      bottom: 4,
      width: 5,
      child: ColoredBox(color: handleColor),
    );

    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: solid
                  ? palette.foreground.withValues(alpha: selected ? 1 : 0.55)
                  : kind == LaneKind.add
                  ? palette.foreground.withValues(alpha: 0.1)
                  : null,
              border: solid
                  ? null
                  : Border.all(
                      color: palette.foreground.withValues(
                        alpha: selected ? 1 : 0.5,
                      ),
                    ),
            ),
            child: kind == LaneKind.brush
                ? CustomPaint(
                    painter: _HatchPainter(
                      palette.foreground.withValues(alpha: 0.28),
                    ),
                  )
                : null,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: selected ? 12 : 6),
            child: Align(
              alignment: solid ? Alignment.centerLeft : Alignment.center,
              child: solid
                  ? text
                  : DecoratedBox(
                      decoration: BoxDecoration(color: palette.background),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        child: text,
                      ),
                    ),
            ),
          ),
          if (selected) ...[handle(left: true), handle(left: false)],
        ],
      ),
    );
  }
}

class _HatchPainter extends CustomPainter {
  const new(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    canvas.clipRect(Offset.zero & size);
    for (var x = -size.height; x < size.width; x += 5) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_HatchPainter old) => old.color != color;
}

/// The waveform; tap to mute or unmute.
class _SoundLane extends ConsumerWidget {
  const new({required this.projectId});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final session = ref.watch(editorControllerProvider(projectId)).requireValue;
    final hasAudio = ref.watch(
      videoPlaybackProvider(projectId).select((p) => p.hasAudio),
    );
    final peaks = ref.watch(soundWaveProvider(session.project.media.uri)).value;
    final muted = session.timeline.muted;
    final silent =
        !hasAudio ||
        (peaks == null &&
            !ref.watch(soundWaveProvider(session.project.media.uri)).isLoading);
    return GestureDetector(
      key: const Key('lane-sound'),
      behavior: HitTestBehavior.opaque,
      onTap: silent
          ? null
          : ref.read(editorControllerProvider(projectId).notifier).toggleMute,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.foreground.withValues(alpha: 0.07),
          border: Border.all(color: palette.foreground.withValues(alpha: 0.14)),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (!silent && peaks != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                child: CustomPaint(
                  painter: _WavePainter(
                    peaks,
                    palette.foreground.withValues(alpha: muted ? 0.2 : 0.55),
                  ),
                ),
              ),
            if (silent || muted)
              Center(
                child: Text(
                  silent ? 'NO SOUND' : 'MUTED',
                  style: AuvieTypography.sans(
                    9,
                    color: palette.muted,
                    letterSpacingEm: 0.12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  const new(this.peaks, this.color);

  final List<double> peaks;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (peaks.isEmpty) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.butt;
    final bars = math.max(1, (size.width / 5).floor());
    final mid = size.height / 2;
    for (var i = 0; i < bars; i++) {
      final from = i * peaks.length ~/ bars;
      final to = math.max(from + 1, (i + 1) * peaks.length ~/ bars);
      var peak = 0.0;
      for (var j = from; j < to && j < peaks.length; j++) {
        peak = math.max(peak, peaks[j]);
      }
      final half = math.max(1, peak * mid);
      final x = (i + 0.5) * size.width / bars;
      canvas.drawLine(Offset(x, mid - half), Offset(x, mid + half), paint);
    }
  }

  @override
  bool shouldRepaint(_WavePainter old) =>
      old.peaks != peaks || old.color != color;
}

/// Seconds under the strip; the clip's length at the end.
class _Ruler extends StatelessWidget {
  const new({required this.scale});

  final TimelineScale scale;

  @override
  Widget build(BuildContext context) {
    final style = AuvieTypography.sans(
      8.5,
      color: context.palette.muted,
      letterSpacingEm: 0.08,
    );
    final end = scale.durationMs;
    final ticks = scale
        .ticks()
        .where((ms) => scale.width - scale.xOf(ms) > 28)
        .toList();
    return SizedBox(
      height: 14,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (final ms in ticks)
            Positioned(
              left: scale.xOf(ms),
              child: FractionalTranslation(
                translation: Offset(ms == 0 ? 0 : -0.5, 0),
                child: Text('${ms ~/ 1000}', style: style),
              ),
            ),
          Positioned(
            right: 0,
            child: Text('${(end / 1000).round()} S', style: style),
          ),
        ],
      ),
    );
  }
}

class _PlayheadPainter extends CustomPainter {
  const new(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final x = size.width / 2;
    canvas
      ..drawCircle(Offset(x, 3), 3, paint)
      ..drawRect(Rect.fromLTWH(x - 0.5, 3, 1, size.height - 3), paint);
  }

  @override
  bool shouldRepaint(_PlayheadPainter old) => old.color != color;
}
