import 'dart:math' as math;
import 'dart:ui';

import 'package:auvie/features/editor/elements/stable_hash.dart';

/// Generated overlays (light leaks, burns, dust, scratches): drawn from a
/// seed in output fractions, so they look the same at any resolution and
/// need no image files.
abstract final class OverlayRenderer {
  static void paint(
    Canvas canvas,
    Size size,
    Map<String, Object?> params, {
    required String seed,
  }) {
    final random = math.Random(stableHash(seed));
    switch (params['generator']) {
      case 'leak':
        _leak(canvas, size, tone: params['tone']);
      case 'burn':
        _burn(canvas, size);
      case 'streak':
        _streak(canvas, size);
      case 'dust':
        _dust(canvas, size, random);
      case 'scratches':
        _scratches(canvas, size, random);
      case 'haze':
        _haze(canvas, size);
      case 'bokeh':
        _bokeh(canvas, size, random);
      case 'prism':
        _prism(canvas, size);
      case 'creases':
        _creases(canvas, size, random);
    }
  }

  static void _glow(
    Canvas canvas,
    Offset center,
    double radius,
    List<Color> colors,
  ) {
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawRect(
      rect,
      Paint()..shader = Gradient.radial(center, radius, colors, [0, 0.45, 1]),
    );
  }

  static void _leak(Canvas canvas, Size size, {required Object? tone}) {
    final long = size.longestSide;
    final (a, b) = switch (tone) {
      'cool' => (const Color(0xFF3D7BFF), const Color(0xFF9FD8FF)),
      'rose' => (const Color(0xFFE8366E), const Color(0xFFFF9EB5)),
      _ => (const Color(0xFFFF5A1F), const Color(0xFFFFB347)),
    };
    _glow(canvas, Offset(-0.05 * size.width, 0.32 * size.height), 0.75 * long, [
      a.withValues(alpha: 0.85),
      b.withValues(alpha: 0.45),
      b.withValues(alpha: 0),
    ]);
    _glow(canvas, Offset(1.05 * size.width, 0.92 * size.height), 0.45 * long, [
      b.withValues(alpha: 0.6),
      a.withValues(alpha: 0.25),
      a.withValues(alpha: 0),
    ]);
  }

  static void _burn(Canvas canvas, Size size) {
    final band = Rect.fromLTWH(
      size.width * 0.55,
      0,
      size.width * 0.45,
      size.height,
    );
    canvas.drawRect(
      band,
      Paint()
        ..shader = Gradient.linear(
          band.centerRight,
          band.centerLeft,
          const [
            Color(0xFFFFF4D6),
            Color(0xE6FF7A1A),
            Color(0x80B0200A),
            Color(0x00B0200A),
          ],
          const [0, 0.25, 0.6, 1],
        ),
    );
    _glow(
      canvas,
      Offset(size.width, size.height * 0.4),
      size.shortestSide * 0.5,
      const [Color(0xFFFFFBEA), Color(0x99FFB000), Color(0x00FF6000)],
    );
  }

  static void _streak(Canvas canvas, Size size) {
    canvas
      ..save()
      ..translate(size.width * 0.35, 0)
      ..rotate(-0.35);
    final beam = Rect.fromLTWH(
      0,
      -size.longestSide,
      size.shortestSide * 0.35,
      size.longestSide * 3,
    );
    canvas
      ..drawRect(
        beam,
        Paint()
          ..shader = Gradient.linear(
            beam.centerLeft,
            beam.centerRight,
            const [Color(0x00FFE7C2), Color(0x99FFE7C2), Color(0x00FFE7C2)],
            const [0, 0.5, 1],
          ),
      )
      ..restore();
  }

  static void _dust(Canvas canvas, Size size, math.Random random) {
    final short = size.shortestSide;
    for (var i = 0; i < 260; i++) {
      final light = random.nextDouble() < 0.7;
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        short * (0.0006 + random.nextDouble() * 0.0024),
        Paint()
          ..color = (light ? const Color(0xFFFFFFFF) : const Color(0xFF15120F))
              .withValues(alpha: 0.35 + random.nextDouble() * 0.5),
      );
    }
    final hair = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = short * 0.0012
      ..color = const Color(0xCCFFFFFF);
    for (var i = 0; i < 6; i++) {
      final start = Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height,
      );
      final c =
          start +
          Offset(random.nextDouble() - 0.5, random.nextDouble() - 0.5) *
              short *
              0.08;
      final end =
          start +
          Offset(random.nextDouble() - 0.5, random.nextDouble() - 0.5) *
              short *
              0.1;
      canvas.drawPath(
        Path()
          ..moveTo(start.dx, start.dy)
          ..quadraticBezierTo(c.dx, c.dy, end.dx, end.dy),
        hair,
      );
    }
  }

  static void _scratches(Canvas canvas, Size size, math.Random random) {
    final short = size.shortestSide;
    for (var i = 0; i < 14; i++) {
      final x = random.nextDouble() * size.width;
      final drift = (random.nextDouble() - 0.5) * short * 0.03;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = short * (0.0006 + random.nextDouble() * 0.001)
        ..color = Color.fromRGBO(
          255,
          255,
          255,
          0.15 + random.nextDouble() * 0.3,
        );
      var y = 0.0;
      while (y < size.height) {
        final length = size.height * (0.1 + random.nextDouble() * 0.5);
        if (random.nextDouble() < 0.75) {
          canvas.drawLine(
            Offset(x + drift * y / size.height, y),
            Offset(x + drift * (y + length) / size.height, y + length),
            paint,
          );
        }
        y += length + size.height * random.nextDouble() * 0.1;
      }
    }
  }

  /// A warm veil falling from the top, as from a lens in the sun.
  static void _haze(Canvas canvas, Size size) {
    final all = Offset.zero & size;
    canvas.drawRect(
      all,
      Paint()
        ..shader = Gradient.linear(
          all.topCenter,
          all.bottomCenter,
          const [Color(0xB3FFE9CC), Color(0x40FFD9B0), Color(0x00FFD9B0)],
          const [0, 0.4, 0.8],
        ),
    );
    _glow(canvas, Offset(size.width * 0.3, 0), size.longestSide * 0.6, const [
      Color(0x99FFF3DF),
      Color(0x40FFD9B0),
      Color(0x00FFD9B0),
    ]);
  }

  /// Out-of-focus lights, larger and fainter toward the edges of the range.
  static void _bokeh(Canvas canvas, Size size, math.Random random) {
    final short = size.shortestSide;
    const tints = [Color(0xFFFFC27A), Color(0xFFFFE3B0), Color(0xFFFF8F6B)];
    for (var i = 0; i < 18; i++) {
      final radius = short * (0.03 + random.nextDouble() * 0.08);
      final center = Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height,
      );
      final tint = tints[random.nextInt(tints.length)];
      final alpha = 0.12 + random.nextDouble() * 0.28;
      canvas
        ..drawCircle(
          center,
          radius,
          Paint()..color = tint.withValues(alpha: alpha),
        )
        ..drawCircle(
          center,
          radius,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = short * 0.002
            ..color = tint.withValues(alpha: alpha * 1.4),
        );
    }
  }

  /// A band of split light, as when a prism is held to the lens.
  static void _prism(Canvas canvas, Size size) {
    canvas
      ..save()
      ..translate(size.width * 0.62, 0)
      ..rotate(0.28);
    final beam = Rect.fromLTWH(
      0,
      -size.longestSide,
      size.shortestSide * 0.42,
      size.longestSide * 3,
    );
    canvas
      ..drawRect(
        beam,
        Paint()
          ..shader = Gradient.linear(
            beam.centerLeft,
            beam.centerRight,
            const [
              Color(0x00FF3B5C),
              Color(0x99FF3B5C),
              Color(0x99FFC23D),
              Color(0x9947E08A),
              Color(0x993D8BFF),
              Color(0x009B5CFF),
            ],
            const [0, 0.2, 0.4, 0.6, 0.8, 1],
          ),
      )
      ..restore();
  }

  /// Folds of a print kept in a wallet: one each way, with a shadow side.
  static void _creases(Canvas canvas, Size size, math.Random random) {
    final short = size.shortestSide;
    final light = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = short * 0.0032
      ..color = const Color(0xE6FFFFFF);
    final dark = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = short * 0.0045
      ..color = const Color(0x80000000);

    void fold(Offset from, Offset to) {
      final path = Path()..moveTo(from.dx, from.dy);
      final normal = Offset(from.dy - to.dy, to.dx - from.dx);
      final unit = normal / normal.distance;
      for (var i = 1; i <= 24; i++) {
        final point = Offset.lerp(from, to, i / 24)!;
        final jitter = (random.nextDouble() - 0.5) * short * 0.005;
        final p = point + unit * jitter;
        path.lineTo(p.dx, p.dy);
      }
      canvas
        ..drawPath(path.shift(unit * short * 0.002), dark)
        ..drawPath(path, light);
    }

    final x = size.width * (0.35 + random.nextDouble() * 0.3);
    final y = size.height * (0.35 + random.nextDouble() * 0.3);
    fold(Offset(x, 0), Offset(x + short * 0.02, size.height));
    fold(Offset(0, y), Offset(size.width, y - short * 0.02));
  }
}
