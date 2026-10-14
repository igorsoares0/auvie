@Tags(['brand'])
library;

import 'dart:io';
import 'dart:ui' as ui;

import 'package:auvie/app/theme/colors.dart';
import 'package:auvie/app/theme/typography.dart';
import 'package:auvie/app/widgets/film_art.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// Renders the launcher icon, the Play Store icon and the feature graphic
/// with the app's real fonts. Not part of the normal run (dart_test.yaml):
/// `flutter test --run-skipped --tags brand test/tool/brand_render_test.dart`.
void main() {
  const res = 'android/app/src/main/res';

  /// Density buckets and their scale from dp.
  const densities = {
    'mdpi': 1.0,
    'hdpi': 1.5,
    'xhdpi': 2.0,
    'xxhdpi': 3.0,
    'xxxhdpi': 4.0,
  };

  Future<void> render(
    WidgetTester tester,
    Widget art,
    Size size,
    double pixelRatio,
    List<String> paths,
  ) async {
    final key = GlobalKey();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: RepaintBoundary(
            key: key,
            child: SizedBox.fromSize(size: size, child: art),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      for (final path in paths) {
        File(path)
          ..parent.createSync(recursive: true)
          ..writeAsBytesSync(png!.buffer.asUint8List());
      }
    });
  }

  setUp(() {
    TestWidgetsFlutterBinding.instance.platformDispatcher.views.first
      ..physicalSize = const Size(2048, 2048)
      ..devicePixelRatio = 1;
  });

  testWidgets('adaptive launcher icon', (tester) async {
    // 108 dp layers; the mark stays inside the 66 dp safe zone.
    for (final MapEntry(key: bucket, value: scale) in densities.entries) {
      await render(
        tester,
        const _Mark(ink: AuvieColors.ink, dot: AuvieColors.safelightDeep),
        const Size.square(108),
        scale,
        ['$res/mipmap-$bucket/ic_launcher_foreground.png'],
      );
      await render(
        tester,
        const _Mark(ink: Colors.white, dot: Colors.white),
        const Size.square(108),
        scale,
        ['$res/mipmap-$bucket/ic_launcher_monochrome.png'],
      );
      // Legacy square icon (48 dp), for launchers without adaptive icons.
      await render(tester, const _LegacyIcon(), const Size.square(48), scale, [
        '$res/mipmap-$bucket/ic_launcher.png',
      ]);
    }
  });

  testWidgets('Play Store icon and feature graphic', (tester) async {
    await render(tester, const _StoreIcon(), const Size.square(512), 1, [
      'docs/store/icon-512.png',
    ]);
    await render(tester, const _FeatureGraphic(), const Size(1024, 500), 1, [
      'docs/store/feature-graphic.png',
    ]);
  });
}

/// "A." in Newsreader: the wordmark's first letter and the safelight dot.
class _Mark extends StatelessWidget {
  const new({required this.ink, required this.dot, this.size = 108});

  final Color ink;
  final Color dot;

  /// Side of the square, in the same units as the 108 dp icon canvas.
  final double size;

  @override
  Widget build(BuildContext context) {
    final unit = size / 108;
    // Measured on Newsreader at 60: cap height 43, glyph 44.5 wide. The
    // letter and its full stop are centred together on the 108 canvas.
    return Stack(
      children: [
        Positioned(
          left: -8 * unit,
          right: 0,
          top: 32.5 * unit,
          child: Text(
            'A',
            textAlign: TextAlign.center,
            style: AuvieTypography.serif(60 * unit, height: 1, color: ink),
          ),
        ),
        Positioned(
          left: 74 * unit,
          top: 69.5 * unit,
          child: Container(
            width: 6 * unit,
            height: 6 * unit,
            decoration: BoxDecoration(shape: BoxShape.circle, color: dot),
          ),
        ),
      ],
    );
  }
}

class _LegacyIcon extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: const ColoredBox(
        color: AuvieColors.paper,
        child: OverflowBox(
          maxWidth: 72,
          maxHeight: 72,
          child: _Mark(
            ink: AuvieColors.ink,
            dot: AuvieColors.safelightDeep,
            size: 72,
          ),
        ),
      ),
    );
  }
}

/// Full-bleed 512 px icon; Google Play rounds the corners itself.
class _StoreIcon extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AuvieColors.paper,
      child: OverflowBox(
        maxWidth: 760,
        maxHeight: 760,
        child: _Mark(
          ink: AuvieColors.ink,
          dot: AuvieColors.safelightDeep,
          size: 760,
        ),
      ),
    );
  }
}

/// 1024 × 500 Play Store banner: the night film art, the name and the line
/// from the onboarding cover.
class _FeatureGraphic extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const FilmArt(tone: FilmArt.nocturne, seed: 7),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x00161412), Color(0xE6161412)],
            ),
          ),
        ),
        Positioned(
          left: 64,
          right: 64,
          bottom: 56,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Auvie',
                style: AuvieTypography.serif(
                  96,
                  height: 1,
                  color: AuvieColors.bone,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'A darkroom for the photographs and films on your phone.',
                style: AuvieTypography.serif(
                  30,
                  italic: true,
                  color: AuvieColors.bone,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
