import 'package:auvie/app/theme/palette.dart';
import 'package:flutter/material.dart';

/// Type roles from the design handoff ("Design tokens → Typography").
///
/// The bundled fonts are variable, so weight and optical size are applied
/// through [FontVariation]; `fontWeight` is set too so text metrics and
/// accessibility (bold text) stay consistent. There are no bold weights.
///
/// Caps labels must be uppercased by the caller (`'export'.toUpperCase()`):
/// a [TextStyle] cannot transform case.
@immutable
class AuvieTypography extends ThemeExtension<AuvieTypography> {
  const new({
    required this.wordmark,
    required this.display,
    required this.coverTitle,
    required this.parameterName,
    required this.value,
    required this.itemName,
    required this.label,
    required this.buttonLabel,
    required this.tag,
    required this.body,
  });

  factory from(AuviePalette palette) {
    return AuvieTypography(
      wordmark: serif(14, letterSpacingEm: 0.31, color: palette.foreground),
      display: serif(
        38,
        height: 1.08,
        letterSpacingEm: -0.015,
        color: palette.foreground,
      ),
      coverTitle: serif(64, height: 0.95, color: palette.foreground),
      parameterName: serif(
        30,
        height: 1,
        italic: true,
        color: palette.foreground,
      ),
      value: serif(24, color: palette.foreground),
      itemName: serif(16, color: palette.foreground),
      label: sans(11, color: palette.muted),
      buttonLabel: sans(11, letterSpacingEm: 0.18, color: palette.foreground),
      tag: sans(9, color: palette.muted),
      body: TextStyle(
        fontFamily: 'Geist',
        fontSize: 13.5,
        height: 1.55,
        fontWeight: FontWeight.w400,
        fontVariations: const [FontVariation.weight(400)],
        color: palette.foreground3,
      ),
    );
  }

  /// Newsreader 400, with the optical size axis following the font size.
  static TextStyle serif(
    double size, {
    required Color color,
    double? height,
    double letterSpacingEm = 0,
    bool italic = false,
  }) {
    return TextStyle(
      fontFamily: 'Newsreader',
      fontSize: size,
      height: height,
      letterSpacing: size * letterSpacingEm,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      fontWeight: FontWeight.w400,
      fontVariations: [
        const FontVariation.weight(400),
        FontVariation.opticalSize(size.clamp(6, 72)),
      ],
      color: color,
    );
  }

  /// Jost 500, tracked: every functional label.
  static TextStyle sans(
    double size, {
    required Color color,
    double letterSpacingEm = 0.14,
  }) {
    return TextStyle(
      fontFamily: 'Jost',
      fontSize: size,
      letterSpacing: size * letterSpacingEm,
      fontWeight: FontWeight.w500,
      fontVariations: const [FontVariation.weight(500)],
      color: color,
    );
  }

  /// "AUVIE", uppercase, Newsreader 13–15 pt tracked 0.30–0.32 em.
  final TextStyle wordmark;

  /// Headlines, 34–44 pt. The key word is set in italic by the caller.
  final TextStyle display;

  /// Onboarding cover title, 64 pt.
  final TextStyle coverTitle;

  /// Adjust parameter name, e.g. *Exposure*.
  final TextStyle parameterName;

  /// Parameter value; use the accent color when it is live.
  final TextStyle value;

  /// Presets, recents, list rows.
  final TextStyle itemName;

  /// Caps label for all functional UI.
  final TextStyle label;

  /// Caps label inside primary/ghost buttons.
  final TextStyle buttonLabel;

  /// Small caps tag (ATELIER, durations).
  final TextStyle tag;

  /// Explanations only.
  final TextStyle body;

  @override
  AuvieTypography copyWith({
    TextStyle? wordmark,
    TextStyle? display,
    TextStyle? coverTitle,
    TextStyle? parameterName,
    TextStyle? value,
    TextStyle? itemName,
    TextStyle? label,
    TextStyle? buttonLabel,
    TextStyle? tag,
    TextStyle? body,
  }) {
    return AuvieTypography(
      wordmark: wordmark ?? this.wordmark,
      display: display ?? this.display,
      coverTitle: coverTitle ?? this.coverTitle,
      parameterName: parameterName ?? this.parameterName,
      value: value ?? this.value,
      itemName: itemName ?? this.itemName,
      label: label ?? this.label,
      buttonLabel: buttonLabel ?? this.buttonLabel,
      tag: tag ?? this.tag,
      body: body ?? this.body,
    );
  }

  @override
  AuvieTypography lerp(AuvieTypography? other, double t) {
    if (other == null) return this;
    return AuvieTypography(
      wordmark: TextStyle.lerp(wordmark, other.wordmark, t)!,
      display: TextStyle.lerp(display, other.display, t)!,
      coverTitle: TextStyle.lerp(coverTitle, other.coverTitle, t)!,
      parameterName: TextStyle.lerp(parameterName, other.parameterName, t)!,
      value: TextStyle.lerp(value, other.value, t)!,
      itemName: TextStyle.lerp(itemName, other.itemName, t)!,
      label: TextStyle.lerp(label, other.label, t)!,
      buttonLabel: TextStyle.lerp(buttonLabel, other.buttonLabel, t)!,
      tag: TextStyle.lerp(tag, other.tag, t)!,
      body: TextStyle.lerp(body, other.body, t)!,
    );
  }
}
