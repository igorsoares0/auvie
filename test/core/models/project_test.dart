import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fixtures.dart';

void main() {
  test('aspect ratio is width / height after rotation', () {
    expect(photoMedia.aspectRatio, closeTo(4 / 3, 1e-9));
    expect(videoMedia.aspectRatio, closeTo(9 / 16, 1e-9));
  });
}
