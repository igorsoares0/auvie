import 'package:auvie/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Icons from the design handoff (`assets/icons/*.svg`): 1 px stroke,
/// `currentColor`, never filled.
enum AuvieIcons {
  add,
  adjust,
  arrow,
  brush,
  color,
  crop,
  curve,
  dup,
  film,
  grain,
  light,
  photo,
  play,
  redo,
  search,
  sound,
  trash,
  trim,
  type,
  undo,
  video;

  String get asset => 'assets/icons/$name.svg';

  /// Drawing grid: the adjustment family icons (LIGHT, COLOR, CURVE, GRAIN,
  /// CROP) are drawn on 28 and shown at 28 pt; every other icon is on 24.
  double get grid => switch (this) {
    light || color || curve || grain || crop => 28,
    _ => 24,
  };
}

class AuvieIcon extends StatelessWidget {
  const new(this.icon, {super.key, this.size = 22, this.color});

  final AuvieIcons icon;
  final double size;

  /// Defaults to the palette foreground.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      icon.asset,
      width: size,
      height: size,
      theme: SvgTheme(currentColor: color ?? context.palette.foreground),
    );
  }
}
