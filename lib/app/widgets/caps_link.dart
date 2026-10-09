import 'package:auvie/app/theme/app_theme.dart';
import 'package:auvie/app/theme/spacing.dart';
import 'package:flutter/material.dart';

/// A tracked uppercase text action with a 44 pt hit area (SKIP, SETTINGS…).
class CapsLink extends StatelessWidget {
  const new(
    this.label, {
    required this.onTap,
    super.key,
    this.color,
    this.trailing,
  });

  final String label;
  final VoidCallback? onTap;
  final Color? color;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final style = context.type.label.copyWith(
      color: color ?? context.palette.foreground,
    );
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: AuvieSpacing.minHitTarget,
            minWidth: AuvieSpacing.minHitTarget,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label.toUpperCase(), style: style),
              if (trailing != null) ...[
                const SizedBox(width: AuvieSpacing.s8),
                IconTheme(
                  data: IconThemeData(color: style.color),
                  child: trailing!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
