import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Bundled fonts are SIL OFL; their licenses must ship with the app.
const _fontLicenses = {
  'Newsreader': 'assets/fonts/OFL-Newsreader.txt',
  'Jost': 'assets/fonts/OFL-Jost.txt',
  'Geist': 'assets/fonts/OFL-Geist.txt',
  'IBM Plex Mono': 'assets/fonts/OFL-IBMPlexMono.txt',
  'Caveat': 'assets/fonts/OFL-Caveat.txt',
};

void registerFontLicenses() {
  LicenseRegistry.addLicense(() async* {
    for (final MapEntry(key: family, value: path) in _fontLicenses.entries) {
      final text = await rootBundle.loadString(path);
      yield LicenseEntryWithLineBreaks([family], text);
    }
  });
}
