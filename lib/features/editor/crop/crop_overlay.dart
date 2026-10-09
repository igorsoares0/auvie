import 'package:auvie/app/theme/app_theme.dart';
import 'package:auvie/core/models/crop.dart';
import 'package:flutter/material.dart';

/// The crop frame drawn over the whole (straightened) photo while the CROP
/// family is open: veil outside, 1 px frame, L corners, thirds while
/// dragging. Drag inside to move, drag a corner to resize.
class CropOverlay extends StatefulWidget {
  const new({
    required this.rect,
    required this.onMove,
    required this.onResize,
    required this.onEnd,
    super.key,
  });

  /// Crop area in frame fractions (the displayed photo is the frame).
  final NormalizedRect rect;

  /// Deltas in frame fractions.
  final void Function(double dx, double dy) onMove;
  final void Function(CropCorner corner, double dx, double dy) onResize;
  final VoidCallback onEnd;

  /// Distance (logical px) within which a touch grabs a corner.
  static const cornerReach = 32.0;

  @override
  State<CropOverlay> createState() => _CropOverlayState();
}

enum _Drag { none, move, corner }

class _CropOverlayState extends State<CropOverlay> {
  _Drag _drag = _Drag.none;
  CropCorner? _corner;

  Rect _pixels(Size size) => Rect.fromLTWH(
    widget.rect.left * size.width,
    widget.rect.top * size.height,
    widget.rect.width * size.width,
    widget.rect.height * size.height,
  );

  void _start(Offset at, Size size) {
    final r = _pixels(size);
    final corners = {
      CropCorner.topLeft: r.topLeft,
      CropCorner.topRight: r.topRight,
      CropCorner.bottomRight: r.bottomRight,
      CropCorner.bottomLeft: r.bottomLeft,
    };
    for (final MapEntry(key: corner, value: point) in corners.entries) {
      if ((point - at).distance <= CropOverlay.cornerReach) {
        setState(() {
          _drag = _Drag.corner;
          _corner = corner;
        });
        return;
      }
    }
    setState(() => _drag = r.contains(at) ? _Drag.move : _Drag.none);
  }

  void _update(Offset delta, Size size) {
    final dx = delta.dx / size.width;
    final dy = delta.dy / size.height;
    switch (_drag) {
      case _Drag.move:
        widget.onMove(dx, dy);
      case _Drag.corner:
        widget.onResize(_corner!, dx, dy);
      case _Drag.none:
        break;
    }
  }

  void _end() {
    if (_drag != _Drag.none) widget.onEnd();
    setState(() {
      _drag = _Drag.none;
      _corner = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        return GestureDetector(
          key: const Key('crop-overlay'),
          behavior: HitTestBehavior.opaque,
          onPanStart: (d) => _start(d.localPosition, size),
          onPanUpdate: (d) => _update(d.delta, size),
          onPanEnd: (_) => _end(),
          onPanCancel: _end,
          child: CustomPaint(
            size: size,
            painter: _CropPainter(
              rect: _pixels(size),
              veil: palette.veil,
              line: const Color(0xFFEFE8DC),
              thirds: _drag != _Drag.none,
            ),
          ),
        );
      },
    );
  }
}

class _CropPainter extends CustomPainter {
  new({
    required this.rect,
    required this.veil,
    required this.line,
    required this.thirds,
  });

  final Rect rect;
  final Color veil;

  /// Anything drawn on the photo keeps its light treatment in both themes.
  final Color line;
  final bool thirds;

  @override
  void paint(Canvas canvas, Size size) {
    final outside = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addRect(rect);
    canvas.drawPath(outside, Paint()..color = veil);

    final hairline = Paint()
      ..color = line
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    canvas.drawRect(rect.deflate(0.5), hairline);

    if (thirds) {
      final guide = Paint()
        ..color = line.withValues(alpha: 0.4)
        ..strokeWidth = 1;
      for (var i = 1; i < 3; i++) {
        final x = rect.left + rect.width * i / 3;
        final y = rect.top + rect.height * i / 3;
        canvas
          ..drawLine(Offset(x, rect.top), Offset(x, rect.bottom), guide)
          ..drawLine(Offset(rect.left, y), Offset(rect.right, y), guide);
      }
    }

    const arm = 16.0;
    final corner = Paint()
      ..color = line
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    for (final (point, sx, sy) in [
      (rect.topLeft, 1.0, 1.0),
      (rect.topRight, -1.0, 1.0),
      (rect.bottomRight, -1.0, -1.0),
      (rect.bottomLeft, 1.0, -1.0),
    ]) {
      canvas.drawPath(
        Path()
          ..moveTo(point.dx + sx * arm, point.dy)
          ..lineTo(point.dx, point.dy)
          ..lineTo(point.dx, point.dy + sy * arm),
        corner,
      );
    }
  }

  @override
  bool shouldRepaint(_CropPainter old) =>
      old.rect != rect || old.veil != veil || old.thirds != thirds;
}
