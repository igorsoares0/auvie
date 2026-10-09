import 'package:auvie/app/theme/app_theme.dart';
import 'package:auvie/app/widgets/system_bars.dart';
import 'package:flutter/material.dart';

/// Applies the editor theme (darkroom, or light when the system appearance
/// is light) to an editor or export route.
class EditorTheme extends StatelessWidget {
  const new({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AuvieTheme.editor(MediaQuery.platformBrightnessOf(context)),
      child: SystemBars(child: child),
    );
  }
}
