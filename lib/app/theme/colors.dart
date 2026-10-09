import 'dart:ui';

/// Raw color tokens from the design handoff
/// (`docs/design_handoff_epreuve/README.md`, "Design tokens → Color").
///
/// Widgets should not use these directly: read the semantic roles from
/// `AuviePalette` so the same widget works on paper and in the darkroom.
abstract final class AuvieColors {
  static const paper = Color(0xFFF3EEE5);
  static const ink = Color(0xFF1A1714);
  static const ink2 = Color(0xFF3D3832);
  static const ink3 = Color(0xFF4D463E);
  static const mutedLight = Color(0xFF6F665C);

  static const darkroom = Color(0xFF161412);
  static const bone = Color(0xFFEFE8DC);
  static const bone2 = Color(0xFFC9C0B3);
  static const mutedDark = Color(0xFF8C8378);
  static const mutedDark2 = Color(0xFFA39A8E);

  /// Accent on dark. Marks only "the live thing" (active value, playhead…).
  static const safelight = Color(0xFFE0573C);

  /// Accent on paper.
  static const safelightDeep = Color(0xFFB23A26);

  static const black = Color(0xFF0B0A09);
}
