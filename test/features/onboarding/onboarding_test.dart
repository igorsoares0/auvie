import 'package:auvie/app/settings/app_settings.dart';
import 'package:auvie/features/home/home_screen.dart';
import 'package:auvie/features/onboarding/onboarding_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_entitlement_service.dart';
import '../../helpers/pump_app.dart';

void main() {
  Future<TestApp> firstLaunch(
    WidgetTester tester, {
    FakeEntitlementService? store,
  }) async {
    final app = (await tester.runAsync(
      () => TestApp.create(onboardingSeen: false, store: store),
    ))!;
    await tester.pumpTestApp(app);
    return app;
  }

  bool seen(TestApp app) =>
      app.container.read(appSettingsProvider).onboardingSeen;

  testWidgets('first launch opens on the cover', (tester) async {
    await firstLaunch(tester);
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text('Auvie'), findsOneWidget);
    expect(find.text('BEGIN'), findsOneWidget);
  });

  testWidgets('walks through the story and lands on Home', (tester) async {
    final app = await firstLaunch(tester);

    await tester.tap(find.text('BEGIN'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('real emulsions', findRichText: true),
      findsOneWidget,
    );

    await tester.tap(find.text('NEXT'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('along a line', findRichText: true),
      findsOneWidget,
    );

    await tester.tap(find.text('NEXT'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('what you choose', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('NO ACCESS TO YOUR GALLERY'), findsOneWidget);
    expect(seen(app), isFalse);

    await tester.tap(find.text('CONTINUE'));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(seen(app), isTrue);
  });

  testWidgets('skip goes straight to Home', (tester) async {
    final app = await firstLaunch(tester);
    await tester.tap(find.text('BEGIN'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('SKIP'));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(seen(app), isTrue);
  });

  testWidgets('pages show their progress mark', (tester) async {
    await firstLaunch(tester);
    await tester.tap(find.text('BEGIN'));
    await tester.pumpAndSettle();
    final active = tester.getSize(find.byKey(const Key('progress-active')));
    expect(active.width, 18);
  });

  testWidgets('later launches skip onboarding', (tester) async {
    final app = (await tester.runAsync(TestApp.create))!;
    await tester.pumpTestApp(app);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('I ALREADY HAVE PRO restores it and skips the welcome', (
    tester,
  ) async {
    final app = await firstLaunch(
      tester,
      store: FakeEntitlementService()..restorable = true,
    );

    await tester.tap(find.byKey(const Key('onboarding-have-pro')));
    await tester.pumpAndSettle();

    expect(app.store.restores, 1);
    expect(find.text('Pro restored.'), findsOneWidget);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(seen(app), isTrue);
  });

  testWidgets('I ALREADY HAVE PRO says when nothing was found', (tester) async {
    final app = await firstLaunch(tester);

    await tester.tap(find.byKey(const Key('onboarding-have-pro')));
    await tester.pumpAndSettle();

    expect(
      find.text('No Pro purchase on this Google account.'),
      findsOneWidget,
    );
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(seen(app), isFalse);
  });
}
