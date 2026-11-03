import 'dart:math' as math;
import 'dart:ui';

/// Frames (spec §26) from their catalog params: drawn over the image edges.
abstract final class FrameRenderer {
  static Color _color(Object? hex) {
    if (hex is! String || hex.length != 7) return const Color(0xFFF3EEE5);
    return Color(0xFF000000 | int.parse(hex.substring(1), radix: 16));
  }

  static void paint(Canvas canvas, Size size, Map<String, Object?> params) {
    final short = size.shortestSide;
    final m = ((params['margin'] as num?)?.toDouble() ?? 0.04) * short;
    final color = _color(params['color']);
    final fill = Paint()..color = color;
    final all = Offset.zero & size;

    void border(double left, double top, double right, double bottom) {
      final inner = Rect.fromLTRB(
        left,
        top,
        size.width - right,
        size.height - bottom,
      );
      canvas.drawPath(
        Path()
          ..fillType = PathFillType.evenOdd
          ..addRect(all)
          ..addRect(inner),
        fill,
      );
    }

    switch (params['style']) {
      case 'border':
        border(m, m, m, m);
      case 'print':
        border(m, m, m, m * 3.2);
      case 'hairline':
        canvas.drawRect(
          all.deflate(m),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = short * 0.0025
            ..color = color,
        );
      case 'film35':
        border(m * 0.25, m, m * 0.25, m);
        final hole = Paint()..color = const Color(0xE6F3EEE5);
        final w = short * 0.022;
        final h = m * 0.42;
        final step = short * 0.06;
        for (var x = step / 2; x < size.width; x += step) {
          for (final y in [(m - h) / 2, size.height - m + (m - h) / 2]) {
            canvas.drawRRect(
              RRect.fromRectAndRadius(
                Rect.fromLTWH(x - w / 2, y, w, h),
                Radius.circular(w * 0.2),
              ),
              hole,
            );
          }
        }
      case 'mat':
        border(m, m, m, m);
        canvas.drawRect(
          all.deflate(m * 0.55),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = short * 0.0018
            ..color = const Color(0x59000000),
        );
      case 'slide':
        final window = RRect.fromRectAndRadius(
          all.deflate(m),
          Radius.circular(m * 0.45),
        );
        canvas
          ..drawPath(
            Path()
              ..fillType = PathFillType.evenOdd
              ..addRect(all)
              ..addRRect(window),
            fill,
          )
          ..drawRRect(
            window,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = short * 0.003
              ..color = const Color(0x40000000),
          );
      case 'deckle':
        canvas.drawPath(
          Path()
            ..fillType = PathFillType.evenOdd
            ..addRect(all)
            ..addPolygon(_deckledEdge(all.deflate(m), short * 0.014), true),
          fill,
        );
      case 'rebate':
        border(m * 0.35, m, m * 0.35, m);
        final tick = Paint()
          ..strokeWidth = short * 0.0025
          ..color = const Color(0xCCE7C27A);
        final step = short * 0.03;
        var index = 0;
        for (var x = step; x < size.width; x += step) {
          final length = m * (index % 5 == 0 ? 0.42 : 0.22);
          canvas
            ..drawLine(Offset(x, m * 0.2), Offset(x, m * 0.2 + length), tick)
            ..drawLine(
              Offset(x, size.height - m * 0.2),
              Offset(x, size.height - m * 0.2 - length),
              tick,
            );
          index++;
        }
    }
  }

  /// The hand-torn edge of an old print, the same at every resolution: the
  /// walk is seeded and its steps follow [step], a fraction of the photo.
  static List<Offset> _deckledEdge(Rect inner, double step) {
    final random = math.Random(7);
    double wobble() => (random.nextDouble() - 0.5) * step;
    final points = <Offset>[];
    void side(Offset from, Offset to, Offset out) {
      final count = ((to - from).distance / step).ceil();
      for (var i = 0; i < count; i++) {
        points.add(Offset.lerp(from, to, i / count)! + out * wobble());
      }
    }

    side(inner.topLeft, inner.topRight, const Offset(0, 1));
    side(inner.topRight, inner.bottomRight, const Offset(1, 0));
    side(inner.bottomRight, inner.bottomLeft, const Offset(0, 1));
    side(inner.bottomLeft, inner.topLeft, const Offset(1, 0));
    return points;
  }
}
