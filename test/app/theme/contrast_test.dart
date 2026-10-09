import 'dart:math' as math;

import 'package:auvie/app/theme/palette.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

/// WCAG 2.x contrast ratio.
double contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  for (final (name, palette) in [
    ('paper', AuviePalette.paper),
    ('darkroom', AuviePalette.darkroom),
  ]) {
    group('$name text roles reach 4.5:1 on the background', () {
      final roles = {
        'foreground': palette.foreground,
        'foreground2': palette.foreground2,
        'foreground3': palette.foreground3,
        'muted': palette.muted,
        'mutedStrong': palette.mutedStrong,
        'accent': palette.accent,
      };
      for (final MapEntry(key: role, value: color) in roles.entries) {
        test(role, () {
          expect(
            contrast(color, palette.background),
            greaterThanOrEqualTo(4.5),
          );
        });
      }
    });
  }

  test('filled CTA label is readable on the filled button', () {
    for (final p in [AuviePalette.paper, AuviePalette.darkroom]) {
      expect(contrast(p.background, p.foreground), greaterThanOrEqualTo(4.5));
    }
  });
}
