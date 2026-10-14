import 'dart:async';

import 'package:auvie/app/router/routes.dart';
import 'package:auvie/app/settings/app_settings.dart';
import 'package:auvie/app/theme/app_theme.dart';
import 'package:auvie/app/theme/spacing.dart';
import 'package:auvie/app/theme/typography.dart';
import 'package:auvie/app/widgets/auvie_icon.dart';
import 'package:auvie/app/widgets/caps_link.dart';
import 'package:auvie/app/widgets/system_bars.dart';
import 'package:auvie/core/platform/link_opener.dart';
import 'package:auvie/core/storage/storage_providers.dart';
import 'package:auvie/core/subscription/entitlement.dart';
import 'package:auvie/core/subscription/entitlement_providers.dart';
import 'package:auvie/features/export/export_options.dart';
import 'package:auvie/features/subscription/pro_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_screen.g.dart';

/// Platform answers won't change by retrying.
Duration? _noRetry(int retryCount, Object error) => null;

/// "1.0.0 (1)".
@Riverpod(retry: _noRetry)
Future<String> appVersion(Ref ref) async {
  final info = await PackageInfo.fromPlatform();
  return '${info.version} (${info.buildNumber})';
}

/// Bytes Settings → STORAGE can free.
@Riverpod(retry: _noRetry)
Future<int> cacheSize(Ref ref) => ref.watch(cacheCleanerProvider).size();

/// Settings (paper): Pro, storage and about. No design in the handoff; it
/// follows the Archive and Pro screens.
class SettingsScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _busy = false;

  void _say(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore() => _run(() async {
    final service = ref.read(entitlementServiceProvider);
    if (!service.available) return _say("Pro isn't available yet.");
    try {
      final found = (await service.restore()).isPro;
      _say(found ? 'Pro restored.' : 'No Pro purchase on this Google account.');
    } on Exception {
      _say("Couldn't reach Google Play. Try again later.");
    }
  });

  Future<void> _clear() => _run(() async {
    final freed = await ref.read(cacheCleanerProvider).clear();
    ref.invalidate(cacheSizeProvider);
    _say(freed == 0 ? 'Nothing to clear.' : 'Freed ${megabytes(freed)}.');
  });

  Future<void> _open(Uri url) async {
    final opened = await ref.read(linkOpenerProvider).open(url);
    if (!opened) _say("That page couldn't be opened.");
  }

  Future<void> _replayWelcome() async {
    await ref.read(appSettingsProvider).resetOnboarding();
    if (mounted) context.go(AppRoutes.onboarding);
  }

  @override
  Widget build(BuildContext context) {
    final entitlement = ref.watch(proAccessProvider);
    final cache = ref.watch(cacheSizeProvider).value;
    final version = ref.watch(appVersionProvider).value;
    final service = ref.watch(entitlementServiceProvider);

    return SystemBars(
      child: Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: AuvieSpacing.gutter,
            ),
            children: [
              SizedBox(
                height: AuvieSpacing.headerHeight,
                child: Row(
                  children: [
                    Semantics(
                      button: true,
                      label: 'Home',
                      child: GestureDetector(
                        key: const Key('settings-back'),
                        behavior: HitTestBehavior.opaque,
                        onTap: () => context.pop(),
                        child: SizedBox(
                          height: AuvieSpacing.minHitTarget,
                          child: Row(
                            children: [
                              Transform.flip(
                                flipX: true,
                                child: const AuvieIcon(
                                  AuvieIcons.arrow,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: AuvieSpacing.s6),
                              Text('HOME', style: context.type.label),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AuvieSpacing.s6),
              Text(
                'Settings',
                style: context.type.display.copyWith(fontSize: 42),
              ),
              const _Section('Auvie Pro'),
              _Row(
                key: const Key('settings-pro'),
                title: entitlement.isPro ? 'Pro' : 'Free',
                note: _proNote(entitlement),
                action: entitlement.isPro
                    ? CapsLink(
                        'Manage',
                        key: const Key('settings-manage'),
                        onTap: () => _open(service.manageUrl),
                      )
                    : CapsLink(
                        'See Pro',
                        key: const Key('settings-see-pro'),
                        color: context.palette.accent,
                        onTap: () =>
                            context.push(AppRoutes.proFrom('settings')),
                      ),
              ),
              if (!entitlement.isPro)
                _Row(
                  title: 'Already bought Pro?',
                  note: 'ON THIS GOOGLE ACCOUNT',
                  action: CapsLink(
                    'Restore',
                    key: const Key('settings-restore'),
                    onTap: _busy ? null : _restore,
                  ),
                ),
              const _Section('Storage'),
              _Row(
                key: const Key('settings-storage'),
                title: 'Exports and leftovers',
                note: cache == null
                    ? '…'
                    : '${megabytes(cache)} · YOUR EDITS AND THE GALLERY STAY',
                action: CapsLink(
                  'Clear',
                  key: const Key('settings-clear'),
                  onTap: _busy ? null : _clear,
                ),
              ),
              const _Section('About'),
              _Row(
                title: 'Auvie',
                note: version == null ? '' : 'VERSION $version',
              ),
              _Link(
                'Terms of use',
                key: const Key('settings-terms'),
                onTap: () => _open(termsUrl),
              ),
              _Link(
                'Privacy',
                key: const Key('settings-privacy'),
                onTap: () => _open(privacyUrl),
              ),
              _Link(
                'Open-source licenses',
                key: const Key('settings-licenses'),
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: 'Auvie',
                  applicationVersion: version,
                ),
              ),
              _Link(
                'Replay the welcome',
                key: const Key('settings-welcome'),
                onTap: _replayWelcome,
              ),
              if (!kReleaseMode)
                _Link(
                  'Engine lab',
                  onTap: () => context.push(AppRoutes.engineLab),
                ),
              const SizedBox(height: AuvieSpacing.s34),
              Text(
                'Your photos and films never leave this phone.',
                textAlign: TextAlign.center,
                style: AuvieTypography.serif(
                  14,
                  italic: true,
                  color: context.palette.muted,
                ),
              ),
              const SizedBox(height: AuvieSpacing.s22),
            ],
          ),
        ),
      ),
    );
  }

  static String _proNote(Entitlement e) {
    if (!e.isPro) return 'EVERY FILM AND THE FULL KIT';
    final period = switch (e.period) {
      ProPeriod.yearly => 'YEARLY',
      ProPeriod.monthly => 'MONTHLY',
      null => 'ACTIVE',
    };
    final expires = e.expiresAt;
    if (expires == null) return period;
    return '$period · ${e.inTrial ? 'FREE UNTIL' : 'RENEWS'} '
        '${shortDate(expires)}';
  }
}

class _Section extends StatelessWidget {
  const new(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AuvieSpacing.s28,
        bottom: AuvieSpacing.s6,
      ),
      child: Text(title.toUpperCase(), style: context.type.label),
    );
  }
}

class _Row extends StatelessWidget {
  const new({required this.title, required this.note, this.action, super.key});

  final String title;
  final String note;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: palette.hairline)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AuvieSpacing.s10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AuvieTypography.serif(18, color: palette.foreground),
                  ),
                  if (note.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(note, style: context.type.tag),
                  ],
                ],
              ),
            ),
            ?action,
          ],
        ),
      ),
    );
  }
}

class _Link extends StatelessWidget {
  const new(this.title, {required this.onTap, super.key});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: palette.hairline)),
          ),
          child: SizedBox(
            height: 52,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AuvieTypography.serif(17, color: palette.foreground),
                  ),
                ),
                AuvieIcon(AuvieIcons.arrow, size: 16, color: palette.muted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
