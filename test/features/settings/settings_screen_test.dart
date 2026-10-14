import 'dart:async';
import 'dart:io';

import 'package:auvie/app/router/routes.dart';
import 'package:auvie/app/settings/app_settings.dart';
import 'package:auvie/core/platform/link_opener.dart';
import 'package:auvie/core/telemetry/telemetry.dart';
import 'package:auvie/features/onboarding/onboarding_screen.dart';
import 'package:auvie/features/subscription/pro_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import '../../helpers/fake_entitlement_service.dart';
import '../../helpers/pump_app.dart';

void main() {
  late TestApp app;

  Future<void> openSettings(
    WidgetTester tester, {
    FakeEntitlementService? store,
    void Function(TestApp app)? before,
  }) async {
    app = (await tester.runAsync(() => TestApp.create(store: store)))!;
    before?.call(app);
    await tester.pumpTestApp(app);
    unawaited(app.router.push(AppRoutes.settings));
    await tester.pumpAndSettle();
  }

  Future<void> tapKey(WidgetTester tester, String key) async {
    await tester.ensureVisible(find.byKey(Key(key)));
    await tester.tap(find.byKey(Key(key)));
    await tester.pumpAndSettle();
  }

  testWidgets('free users see Pro, restore and the version', (tester) async {
    await openSettings(tester);

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Free'), findsOneWidget);
    expect(find.text('VERSION 1.0.0 (1)'), findsOneWidget);

    await tapKey(tester, 'settings-restore');
    expect(
      find.text('No Pro purchase on this Google account.'),
      findsOneWidget,
    );

    await tapKey(tester, 'settings-see-pro');
    expect(find.byType(ProScreen), findsOneWidget);
    expect(app.telemetry.of(TelemetryEvent.paywallViewed), [
      {'source': 'settings'},
    ]);
  });

  testWidgets('Pro users manage their subscription', (tester) async {
    await openSettings(tester, store: FakeEntitlementService(pro: true));

    expect(find.text('Pro'), findsOneWidget);
    expect(find.byKey(const Key('settings-restore')), findsNothing);
    await tapKey(tester, 'settings-manage');
    expect(app.links.opened.single.host, 'play.google.com');
  });

  testWidgets('CLEAR frees exports and leftovers, never edits', (tester) async {
    late File old;
    late File thumbnail;
    await openSettings(
      tester,
      before: (app) {
        final paths = app.paths;
        old = File(p.join(paths.exports.path, 'old.jpg'))
          ..createSync(recursive: true)
          ..writeAsBytesSync(List.filled(3 * 1024 * 1024, 1))
          ..setLastModifiedSync(
            DateTime.now().subtract(const Duration(days: 1)),
          );
        thumbnail = paths.previewFor('p1')
          ..createSync(recursive: true)
          ..writeAsBytesSync([1, 2, 3]);
      },
    );
    expect(find.textContaining('3.0 MB'), findsOneWidget);

    await tapKey(tester, 'settings-clear');

    expect(find.text('Freed 3.0 MB.'), findsOneWidget);
    expect(old.existsSync(), isFalse);
    expect(thumbnail.existsSync(), isTrue);
    expect(find.textContaining('0.0 MB'), findsOneWidget);
  });

  testWidgets('terms, privacy, licenses', (tester) async {
    await openSettings(tester);

    await tapKey(tester, 'settings-terms');
    await tapKey(tester, 'settings-privacy');
    expect(app.links.opened, [termsUrl, privacyUrl]);

    await tapKey(tester, 'settings-licenses');
    expect(find.byType(LicensePage), findsOneWidget);
  });

  testWidgets('replaying the welcome opens the onboarding', (tester) async {
    await openSettings(tester);

    await tapKey(tester, 'settings-welcome');

    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(app.container.read(appSettingsProvider).onboardingSeen, isFalse);
  });
}
