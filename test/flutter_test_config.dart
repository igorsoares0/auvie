import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Runs before every test file: loads the app's real fonts so layouts and
/// goldens match the device instead of the default test font.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await _loadAppFonts();
  await testMain();
}

const _fonts = {
  'Newsreader': [
    'assets/fonts/Newsreader.ttf',
    'assets/fonts/Newsreader-Italic.ttf',
  ],
  'Jost': ['assets/fonts/Jost.ttf'],
  'Geist': ['assets/fonts/Geist.ttf'],
  'IBMPlexMono': ['assets/fonts/IBMPlexMono-Regular.ttf'],
  'Caveat': ['assets/fonts/Caveat.ttf'],
  'PlayfairDisplay': ['assets/fonts/PlayfairDisplay.ttf'],
  'AbrilFatface': ['assets/fonts/AbrilFatface.ttf'],
  'BebasNeue': ['assets/fonts/BebasNeue.ttf'],
  'SpecialElite': ['assets/fonts/SpecialElite.ttf'],
  'Shrikhand': ['assets/fonts/Shrikhand.ttf'],
  'Yellowtail': ['assets/fonts/Yellowtail.ttf'],
  'PirataOne': ['assets/fonts/PirataOne.ttf'],
  'PermanentMarker': ['assets/fonts/PermanentMarker.ttf'],
  'VT323': ['assets/fonts/VT323.ttf'],
};

Future<void> _loadAppFonts() async {
  for (final MapEntry(key: family, value: files) in _fonts.entries) {
    final loader = FontLoader(family);
    for (final file in files) {
      loader.addFont(rootBundle.load(file));
    }
    await loader.load();
  }
}
