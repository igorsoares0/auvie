import 'package:auvie/core/models/elements.dart';

/// Ready-made text styles (spec §20), shown as specimens in TYPE. The first
/// four are the handoff's Didone, Grotesk, Typewriter and Hand.
enum TextPreset {
  /// Editorial.
  didone('Didone', TextStyleSpec(italic: true, lineHeight: 1.1)),

  /// Minimal: tracked capitals.
  grotesk(
    'Grotesk',
    TextStyleSpec(
      fontFamily: 'Jost',
      fontSize: 0.04,
      fontWeight: 500,
      letterSpacing: 0.3,
      uppercase: true,
    ),
  ),

  /// Film.
  typewriter(
    'Typewriter',
    TextStyleSpec(fontFamily: 'IBMPlexMono', fontSize: 0.045, lineHeight: 1.3),
  ),

  /// Handwritten.
  hand(
    'Hand',
    TextStyleSpec(
      fontFamily: 'Caveat',
      fontSize: 0.08,
      fontWeight: 500,
      lineHeight: 1,
    ),
  ),
  classic('Classic', TextStyleSpec(lineHeight: 1.15)),
  bold(
    'Bold',
    TextStyleSpec(
      fontFamily: 'Jost',
      fontSize: 0.07,
      fontWeight: 700,
      lineHeight: 1,
    ),
  ),
  film(
    'Film',
    TextStyleSpec(
      fontFamily: 'Geist',
      fontSize: 0.035,
      letterSpacing: 0.12,
      uppercase: true,
    ),
  ),

  /// A magazine headline.
  editorial(
    'Editorial',
    TextStyleSpec(
      fontFamily: 'PlayfairDisplay',
      fontSize: 0.07,
      fontWeight: 700,
      lineHeight: 1.05,
    ),
  ),
  fatface(
    'Fatface',
    TextStyleSpec(
      fontFamily: 'AbrilFatface',
      fontSize: 0.075,
      lineHeight: 1.05,
    ),
  ),

  /// Condensed capitals, as on a cinema bill.
  poster(
    'Poster',
    TextStyleSpec(
      fontFamily: 'BebasNeue',
      fontSize: 0.1,
      letterSpacing: 0.04,
      lineHeight: 1,
      uppercase: true,
    ),
  ),

  /// A typewriter with a worn ribbon.
  worn(
    'Worn',
    TextStyleSpec(fontFamily: 'SpecialElite', fontSize: 0.05, lineHeight: 1.25),
  ),

  /// Seventies display.
  retro(
    'Retro',
    TextStyleSpec(fontFamily: 'Shrikhand', fontSize: 0.07, lineHeight: 1.1),
  ),

  /// Sign painter's script.
  script(
    'Script',
    TextStyleSpec(fontFamily: 'Yellowtail', fontSize: 0.085, lineHeight: 1.1),
  ),

  /// Blackletter.
  gothic(
    'Gothic',
    TextStyleSpec(fontFamily: 'PirataOne', fontSize: 0.085, lineHeight: 1.1),
  ),
  marker('Marker', TextStyleSpec(fontFamily: 'PermanentMarker')),

  /// The orange date a film camera burns into the corner.
  dateStamp(
    'Date stamp',
    TextStyleSpec(
      fontFamily: 'VT323',
      fontSize: 0.065,
      letterSpacing: 0.06,
      lineHeight: 1,
      uppercase: true,
    ),
  );

  new(this.label, this.style);

  final String label;

  /// Font, size, spacing and case; colour and STYLE options are kept from
  /// the element when switching presets.
  final TextStyleSpec style;

  /// [current] restyled with this preset, keeping its colour and STYLE row.
  TextStyleSpec apply(TextStyleSpec current) => style.copyWith(
    color: current.color,
    align: current.align,
    shadow: current.shadow,
    outline: current.outline,
    background: current.background,
  );

  static TextPreset? byId(String? id) =>
      values.where((p) => p.name == id).firstOrNull;
}

/// INK swatches (handoff 04).
const inkColors = [0xFFF6F0E6, 0xFF0B0A09, 0xFFE0573C, 0xFF8E3B2E, 0xFF5F6B57];
