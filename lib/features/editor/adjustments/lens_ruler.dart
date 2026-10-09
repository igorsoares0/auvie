import 'dart:async';

import 'package:auvie/app/theme/app_theme.dart';
import 'package:auvie/core/models/adjustment.dart';
import 'package:auvie/features/editor/adjustments/ruler_scale.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Lens-style ruler (handoff "Adjust"): drag to change the value, with a light
/// haptic at 0 and every major tick; double-tap resets.
class LensRuler extends StatefulWidget {
  const new({
    required this.adjustment,
    required this.value,
    required this.onPreview,
    required this.onCommit,
    required this.onReset,
    super.key,
  });

  final Adjustment adjustment;
  final double value;
  final ValueChanged<double> onPreview;
  final VoidCallback onCommit;
  final VoidCallback onReset;

  @override
  State<LensRuler> createState() => _LensRulerState();
}

class _LensRulerState extends State<LensRuler> {
  late double _value = widget.value;

  @override
  void didUpdateWidget(LensRuler old) {
    super.didUpdateWidget(old);
    _value = widget.value;
  }

  void _drag(DragUpdateDetails details, double width) {
    final scale = RulerScale(widget.adjustment);
    final next = scale.drag(_value, details.delta.dx, width);
    if (scale.crossedMajor(_value, next) != null) {
      unawaited(HapticFeedback.selectionClick());
    }
    _value = next;
    widget.onPreview(next);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final scale = RulerScale(widget.adjustment);
    final labels = widget.adjustment.min < 0
        ? const ['−1.0', '0', '+1.0']
        : const ['0', '0.5', '1.0'];
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return Semantics(
          slider: true,
          value: widget.value.toStringAsFixed(2),
          child: GestureDetector(
            key: const Key('lens-ruler'),
            behavior: HitTestBehavior.opaque,
            onHorizontalDragUpdate: (d) => _drag(d, width),
            onHorizontalDragEnd: (_) => widget.onCommit(),
            onDoubleTap: widget.onReset,
            child: SizedBox(
              height: 44,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _RulerPainter(
                        scale: scale,
                        value: widget.value,
                        tick: palette.foreground,
                        accent: palette.accent,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (final label in labels)
                          Text(
                            label,
                            style: context.type.tag.copyWith(
                              fontSize: 10,
                              letterSpacing: 1,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RulerPainter extends CustomPainter {
  new({
    required this.scale,
    required this.value,
    required this.tick,
    required this.accent,
  });

  final RulerScale scale;
  final double value;
  final Color tick;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width - 1;
    final minor = Paint()
      ..color = tick.withValues(alpha: 0.28)
      ..strokeWidth = 1;
    final major = Paint()
      ..color = tick.withValues(alpha: 0.6)
      ..strokeWidth = 1;
    for (var i = 0; i <= RulerScale.minorTicks; i++) {
      final x = (w * i / RulerScale.minorTicks).roundToDouble() + 0.5;
      canvas.drawLine(Offset(x, 12), Offset(x, 20), minor);
    }
    for (final m in scale.majors) {
      final x = (w * scale.fraction(m)).roundToDouble() + 0.5;
      canvas.drawLine(Offset(x, 6), Offset(x, 20), major);
    }

    final live = Paint()
      ..color = accent
      ..strokeWidth = 1;
    final zero = w * scale.fraction(0) + 0.5;
    final at = w * scale.fraction(value) + 0.5;
    canvas
      ..drawLine(Offset(zero, 24.5), Offset(at, 24.5), live)
      ..drawLine(Offset(at, 0), Offset(at, 26), live);
  }

  @override
  bool shouldRepaint(_RulerPainter old) =>
      old.value != value ||
      old.scale.adjustment != scale.adjustment ||
      old.tick != tick ||
      old.accent != accent;
}
