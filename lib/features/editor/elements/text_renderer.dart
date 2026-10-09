import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:auvie/core/models/elements.dart';
import 'package:flutter/material.dart';

/// Lays out and draws text elements. Sizes are fractions of the output's
/// shorter side, so the same element looks the same at any resolution.
abstract final class TextRenderer {
  /// Text wraps at this fraction of the output width.
  static const wrapWidth = 0.9;

  static FontWeight _weight(int w) =>
      FontWeight.values[((w / 100).round() - 1).clamp(0, 8)];

  /// Text style in output pixels for an output of [size].
  static TextStyle textStyle(TextStyleSpec s, Size size, {Paint? foreground}) {
    final fontPx = s.fontSize * size.shortestSide;
    final shadow = s.shadow;
    return TextStyle(
      fontFamily: s.fontFamily,
      fontSize: fontPx,
      fontWeight: _weight(s.fontWeight),
      fontStyle: s.italic ? FontStyle.italic : FontStyle.normal,
      fontVariations: [
        ui.FontVariation.weight(s.fontWeight.toDouble()),
        if (s.fontFamily == 'Newsreader')
          ui.FontVariation.opticalSize(fontPx.clamp(6, 72)),
      ],
      letterSpacing: s.letterSpacing * fontPx,
      height: s.lineHeight,
      color: foreground == null ? Color(s.color) : null,
      foreground: foreground,
      shadows: shadow == null || foreground != null
          ? null
          : [
              Shadow(
                color: Color(shadow.color),
                blurRadius: shadow.blur * size.shortestSide,
                offset: Offset(shadow.dx, shadow.dy) * size.shortestSide,
              ),
            ],
    );
  }

  static TextAlign _align(TextAlignment a) => switch (a) {
    TextAlignment.left => TextAlign.left,
    TextAlignment.center => TextAlign.center,
    TextAlignment.right => TextAlign.right,
  };

  static TextPainter _layout(
    String text,
    TextStyleSpec s,
    Size size, {
    Paint? foreground,
  }) => TextPainter(
    text: TextSpan(
      text: s.uppercase ? text.toUpperCase() : text,
      style: textStyle(s, size, foreground: foreground),
    ),
    textAlign: _align(s.align),
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: size.width * wrapWidth);

  static double _padding(TextStyleSpec s, Size size) =>
      (s.background?.padding ?? 0) * size.shortestSide;

  /// Size of the element's box (text plus background padding) at scale 1.
  static Size boxSize(String text, TextStyleSpec s, Size size) {
    final painter = _layout(text.isEmpty ? ' ' : text, s, size);
    final pad = _padding(s, size);
    final result = Size(painter.width + pad * 2, painter.height + pad * 2);
    painter.dispose();
    return result;
  }

  /// Draws [text] centred on the canvas origin (after the element's frame
  /// has been applied).
  static void paint(Canvas canvas, String text, TextStyleSpec s, Size size) {
    final content = text.isEmpty ? ' ' : text;
    final fill = _layout(content, s, size);
    final pad = _padding(s, size);
    final topLeft = Offset(-fill.width / 2, -fill.height / 2);

    final background = s.background;
    if (background != null) {
      canvas.drawRect(
        Rect.fromLTWH(
          topLeft.dx - pad,
          topLeft.dy - pad,
          fill.width + pad * 2,
          fill.height + pad * 2,
        ),
        Paint()..color = Color(background.color),
      );
    }
    final outline = s.outline;
    if (outline != null) {
      _layout(
          content,
          s,
          size,
          foreground: Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = math.max(1, outline.width * size.shortestSide)
            ..strokeJoin = StrokeJoin.round
            ..color = Color(outline.color),
        )
        ..paint(canvas, topLeft)
        ..dispose();
    }
    fill
      ..paint(canvas, topLeft)
      ..dispose();
  }
}
