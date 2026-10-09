import 'package:auvie/features/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

void main() {
  testWidgets('starts on Home with the wordmark', (tester) async {
    await tester.pumpAuvieApp();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('AUVIE'), findsOneWidget);
  });

  testWidgets('uses the app name as title', (tester) async {
    await tester.pumpAuvieApp();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.title, 'Auvie');
  });
}
