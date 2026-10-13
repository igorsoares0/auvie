import 'dart:async';

import 'package:auvie/app/router/routes.dart';
import 'package:auvie/core/platform/link_opener.dart';
import 'package:auvie/core/subscription/entitlement.dart';
import 'package:auvie/core/subscription/entitlement_providers.dart';
import 'package:auvie/features/subscription/pro_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_entitlement_service.dart';
import '../../helpers/pump_app.dart';

void main() {
  late TestApp app;

  /// Home → Pro, remembering what the paywall pops with.
  Future<Completer<bool?>> openPro(
    WidgetTester tester, {
    FakeEntitlementService? store,
  }) async {
    app = (await tester.runAsync(() => TestApp.create(store: store)))!;
    await tester.pumpTestApp(app);
    final result = Completer<bool?>();
    unawaited(app.router.push<bool>(AppRoutes.pro).then(result.complete));
    await tester.pumpAndSettle();
    return result;
  }

  bool isPro() => app.container.read(proAccessProvider).isPro;

  String terms(WidgetTester tester) =>
      tester.widget<Text>(find.byKey(const Key('pro-terms-sentence'))).data!;

  testWidgets('offers yearly first, with its saving and trial', (tester) async {
    await openPro(tester);

    expect(
      find.text('The whole darkroom, unlocked.', findRichText: true),
      findsOneWidget,
    );
    for (final (title, _) in ProScreen.benefits) {
      expect(find.text(title), findsOneWidget);
    }
    expect(find.text('SAVE 44%'), findsOneWidget);
    expect(find.text(r'$3.33 / MONTH · 7 DAYS FREE'), findsOneWidget);
    expect(find.text('START FREE TRIAL'), findsOneWidget);
    expect(terms(tester), startsWith(r'Free for 7 days, then $39.99 a year.'));
    expect(find.textContaining('watermark', findRichText: true), findsNothing);
  });

  testWidgets('monthly changes the button and the terms', (tester) async {
    await openPro(tester);

    await tapKey(tester, 'plan-monthly');

    expect(find.text('CONTINUE'), findsOneWidget);
    expect(terms(tester), startsWith(r'$5.99 a month'));
  });

  testWidgets('buying gives Pro and closes with true', (tester) async {
    final result = await openPro(tester);

    await tapKey(tester, 'pro-purchase');

    expect(app.store.purchased.single.period, ProPeriod.yearly);
    expect(isPro(), isTrue);
    expect(await result.future, isTrue);
    expect(find.byType(ProScreen), findsNothing);
  });

  testWidgets('cancelling stays; failures and pending payments say so', (
    tester,
  ) async {
    final store = FakeEntitlementService()..outcome = const PurchaseCancelled();
    await openPro(tester, store: store);

    await tapKey(tester, 'pro-purchase');
    expect(find.byType(ProScreen), findsOneWidget);
    expect(find.byKey(const Key('pro-message')), findsNothing);

    store.outcome = const PurchaseFailed('Card declined.');
    await tapKey(tester, 'pro-purchase');
    expect(find.text('Card declined.'), findsOneWidget);

    store.outcome = const PurchasePending();
    await tapKey(tester, 'pro-purchase');
    expect(find.textContaining('being processed'), findsOneWidget);
    expect(isPro(), isFalse);
  });

  testWidgets('RESTORE finds Pro, or says it found none', (tester) async {
    final store = FakeEntitlementService();
    final result = await openPro(tester, store: store);

    await tapKey(tester, 'pro-restore');
    expect(
      find.text('No Pro purchase on this Google account.'),
      findsOneWidget,
    );

    store.restorable = true;
    await tapKey(tester, 'pro-restore');
    expect(isPro(), isTrue);
    expect(await result.future, isTrue);
  });

  testWidgets('Pro users see their plan and where to manage it', (
    tester,
  ) async {
    await openPro(tester, store: FakeEntitlementService(pro: true));

    expect(find.byKey(const Key('pro-owned')), findsOneWidget);
    expect(find.text('You have Pro.', findRichText: true), findsOneWidget);
    expect(find.byKey(const Key('pro-purchase')), findsNothing);
    expect(find.byKey(const Key('pro-reset')), findsNothing);

    await tapKey(tester, 'pro-manage');
    expect(app.links.opened.single.host, 'play.google.com');
  });

  testWidgets('the simulated store can go back to free', (tester) async {
    await openPro(
      tester,
      store: FakeEntitlementService(pro: true)..simulated = true,
    );

    await tapKey(tester, 'pro-reset');

    expect(isPro(), isFalse);
    expect(find.byKey(const Key('pro-purchase')), findsOneWidget);
  });

  testWidgets('without a store, Pro is not available yet', (tester) async {
    await openPro(tester, store: FakeEntitlementService(available: false));

    expect(find.byKey(const Key('pro-unavailable')), findsOneWidget);
    expect(find.byKey(const Key('pro-purchase')), findsNothing);
  });

  testWidgets('terms, privacy and close', (tester) async {
    final result = await openPro(tester);

    await tapKey(tester, 'pro-terms');
    await tapKey(tester, 'pro-privacy');
    expect(app.links.opened, [termsUrl, privacyUrl]);

    await tapKey(tester, 'pro-close');
    expect(await result.future, isFalse);
  });
}

Future<void> tapKey(WidgetTester tester, String key) async {
  await tester.ensureVisible(find.byKey(Key(key)));
  await tester.tap(find.byKey(Key(key)));
  await tester.pumpAndSettle();
}
