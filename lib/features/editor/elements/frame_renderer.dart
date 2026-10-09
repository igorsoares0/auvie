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
    }
  }
}
