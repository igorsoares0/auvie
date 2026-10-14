import 'package:auvie/app/theme/colors.dart';
import 'package:auvie/app/theme/typography.dart';
import 'package:flutter/material.dart';

/// What a part of a screen shows if it fails to build (release builds),
/// instead of Flutter's red error screen. Works without a theme: it may be
/// the theme that failed.
class ErrorBlock extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AuvieColors.paper,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Something went wrong here. Your edits are safe.',
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
            style: AuvieTypography.serif(
              15,
              italic: true,
              color: AuvieColors.mutedLight,
            ),
          ),
        ),
      ),
    );
  }
}
