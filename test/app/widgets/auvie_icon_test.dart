import 'dart:io';

import 'package:auvie/app/widgets/auvie_icon.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('enum covers every bundled icon', () {
    final files = Directory('assets/icons')
        .listSync()
        .map((f) => p.basenameWithoutExtension(f.path))
        .toSet();

    expect(AuvieIcons.values.map((i) => i.name).toSet(), files);
  });

  for (final icon in AuvieIcons.values) {
    test(
      '${icon.name} is a stroke icon tinted by currentColor on its grid',
      () async {
        final svg = await rootBundle.loadString(icon.asset);
        expect(svg, contains('stroke="currentColor"'));

        final info = await vg.loadPicture(SvgStringLoader(svg), null);
        addTearDown(info.picture.dispose);
        expect(info.size, Size(icon.grid, icon.grid));
      },
    );
  }
}
