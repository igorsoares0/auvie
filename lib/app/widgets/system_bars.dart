import 'package:auvie/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Matches the Android status and navigation bars to the current palette.
class SystemBars extends StatelessWidget {
  const new({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final background = context.palette.background;
    final icons = dark ? Brightness.light : Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: background,
        statusBarIconBrightness: icons,
        systemNavigationBarColor: background,
        systemNavigationBarIconBrightness: icons,
        systemNavigationBarDividerColor: background,
      ),
      child: child,
    );
  }
}
