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
        _leak(canvas, size, warm: params['tone'] != 'cool');
      case 'burn':
        _burn(canvas, size);
      case 'streak':
        _streak(canvas, size);
      case 'dust':
        _dust(canvas, size, random);
      case 'scratches':
        _scratches(canvas, size, random);
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

  static void _leak(Canvas canvas, Size size, {required bool warm}) {
    final long = size.longestSide;
    final (a, b) = warm
        ? (const Color(0xFFFF5A1F), const Color(0xFFFFB347))
        : (const Color(0xFF3D7BFF), const Color(0xFF9FD8FF));
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
}
