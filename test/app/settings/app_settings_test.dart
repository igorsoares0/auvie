import 'package:auvie/app/settings/app_settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AppSettings settings;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    settings = AppSettings(await SharedPreferences.getInstance());
  });

  test('onboarding starts unseen and is remembered', () async {
    expect(settings.onboardingSeen, isFalse);
    await settings.markOnboardingSeen();
    expect(settings.onboardingSeen, isTrue);
  });

  test('frames are named like a roll of film', () async {
    expect(await settings.nextFrameName(), 'Roll 001 · 01');
    expect(await settings.nextFrameName(), 'Roll 001 · 02');
  });

  test('a new roll starts after 36 frames', () async {
    final names = [
      for (var i = 0; i < AppSettings.framesPerRoll + 1; i++)
        await settings.nextFrameName(),
    ];
    expect(names[35], 'Roll 001 · 36');
    expect(names[36], 'Roll 002 · 01');
  });
}
