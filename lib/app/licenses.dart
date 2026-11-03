import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Bundled fonts are SIL OFL or Apache 2.0; their licenses must ship with
/// the app.
const _fontLicenses = {
  'Newsreader': 'assets/fonts/OFL-Newsreader.txt',
  'Jost': 'assets/fonts/OFL-Jost.txt',
  'Geist': 'assets/fonts/OFL-Geist.txt',
  'IBM Plex Mono': 'assets/fonts/OFL-IBMPlexMono.txt',
  'Caveat': 'assets/fonts/OFL-Caveat.txt',
  'Playfair Display': 'assets/fonts/OFL-PlayfairDisplay.txt',
  'Abril Fatface': 'assets/fonts/OFL-AbrilFatface.txt',
  'Bebas Neue': 'assets/fonts/OFL-BebasNeue.txt',
  'Special Elite': 'assets/fonts/LICENSE-SpecialElite.txt',
  'Shrikhand': 'assets/fonts/OFL-Shrikhand.txt',
  'Yellowtail': 'assets/fonts/LICENSE-Yellowtail.txt',
  'Pirata One': 'assets/fonts/OFL-PirataOne.txt',
  'Permanent Marker': 'assets/fonts/LICENSE-PermanentMarker.txt',
  'VT323': 'assets/fonts/OFL-VT323.txt',
};

void registerFontLicenses() {
  LicenseRegistry.addLicense(() async* {
    for (final MapEntry(key: family, value: path) in _fontLicenses.entries) {
      final text = await rootBundle.loadString(path);
      yield LicenseEntryWithLineBreaks([family], text);
    }
  });
}
