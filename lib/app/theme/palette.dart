import 'package:auvie/app/theme/colors.dart';
import 'package:flutter/material.dart';

/// Semantic color roles. Two instances exist: [paper] for browsing screens
/// (Home, Archive, Onboarding, Pro) and [darkroom] for the dark editor.
@immutable
class AuviePalette extends ThemeExtension<AuviePalette> {
  const new({
    required this.background,
    required this.foreground,
    required this.foreground2,
    required this.foreground3,
    required this.muted,
    required this.mutedStrong,
    required this.accent,
    required this.hairline,
    required this.hairlineStrong,
    required this.veil,
  });

  static const paper = AuviePalette(
    background: AuvieColors.paper,
    foreground: AuvieColors.ink,
    foreground2: AuvieColors.ink2,
    foreground3: AuvieColors.ink3,
    muted: AuvieColors.mutedLight,
    mutedStrong: AuvieColors.ink3,
    accent: AuvieColors.safelightDeep,
    hairline: Color(0x1A1A1714), // ink @ 10%
    hairlineStrong: Color(0x2E1A1714), // ink @ 18%
    veil: Color(0xB8F3EEE5), // paper @ 72%
  );

  static const darkroom = AuviePalette(
    background: AuvieColors.darkroom,
    foreground: AuvieColors.bone,
    foreground2: AuvieColors.bone2,
    foreground3: AuvieColors.bone2,
    muted: AuvieColors.mutedDark,
    mutedStrong: AuvieColors.mutedDark2,
    accent: AuvieColors.safelight,
    hairline: Color(0x1AEFE8DC), // bone @ 10%
    hairlineStrong: Color(0x38EFE8DC), // bone @ 22%
    veil: Color(0xB8161412), // darkroom @ 72%
  );

  /// Screen background.
  final Color background;

  /// Primary text, filled CTAs, icons.
  final Color foreground;

  /// Secondary text.
  final Color foreground2;

  /// Body copy and ghost buttons.
  final Color foreground3;

  /// Labels and metadata (≥ 4.5:1 on [background]).
  final Color muted;

  /// Close / Cancel.
  final Color mutedStrong;

  /// Safelight: only for the live value, playhead, active tool dot, Pro badge
  /// and error causes. Never for fills or decoration.
  final Color accent;

  /// 1 px rules.
  final Color hairline;
  final Color hairlineStrong;

  /// Veil over trimmed footage and dimmed content.
  final Color veil;

  @override
  AuviePalette copyWith({
    Color? background,
    Color? foreground,
    Color? foreground2,
    Color? foreground3,
    Color? muted,
    Color? mutedStrong,
    Color? accent,
    Color? hairline,
    Color? hairlineStrong,
    Color? veil,
  }) {
    return AuviePalette(
      background: background ?? this.background,
      foreground: foreground ?? this.foreground,
      foreground2: foreground2 ?? this.foreground2,
      foreground3: foreground3 ?? this.foreground3,
      muted: muted ?? this.muted,
      mutedStrong: mutedStrong ?? this.mutedStrong,
      accent: accent ?? this.accent,
      hairline: hairline ?? this.hairline,
      hairlineStrong: hairlineStrong ?? this.hairlineStrong,
      veil: veil ?? this.veil,
    );
  }

  @override
  AuviePalette lerp(AuviePalette? other, double t) {
    if (other == null) return this;
    return AuviePalette(
      background: Color.lerp(background, other.background, t)!,
      foreground: Color.lerp(foreground, other.foreground, t)!,
      foreground2: Color.lerp(foreground2, other.foreground2, t)!,
      foreground3: Color.lerp(foreground3, other.foreground3, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      mutedStrong: Color.lerp(mutedStrong, other.mutedStrong, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      hairline: Color.lerp(hairline, other.hairline, t)!,
      hairlineStrong: Color.lerp(hairlineStrong, other.hairlineStrong, t)!,
      veil: Color.lerp(veil, other.veil, t)!,
    );
  }
}
