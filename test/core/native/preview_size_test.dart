import 'dart:ui';

import 'package:auvie/core/models/project.dart';
import 'package:auvie/core/native/preview_size.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const landscape = MediaRef(
    uri: 'content://p',
    type: MediaType.photo,
    width: 4000,
    height: 3000,
  );

  int maxPx(MediaRef media, Size box, [double dpr = 3]) =>
      previewMaxPx(media: media, box: box, devicePixelRatio: dpr);

  test('a landscape photo is limited by the box width', () {
    // 360 × 400 logical at 3x: shown 1080 × 810 physical.
    expect(maxPx(landscape, const Size(360, 400)), 1080);
  });

  test('a portrait photo is limited by the box height', () {
    const portrait = MediaRef(
      uri: 'content://p',
      type: MediaType.photo,
      width: 3000,
      height: 4000,
    );
    // Height-bound: 300 logical × 3 = 900.
    expect(maxPx(portrait, const Size(360, 300)), 900);
  });

  test('never exceeds the original', () {
    const small = MediaRef(
      uri: 'content://p',
      type: MediaType.photo,
      width: 640,
      height: 480,
    );
    expect(maxPx(small, const Size(400, 400)), 640);
  });

  test('an unmeasured box falls back to a small preview', () {
    expect(maxPx(landscape, Size.zero), 256);
  });
}
