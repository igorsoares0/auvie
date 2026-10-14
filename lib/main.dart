import 'dart:async';

import 'package:auvie/app/app.dart';
import 'package:auvie/app/licenses.dart';
import 'package:auvie/app/settings/app_settings.dart';
import 'package:auvie/app/widgets/error_block.dart';
import 'package:auvie/core/storage/storage_providers.dart';
import 'package:auvie/core/telemetry/telemetry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerFontLicenses();
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
  catchErrors(container.read(telemetryProvider));
  // Leftovers of exports interrupted a day ago or more.
  unawaited(
    container
        .read(cacheCleanerProvider)
        .cleanStale()
        .catchError((Object e) => 0),
  );
  runApp(
    UncontrolledProviderScope(container: container, child: const AuvieApp()),
  );
}

/// Errors never close the app (spec §64): they are reported to
/// [telemetry]; a widget that fails to build shows a quiet note instead of
/// the red error screen in release builds.
void catchErrors(Telemetry telemetry) {
  final previous = FlutterError.onError;
  FlutterError.onError = (details) {
    telemetry.error(details.exception, details.stack);
    previous?.call(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    telemetry.error(error, stack, fatal: true);
    return true; // Handled: keep the app running.
  };
  if (kReleaseMode) {
    ErrorWidget.builder = (details) => const ErrorBlock();
  }
}
