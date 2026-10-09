import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'app_settings.g.dart';

/// The loaded preferences. Overridden in `main` (loading is async) and tests.
@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(Ref ref) =>
    throw UnimplementedError('Override sharedPreferencesProvider');

@Riverpod(keepAlive: true)
AppSettings appSettings(Ref ref) =>
    AppSettings(ref.watch(sharedPreferencesProvider));

/// Small persistent flags. Everything else lives in the database.
class AppSettings {
  const new(this._prefs);

  final SharedPreferences _prefs;

  static const _onboardingSeen = 'auvie.onboardingSeen';
  static const _framesExposed = 'auvie.framesExposed';

  /// Frames per roll, like 36-exposure film.
  static const framesPerRoll = 36;

  bool get onboardingSeen => _prefs.getBool(_onboardingSeen) ?? false;

  Future<void> markOnboardingSeen() => _prefs.setBool(_onboardingSeen, true);

  /// Names the next project like a frame on a roll of film:
  /// "Roll 001 · 01" … "Roll 001 · 36", "Roll 002 · 01" …
  /// Numbers keep growing even when projects are deleted.
  Future<String> nextFrameName() async {
    final exposed = _prefs.getInt(_framesExposed) ?? 0;
    await _prefs.setInt(_framesExposed, exposed + 1);
    final roll = exposed ~/ framesPerRoll + 1;
    final frame = exposed % framesPerRoll + 1;
    return 'Roll ${roll.toString().padLeft(3, '0')} · '
        '${frame.toString().padLeft(2, '0')}';
  }
}
