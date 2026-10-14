import 'dart:convert';
import 'dart:io';

import 'package:integration_test/integration_test_driver.dart';

/// `flutter drive --profile --no-dds --driver=test_driver/perf_driver.dart
/// --target=integration_test/perf_test.dart`: writes each frame-timing
/// summary (`watchPerformance` reportKey) to `build/perf/KEY.json`.
Future<void> main() => integrationDriver(
  responseDataCallback: (data) async {
    if (data == null) return;
    final dir = Directory('build/perf')..createSync(recursive: true);
    for (final MapEntry(:key, :value) in data.entries) {
      File(
        '${dir.path}/$key.json',
      ).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(value));
      stdout.writeln('perf: wrote $key');
    }
  },
);
