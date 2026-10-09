import 'dart:math' as math;

import 'package:auvie/core/models/preset.dart';
import 'package:flutter/material.dart';

/// Placeholder imagery built from a preset's tone strip: a soft gradient
/// "landscape" with grain. Stands in for the handoff's Unsplash photos until
/// licensed images are added (see docs/PLANO-IMPLEMENTACAO-ANDROID.md).
class FilmArt extends StatelessWidget {
  const new({required this.tone, super.key, this.seed = 1});

  final ToneStrip tone;

  /// Varies the composition between instances.
  final int seed;

  /// Warm, Ektar-like tones.
  static const ektar = ToneStrip(
    highlight: 0xFFE9C9A0,
    mid: 0xFFB4674A,
    shadow: 0xFF3B2A22,
  );

  /// Blue night tones.
  static const nocturne = ToneStrip(
    highlight: 0xFFB9A98A,
    mid: 0xFF3D4F66,
    shadow: 0xFF121A26,
  );

  /// Grey, Cendre-like tones.
  static const cendre = ToneStrip(
    highlight: 0xFFD6D2CA,
    mid: 0xFF8C8A86,
    shadow: 0xFF2C2D2F,
  );

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(
        painter: _FilmArtPainter(tone, seed),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _FilmArtPainter extends CustomPainter {
  new(this.tone, this.seed);

  final ToneStrip tone;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final high = Color(tone.highlight);
    final mid = Color(tone.mid);
    final shadow = Color(tone.shadow);

    // Sky to ground.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [high, Color.lerp(high, mid, 0.6)!, shadow],
          stops: const [0, 0.45, 1],
        ).createShader(rect),
    );

    // Two hills.
    final random = math.Random(seed);
    for (final (depth, color) in [
      (0.55 + random.nextDouble() * 0.1, Color.lerp(mid, shadow, 0.35)!),
      (0.72 + random.nextDouble() * 0.08, shadow),
    ]) {
      final y = size.height * depth;
      final path = Path()
        ..moveTo(0, y)
        ..cubicTo(
          size.width * 0.3,
          y - size.height * (0.08 + random.nextDouble() * 0.08),
          size.width * 0.6,
          y + size.height * 0.06,
          size.width,
          y - size.height * 0.05,
        )
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
      canvas.drawPath(path, Paint()..color = color.withValues(alpha: 0.9));
    }

    // Light glow.
    final glow = Offset(
      size.width * (0.3 + random.nextDouble() * 0.4),
      size.height * 0.3,
    );
    final radius = size.shortestSide * 0.35;
    canvas.drawCircle(
      glow,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [high.withValues(alpha: 0.7), high.withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: glow, radius: radius)),
    );

    // Grain.
    final grain = Paint()..strokeWidth = 1;
    final dots = (size.width * size.height / 60).clamp(0, 6000).toInt();
    for (var i = 0; i < dots; i++) {
      grain.color = (random.nextBool() ? Colors.white : Colors.black)
          .withValues(alpha: 0.05 + random.nextDouble() * 0.05);
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        0.6,
        grain,
      );
    }
  }

  @override
  bool shouldRepaint(_FilmArtPainter old) =>
      old.tone != tone || old.seed != seed;
}
