import 'package:auvie/core/models/preset.dart';
import 'package:flutter/material.dart';

/// The 2 pt highlight / mid / shadow strip under a preset.
class ToneStripBar extends StatelessWidget {
  const new({required this.tone, super.key, this.height = 2});

  /// Null draws a neutral strip in [Colors] from the theme (Original).
  final ToneStrip? tone;
  final double height;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.outline;
    final colors = tone == null
        ? [muted, muted, muted]
        : [Color(tone!.highlight), Color(tone!.mid), Color(tone!.shadow)];
    return SizedBox(
      height: height,
      child: Row(
        children: [
          for (final c in colors) Expanded(child: ColoredBox(color: c)),
        ],
      ),
    );
  }
}
