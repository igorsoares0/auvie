import 'package:auvie/app/theme/app_theme.dart';
import 'package:auvie/app/theme/spacing.dart';
import 'package:auvie/core/models/tone_curve.dart';
import 'package:flutter/material.dart';

enum CurveChannel { rgb, red, green, blue }

extension CurvesChannels on ToneCurves {
  ToneCurve channel(CurveChannel c) => switch (c) {
    CurveChannel.rgb => master,
    CurveChannel.red => red,
    CurveChannel.green => green,
    CurveChannel.blue => blue,
  };

  ToneCurves withChannel(CurveChannel c, ToneCurve curve) => switch (c) {
    CurveChannel.rgb => copyWith(master: curve),
    CurveChannel.red => copyWith(red: curve),
    CurveChannel.green => copyWith(green: curve),
    CurveChannel.blue => copyWith(blue: curve),
  };
}

/// Pure point edits, kept apart from gestures so they can be tested.
abstract final class CurveEdits {
  /// Points closer than this (in 0…1) can't share an x.
  static const minGap = 0.02;

  /// Adds a point at ([x], [y]) and returns the curve and the new index.
  static (ToneCurve, int) add(ToneCurve curve, double x, double y) {
    final points = [...curve.points];
    var index = points.indexWhere((p) => p.x > x);
    if (index < 0) index = points.length;
    final before = index > 0 ? points[index - 1].x : -1.0;
    final after = index < points.length ? points[index].x : 2.0;
    if (x - before < minGap || after - x < minGap) return (curve, -1);
    points.insert(index, CurvePoint(x: x, y: y.clamp(0, 1)));
    return (ToneCurve(points: points), index);
  }

  /// Moves point [index]; endpoints only move vertically, others stay
  /// between their neighbours.
  static ToneCurve move(ToneCurve curve, int index, double x, double y) {
    final points = [...curve.points];
    final last = points.length - 1;
    final nx = index == 0 || index == last
        ? points[index].x
        : x.clamp(points[index - 1].x + minGap, points[index + 1].x - minGap);
    points[index] = CurvePoint(x: nx, y: y.clamp(0, 1));
    return ToneCurve(points: points);
  }

  /// Removes a middle point; endpoints stay.
  static ToneCurve remove(ToneCurve curve, int index) {
    if (index <= 0 || index >= curve.points.length - 1) return curve;
    return ToneCurve(points: [...curve.points]..removeAt(index));
  }
}

/// CURVE: drag points, tap to add, hold a point to remove it, double-tap to
/// reset the channel.
class CurveEditor extends StatefulWidget {
  const new({
    required this.curves,
    required this.onPreview,
    required this.onCommit,
    required this.onRecord,
    super.key,
  });

  final ToneCurves curves;
  final ValueChanged<ToneCurves> onPreview;
  final VoidCallback onCommit;
  final ValueChanged<ToneCurves> onRecord;

  @override
  State<CurveEditor> createState() => _CurveEditorState();
}

class _CurveEditorState extends State<CurveEditor> {
  CurveChannel _channel = CurveChannel.rgb;
  int? _dragging;

  static const _hitRadius = 24.0;

  ToneCurve get _curve => widget.curves.channel(_channel);

  Offset _toUnit(Offset local, Size size) => Offset(
    (local.dx / size.width).clamp(0, 1),
    (1 - local.dy / size.height).clamp(0, 1),
  );

  int? _nearest(Offset local, Size size) {
    for (final (i, p) in _curve.points.indexed) {
      final position = Offset(p.x * size.width, (1 - p.y) * size.height);
      if ((position - local).distance <= _hitRadius) return i;
    }
    return null;
  }

  void _emit(ToneCurve curve) =>
      widget.onPreview(widget.curves.withChannel(_channel, curve));

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AuvieSpacing.gutter),
      child: Column(
        children: [
          Row(
            children: [
              for (final c in CurveChannel.values)
                GestureDetector(
                  key: Key('curve-${c.name}'),
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _channel = c),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 18, 10),
                    child: Text(
                      c == CurveChannel.rgb ? 'RGB' : c.name[0].toUpperCase(),
                      style: context.type.label.copyWith(
                        color: c == _channel
                            ? palette.foreground
                            : palette.muted,
                      ),
                    ),
                  ),
                ),
              const Spacer(),
              Text('DOUBLE-TAP TO RESET', style: context.type.tag),
            ],
          ),
          const SizedBox(height: AuvieSpacing.s6),
          SizedBox(
            height: 132,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final size = constraints.biggest;
                return GestureDetector(
                  key: const Key('curve-area'),
                  behavior: HitTestBehavior.opaque,
                  onTapUp: (d) {
                    if (_nearest(d.localPosition, size) != null) return;
                    final unit = _toUnit(d.localPosition, size);
                    final (curve, index) = CurveEdits.add(
                      _curve,
                      unit.dx,
                      unit.dy,
                    );
                    if (index >= 0) {
                      widget.onRecord(
                        widget.curves.withChannel(_channel, curve),
                      );
                    }
                  },
                  onLongPressStart: (d) {
                    final i = _nearest(d.localPosition, size);
                    if (i == null) return;
                    widget.onRecord(
                      widget.curves.withChannel(
                        _channel,
                        CurveEdits.remove(_curve, i),
                      ),
                    );
                  },
                  onDoubleTap: () => widget.onRecord(
                    widget.curves.withChannel(_channel, const ToneCurve()),
                  ),
                  onPanStart: (d) =>
                      _dragging = _nearest(d.localPosition, size),
                  onPanUpdate: (d) {
                    final i = _dragging;
                    if (i == null) return;
                    final unit = _toUnit(d.localPosition, size);
                    _emit(CurveEdits.move(_curve, i, unit.dx, unit.dy));
                  },
                  onPanEnd: (_) {
                    if (_dragging != null) widget.onCommit();
                    _dragging = null;
                  },
                  child: CustomPaint(
                    painter: _CurvePainter(
                      curve: _curve,
                      line: _channelColor(palette.foreground),
                      grid: palette.hairline,
                      guide: palette.hairlineStrong,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _channelColor(Color fallback) => switch (_channel) {
    CurveChannel.rgb => fallback,
    CurveChannel.red => const Color(0xFFE0573C),
    CurveChannel.green => const Color(0xFF7FA37A),
    CurveChannel.blue => const Color(0xFF6F8CB0),
  };
}

class _CurvePainter extends CustomPainter {
  new({
    required this.curve,
    required this.line,
    required this.grid,
    required this.guide,
  });

  final ToneCurve curve;
  final Color line;
  final Color grid;
  final Color guide;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = grid
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    canvas.drawRect(Offset.zero & size, gridPaint);
    for (var i = 1; i < 4; i++) {
      final x = size.width * i / 4;
      final y = size.height * i / 4;
      canvas
        ..drawLine(Offset(x, 0), Offset(x, size.height), gridPaint)
        ..drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, 0),
      Paint()
        ..color = guide
        ..strokeWidth = 1,
    );

    final sample = curve.sampler();
    final path = Path();
    for (var i = 0; i <= 64; i++) {
      final x = i / 64;
      final point = Offset(x * size.width, (1 - sample(x)) * size.height);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = line
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    );
    for (final p in curve.points) {
      canvas.drawCircle(
        Offset(p.x * size.width, (1 - p.y) * size.height),
        4,
        Paint()..color = line,
      );
    }
  }

  @override
  bool shouldRepaint(_CurvePainter old) =>
      old.curve != curve || old.line != line || old.grid != grid;
}
