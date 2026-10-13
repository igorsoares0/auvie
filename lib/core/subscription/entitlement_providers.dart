import 'dart:async';

import 'package:auvie/app/settings/app_settings.dart';
import 'package:auvie/core/subscription/entitlement.dart';
import 'package:auvie/core/subscription/entitlement_service.dart';
import 'package:auvie/core/subscription/revenuecat_entitlement_service.dart';
import 'package:auvie/core/subscription/simulated_entitlement_service.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'entitlement_providers.g.dart';

/// RevenueCat's public Android key, given at build time:
/// `--dart-define=REVENUECAT_ANDROID_KEY=goog_…` (docs/REVENUECAT-SETUP.md).
const revenueCatAndroidKey = String.fromEnvironment('REVENUECAT_ANDROID_KEY');

/// The store: RevenueCat when a key is set; otherwise the simulated store in
/// debug and profile builds, and "not available" in release.
@Riverpod(keepAlive: true)
EntitlementService entitlementService(Ref ref) {
  final settings = ref.watch(appSettingsProvider);
  final service = revenueCatAndroidKey.isNotEmpty
      ? RevenueCatEntitlementService(revenueCatAndroidKey, settings)
      : kReleaseMode
      ? UnavailableEntitlementService(settings)
      : SimulatedEntitlementService(settings) as EntitlementService;
  unawaited(
    service.start().catchError(
      (Object e) => debugPrint('Store not started: $e'),
    ),
  );
  return service;
}

/// Whether the user has Pro, updated on every purchase or expiration.
@Riverpod(keepAlive: true)
class ProAccess extends _$ProAccess {
  @override
  Entitlement build() {
    final service = ref.watch(entitlementServiceProvider);
    final sub = service.changes.listen((e) => state = e);
    ref.onDispose(sub.cancel);
    return service.current;
  }
}
