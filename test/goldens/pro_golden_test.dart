@Tags(['golden'])
library;

import 'dart:async';

import 'package:auvie/app/router/routes.dart';
import 'package:auvie/core/storage/storage_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fake_entitlement_service.dart';
import '../helpers/fixtures.dart';
import '../helpers/pump_app.dart';

void main() {
  Future<TestApp> open(
    WidgetTester tester,
    String location, {
    bool pro = false,
    List<String> favorites = const [],
  }) async {
    final app = (await tester.runAsync(
      () => TestApp.create(
        store: FakeEntitlementService(pro: pro),
        favorites: favorites,
      ),
    ))!;
    await tester.pumpTestApp(app);
    unawaited(app.router.push(location));
    await tester.pumpAndSettle();
    return app;
  }

  Future<void> expectScreen(String name) => expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('screens/$name.png'),
  );

  testWidgets('archive', (tester) async {
    await open(tester, AppRoutes.archive, favorites: ['portra_04']);
    await expectScreen('archive');
  });

  testWidgets('pro paywall', (tester) async {
    await open(tester, AppRoutes.pro);
    await expectScreen('pro');
  });

  testWidgets('pro, already subscribed', (tester) async {
    await open(tester, AppRoutes.pro, pro: true);
    await expectScreen('pro_owned');
  });

  testWidgets('export with a Pro film', (tester) async {
    final app = (await tester.runAsync(TestApp.create))!;
    final repository = app.container.read(projectRepositoryProvider);
    final created = (await tester.runAsync(
      () => repository.create(photoMedia, name: 'Roll 014 · 07'),
    ))!;
    await tester.runAsync(
      () => repository.save(
        created.copyWith(edit: created.edit.withPreset('nocturne_19')),
      ),
    );
    await tester.pumpTestApp(app);
    unawaited(app.router.push(AppRoutes.export(created.id)));
    await tester.pumpAndSettle();
    await expectScreen('export_pro_notice');
  });
}
