import 'package:auvie/app/theme/app_theme.dart';
import 'package:auvie/app/theme/colors.dart';
import 'package:auvie/app/widgets/auvie_icon.dart';
import 'package:auvie/core/models/elements.dart';
import 'package:auvie/features/editor/elements/element_assets.dart';
import 'package:auvie/features/editor/elements/element_assets_provider.dart';
import 'package:auvie/features/editor/elements/element_geometry.dart';
import 'package:auvie/features/editor/elements/elements_painter.dart';
import 'package:auvie/features/editor/elements/stroke_smoothing.dart';
import 'package:auvie/features/editor/photo/editor_session.dart';
import 'package:auvie/features/editor/photo/photo_editor_controller.dart';
import 'package:auvie/features/editor/text/path_text_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Elements over the photo, and the gestures that edit them: tap to select
/// (or to add text in TYPE), drag / pinch / twist the selection, draw with
/// BRUSH or TEXT BRUSH.
class ElementsLayer extends ConsumerStatefulWidget {
  const new({required this.projectId, super.key});

  final String projectId;

  /// Points closer than this (output px) aren't recorded while drawing.
  static const minPointDistance = 2.0;

  @override
  ConsumerState<ElementsLayer> createState() => _ElementsLayerState();
}

class _ElementsLayerState extends ConsumerState<ElementsLayer> {
  /// TEXT BRUSH line being drawn (output fractions).
  final _path = <StrokePoint>[];
  int? _pointer;
  Offset? _lastPoint;
  bool _transforming = false;
  double _lastScale = 1;
  double _lastRotation = 0;

  PhotoEditor get _controller =>
      ref.read(photoEditorProvider(widget.projectId).notifier);

  static bool _drawing(EditorSession s) =>
      s.editingElementId == null &&
      (s.tool == EditorTool.brush ||
          (s.tool == EditorTool.type && s.typeMode == TypeMode.textBrush));

  StrokePoint _point(PointerEvent e, Size size) {
    final pressure = e.pressureMax > e.pressureMin
        ? ((e.pressure - e.pressureMin) / (e.pressureMax - e.pressureMin))
              .clamp(0.0, 1.0)
        : null;
    return StrokePoint(
      x: (e.localPosition.dx / size.width).clamp(0, 1),
      y: (e.localPosition.dy / size.height).clamp(0, 1),
      pressure: pressure,
    );
  }

  void _down(PointerDownEvent e, Size size, EditorSession s) {
    if (_pointer != null) return;
    _pointer = e.pointer;
    _lastPoint = e.localPosition;
    final p = _point(e, size);
    if (s.tool == EditorTool.brush) {
      _controller.beginStroke(p);
    } else {
      setState(
        () => _path
          ..clear()
          ..add(p),
      );
    }
  }

  void _move(PointerMoveEvent e, Size size, EditorSession s) {
    if (e.pointer != _pointer) return;
    final last = _lastPoint;
    if (last != null &&
        (e.localPosition - last).distance < ElementsLayer.minPointDistance) {
      return;
    }
    _lastPoint = e.localPosition;
    final p = _point(e, size);
    if (s.tool == EditorTool.brush) {
      _controller.extendStroke(p);
    } else {
      setState(() => _path.add(p));
    }
  }

  void _up(PointerEvent e, EditorSession s) {
    if (e.pointer != _pointer) return;
    _pointer = null;
    _lastPoint = null;
    if (s.tool == EditorTool.brush) {
      _controller.endStroke();
    } else {
      final path = smoothStroke(List<StrokePoint>.of(_path));
      setState(_path.clear);
      _controller.addTextPath(path);
    }
  }

  void _tap(Offset at, Size size, EditorSession s, ElementAssets assets) {
    final hit = ElementGeometry.hit(s.edit.elements, at, size, assets);
    if (hit != null) {
      _controller.selectElement(hit);
    } else if (s.tool == EditorTool.type && s.typeMode == TypeMode.setType) {
      _controller.addText(
        center: Offset(at.dx / size.width, at.dy / size.height),
      );
    } else {
      _controller.selectElement(null);
    }
  }

  void _scaleStart(
    ScaleStartDetails d,
    Size size,
    EditorSession s,
    ElementAssets assets,
  ) {
    final hit = ElementGeometry.hit(
      s.edit.elements,
      d.localFocalPoint,
      size,
      assets,
    );
    final selected = s.selected;
    final onSelected =
        selected != null &&
        (ElementGeometry.of(
              selected,
              size,
              assets,
            )?.contains(d.localFocalPoint, slop: 16) ??
            false);
    if (!onSelected && hit == null) return;
    if (!onSelected) _controller.selectElement(hit);
    _transforming = true;
    _lastScale = 1;
    _lastRotation = 0;
  }

  void _scaleUpdate(ScaleUpdateDetails d, Size size) {
    if (!_transforming) return;
    _controller.transformSelected(
      size,
      delta: d.focalPointDelta,
      scale: d.scale / _lastScale,
      rotation: d.rotation - _lastRotation,
    );
    _lastScale = d.scale;
    _lastRotation = d.rotation;
  }

  void _scaleEnd() {
    if (_transforming) _controller.commit();
    _transforming = false;
  }

  @override
  Widget build(BuildContext context) {
    final session = ref
        .watch(photoEditorProvider(widget.projectId))
        .requireValue;
    final assets = ref.watch(elementAssetsProvider).value;
    if (assets == null) return const SizedBox.shrink();
    final drawing = _drawing(session);

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final selected = session.editingElementId == null
            ? session.selected
            : null;
        final frame = selected == null
            ? null
            : ElementGeometry.of(selected, size, assets);
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  key: const Key('elements-paint'),
                  painter: ElementsPainter(
                    elements: session.edit.elements,
                    assets: assets,
                  ),
                ),
              ),
            ),
            if (_path.length > 1)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _GuidePainter([
                      for (final p in _path)
                        Offset(p.x * size.width, p.y * size.height),
                    ]),
                  ),
                ),
              ),
            if (frame != null)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _SelectionPainter(
                      frame,
                      pathEnd: switch (selected) {
                        TextPathElement(:final path) when path.isNotEmpty =>
                          frame.toOutput(
                            Offset(
                                  path.last.x * size.width,
                                  path.last.y * size.height,
                                ) -
                                frame.pivot,
                          ),
                        _ => null,
                      },
                    ),
                  ),
                ),
              ),
            Positioned.fill(
              child: drawing
                  ? Listener(
                      key: const Key('elements-draw'),
                      behavior: HitTestBehavior.opaque,
                      onPointerDown: (e) => _down(e, size, session),
                      onPointerMove: (e) => _move(e, size, session),
                      onPointerUp: (e) => _up(e, session),
                      onPointerCancel: (e) => _up(e, session),
                    )
                  : GestureDetector(
                      key: const Key('elements-gestures'),
                      behavior: HitTestBehavior.translucent,
                      onTapUp: (d) =>
                          _tap(d.localPosition, size, session, assets),
                      onScaleStart: (d) =>
                          _scaleStart(d, size, session, assets),
                      onScaleUpdate: (d) => _scaleUpdate(d, size),
                      onScaleEnd: (_) => _scaleEnd(),
                    ),
            ),
            if (frame != null && !drawing)
              _Pill(
                bounds: frame.bounds,
                area: size,
                canEdit: selected is TextElement || selected is TextPathElement,
                onDuplicate: _controller.duplicateSelected,
                onDelete: _controller.deleteSelected,
                onEdit: _controller.editSelectedText,
              ),
          ],
        );
      },
    );
  }
}

/// Dashed baseline while drawing a TEXT BRUSH line.
class _GuidePainter extends CustomPainter {
  new(this.points);

  final List<Offset> points;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AuvieColors.bone.withValues(alpha: 0.6);
    for (final metric in PathTextPainter.smoothPath(points).computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += 6) {
        canvas.drawPath(metric.extractPath(d, d + 2), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_GuidePainter old) => old.points.length != points.length;
}

/// Hairline around the selection; for a TEXT BRUSH line, the ring where
/// the next letter lands (handoff 04).
class _SelectionPainter extends CustomPainter {
  new(this.frame, {this.pathEnd});

  final ElementFrame frame;
  final Offset? pathEnd;

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AuvieColors.bone.withValues(alpha: 0.8);
    final c = frame.corners;
    canvas.drawPath(Path()..addPolygon(c, true), line);
    final end = pathEnd;
    if (end != null) {
      canvas
        ..drawCircle(end, 11, line)
        ..drawCircle(end, 1.5, Paint()..color = AuvieColors.bone);
    }
  }

  @override
  bool shouldRepaint(_SelectionPainter old) =>
      old.frame.corners.toString() != frame.corners.toString() ||
      old.pathEnd != pathEnd;
}

/// Duplicate / delete / EDIT, above the selection (handoff 04).
class _Pill extends StatelessWidget {
  const new({
    required this.bounds,
    required this.area,
    required this.canEdit,
    required this.onDuplicate,
    required this.onDelete,
    required this.onEdit,
  });

  final Rect bounds;
  final Size area;
  final bool canEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  static const _cell = 40.0;
  static const _height = 34.0;

  @override
  Widget build(BuildContext context) {
    final width = _cell * (canEdit ? 3 : 2);
    final left = (bounds.center.dx - width / 2).clamp(0.0, area.width - width);
    final above = bounds.top - _height - 10;
    final top = above >= 0
        ? above
        : (bounds.bottom + 10).clamp(0.0, area.height - _height);
    const divider = BorderSide(color: Color(0x2EEFE8DC));

    Widget cell(
      Key key,
      Widget child,
      VoidCallback onTap, {
      bool first = false,
    }) => GestureDetector(
      key: key,
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: _cell,
        height: _height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: first ? null : const Border(left: divider),
        ),
        child: child,
      ),
    );

    return Positioned(
      left: left,
      top: top,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xB3161412),
          border: Border.all(color: const Color(0x59EFE8DC)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            cell(
              const Key('element-duplicate'),
              const AuvieIcon(
                AuvieIcons.dup,
                size: 17,
                color: AuvieColors.bone,
              ),
              onDuplicate,
              first: true,
            ),
            cell(
              const Key('element-delete'),
              const AuvieIcon(
                AuvieIcons.trash,
                size: 17,
                color: AuvieColors.bone,
              ),
              onDelete,
            ),
            if (canEdit)
              cell(
                const Key('element-edit'),
                Text(
                  'EDIT',
                  style: context.type.tag.copyWith(
                    fontSize: 10,
                    color: AuvieColors.bone,
                  ),
                ),
                onEdit,
              ),
          ],
        ),
      ),
    );
  }
}
