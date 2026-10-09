import 'package:auvie/app/theme/palette.dart';
import 'package:auvie/app/theme/spacing.dart';
import 'package:auvie/app/theme/typography.dart';
import 'package:flutter/material.dart';

/// Theme follows the task, not a setting: browsing screens are always
/// [paper]; the editor follows the system appearance ([editor]).
abstract final class AuvieTheme {
  static ThemeData paper() => _build(AuviePalette.paper, Brightness.light);

  static ThemeData darkroom() => _build(AuviePalette.darkroom, Brightness.dark);

  /// Editor and export: darkroom, or the light editor when the system
  /// appearance is light.
  static ThemeData editor(Brightness platformBrightness) =>
      platformBrightness == Brightness.light ? paper() : darkroom();

  static ThemeData _build(AuviePalette palette, Brightness brightness) {
    final type = AuvieTypography.from(palette);
    const square = RoundedRectangleBorder();

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: palette.foreground,
        onPrimary: palette.background,
        secondary: palette.accent,
        onSecondary: palette.background,
        error: palette.accent,
        onError: palette.background,
        surface: palette.background,
        onSurface: palette.foreground,
        outline: palette.hairlineStrong,
        outlineVariant: palette.hairline,
      ),
      scaffoldBackgroundColor: palette.background,
      fontFamily: 'Geist',
      textTheme: TextTheme(
        displayLarge: type.coverTitle,
        displayMedium: type.display,
        headlineMedium: type.parameterName,
        titleLarge: type.value,
        titleMedium: type.itemName,
        bodyMedium: type.body,
        labelLarge: type.buttonLabel,
        labelMedium: type.label,
        labelSmall: type.tag,
      ),
      // No ripples or highlight fills: the design has no shadows or boxes.
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      dividerTheme: DividerThemeData(
        color: palette.hairline,
        thickness: AuvieSpacing.hairline,
        space: AuvieSpacing.hairline,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: palette.foreground,
          foregroundColor: palette.background,
          minimumSize: const Size.fromHeight(AuvieSpacing.primaryButtonHeight),
          shape: square,
          elevation: 0,
          textStyle: type.buttonLabel,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: palette.foreground3,
          minimumSize: const Size(
            AuvieSpacing.minHitTarget,
            AuvieSpacing.minHitTarget,
          ),
          shape: square,
          textStyle: type.buttonLabel,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.foreground,
          side: BorderSide(color: palette.foreground),
          shape: square,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          textStyle: type.label,
        ),
      ),
      sliderTheme: SliderThemeData(
        trackHeight: AuvieSpacing.hairline,
        activeTrackColor: palette.foreground,
        inactiveTrackColor: palette.hairlineStrong,
        thumbColor: palette.foreground,
        overlayShape: SliderComponentShape.noOverlay,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
      ),
      extensions: [palette, type],
    );
  }
}

extension AuvieThemeContext on BuildContext {
  AuviePalette get palette => Theme.of(this).extension<AuviePalette>()!;

  AuvieTypography get type => Theme.of(this).extension<AuvieTypography>()!;
}
