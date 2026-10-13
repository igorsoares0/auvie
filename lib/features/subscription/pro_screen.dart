import 'dart:async';

import 'package:auvie/app/theme/app_theme.dart';
import 'package:auvie/app/theme/spacing.dart';
import 'package:auvie/app/theme/typography.dart';
import 'package:auvie/app/widgets/caps_link.dart';
import 'package:auvie/app/widgets/emphasis_text.dart';
import 'package:auvie/app/widgets/film_art.dart';
import 'package:auvie/core/platform/link_opener.dart';
import 'package:auvie/core/subscription/entitlement.dart';
import 'package:auvie/core/subscription/entitlement_providers.dart';
import 'package:auvie/core/subscription/entitlement_service.dart';
import 'package:auvie/core/subscription/pro_formatting.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Pro (handoff 08, paper): what Pro unlocks, the plans and the purchase.
/// Pops `true` when the user ends up with Pro, so Export can carry on.
class ProScreen extends ConsumerStatefulWidget {
  const new({super.key});

  /// The three benefits i / ii / iii (decision M7: Pro is content only).
  static const benefits = [
    ('Every collection, every edition', 'ALL FILMS · NEW EACH MONTH'),
    ('The full darkroom kit', 'LEAKS · BURNS · FRAMES · STICKERS'),
    ('Everything you make stays yours', 'NO WATERMARK, EVER · CANCEL ANYTIME'),
  ];

  @override
  ConsumerState<ProScreen> createState() => _ProScreenState();
}

class _ProScreenState extends ConsumerState<ProScreen> {
  late final Future<List<ProPlan>> _plans;
  String? _selected;
  bool _busy = false;
  String? _message;

  EntitlementService get _service => ref.read(entitlementServiceProvider);

  @override
  void initState() {
    super.initState();
    _plans = _service.plans().catchError((Object e) {
      debugPrint('Plans: $e');
      return const <ProPlan>[];
    });
  }

  void _close({bool pro = false}) {
    if (context.canPop()) context.pop(pro);
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await action();
    } on PlatformException catch (e) {
      if (mounted) setState(() => _message = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _purchase(ProPlan plan) => _run(() async {
    final outcome = await _service.purchase(plan);
    if (!mounted) return;
    switch (outcome) {
      case PurchaseDone():
        _close(pro: true);
      case PurchaseCancelled():
        break;
      case PurchasePending():
        setState(
          () => _message =
              'Your payment is being processed. Pro unlocks when it clears.',
        );
      case PurchaseFailed(:final message):
        setState(() => _message = message ?? "The purchase didn't go through.");
    }
  });

  Future<void> _restore() => _run(() async {
    final entitlement = await _service.restore();
    if (!mounted) return;
    if (entitlement.isPro) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Pro restored.')));
      _close(pro: true);
    } else {
      setState(() => _message = 'No Pro purchase on this Google account.');
    }
  });

  Future<void> _open(Uri url) async {
    final opened = await ref.read(linkOpenerProvider).open(url);
    if (!opened && mounted) {
      setState(() => _message = "That page couldn't be opened.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final entitlement = ref.watch(proAccessProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AuvieSpacing.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: AuvieSpacing.headerHeight,
                child: Row(
                  children: [
                    Text(
                      'AUVIE PRO',
                      style: context.type.tag.copyWith(color: palette.accent),
                    ),
                    const Spacer(),
                    CapsLink('×', key: const Key('pro-close'), onTap: _close),
                  ],
                ),
              ),
              const SizedBox(height: AuvieSpacing.s6),
              EmphasisText(
                'The whole *darkroom,* unlocked.',
                style: context.type.display.copyWith(fontSize: 34),
              ),
              const SizedBox(height: AuvieSpacing.s18),
              const SizedBox(
                height: 112,
                child: FilmArt(tone: FilmArt.nocturne, seed: 3),
              ),
              const SizedBox(height: AuvieSpacing.s8),
              for (final (i, (title, note)) in ProScreen.benefits.indexed)
                _Benefit(
                  numeral: const ['i', 'ii', 'iii'][i],
                  title: title,
                  note: note,
                ),
              const SizedBox(height: AuvieSpacing.s18),
              if (entitlement.isPro)
                _Owned(
                  entitlement: entitlement,
                  simulated: _service.simulated,
                  onManage: () => _open(_service.manageUrl),
                  onReset: () => _run(_service.resetSimulation),
                )
              else
                FutureBuilder<List<ProPlan>>(
                  future: _plans,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const SizedBox(
                        height: 140,
                        child: Center(
                          child: SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 1),
                          ),
                        ),
                      );
                    }
                    final plans = snapshot.data ?? const [];
                    if (plans.isEmpty) return const _Unavailable();
                    return _Plans(
                      plans: plans,
                      selected: _selected ?? plans.first.id,
                      busy: _busy,
                      onSelect: (id) => setState(() => _selected = id),
                      onPurchase: _purchase,
                    );
                  },
                ),
              if (_message case final message?) ...[
                const SizedBox(height: AuvieSpacing.s10),
                Text(
                  message,
                  key: const Key('pro-message'),
                  textAlign: TextAlign.center,
                  style: context.type.body.copyWith(color: palette.accent),
                ),
              ],
              const SizedBox(height: AuvieSpacing.s10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!entitlement.isPro)
                    CapsLink(
                      'Restore',
                      key: const Key('pro-restore'),
                      color: palette.mutedStrong,
                      onTap: _busy || !_service.available ? null : _restore,
                    ),
                  const SizedBox(width: AuvieSpacing.s18),
                  CapsLink(
                    'Terms',
                    key: const Key('pro-terms'),
                    color: palette.mutedStrong,
                    onTap: () => _open(termsUrl),
                  ),
                  const SizedBox(width: AuvieSpacing.s18),
                  CapsLink(
                    'Privacy',
                    key: const Key('pro-privacy'),
                    color: palette.mutedStrong,
                    onTap: () => _open(privacyUrl),
                  ),
                ],
              ),
              const SizedBox(height: AuvieSpacing.s12),
            ],
          ),
        ),
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  const new({required this.numeral, required this.title, required this.note});

  final String numeral;
  final String title;
  final String note;

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 22,
              child: Text(
                numeral,
                style: AuvieTypography.serif(
                  14,
                  italic: true,
                  color: palette.muted,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AuvieTypography.serif(15, color: palette.foreground),
                  ),
                  const SizedBox(height: 2),
                  Text(note, style: context.type.tag),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The plans as radio rows, the button and the terms.
class _Plans extends StatelessWidget {
  const new({
    required this.plans,
    required this.selected,
    required this.busy,
    required this.onSelect,
    required this.onPurchase,
  });

  final List<ProPlan> plans;
  final String selected;
  final bool busy;
  final ValueChanged<String> onSelect;
  final ValueChanged<ProPlan> onPurchase;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final plan = plans.firstWhere(
      (p) => p.id == selected,
      orElse: () => plans.first,
    );
    final yearly = plans.where((p) => p.period == ProPeriod.yearly).firstOrNull;
    final monthly = plans
        .where((p) => p.period == ProPeriod.monthly)
        .firstOrNull;
    final save = yearly == null || monthly == null
        ? null
        : savePercent(yearly: yearly, monthly: monthly);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final p in plans) ...[
          _PlanRow(
            plan: p,
            selected: p.id == plan.id,
            save: p.period == ProPeriod.yearly ? save : null,
            onTap: () => onSelect(p.id),
          ),
          const SizedBox(height: AuvieSpacing.s10),
        ],
        const SizedBox(height: AuvieSpacing.s6),
        FilledButton(
          key: const Key('pro-purchase'),
          onPressed: busy ? null : () => onPurchase(plan),
          child: Text(busy ? '…' : purchaseLabel(plan)),
        ),
        const SizedBox(height: AuvieSpacing.s8),
        Text(
          termsSentence(plan),
          key: const Key('pro-terms-sentence'),
          textAlign: TextAlign.center,
          style: context.type.body.copyWith(
            fontSize: 12,
            color: palette.mutedStrong,
          ),
        ),
      ],
    );
  }
}

class _PlanRow extends StatelessWidget {
  const new({
    required this.plan,
    required this.selected,
    required this.save,
    required this.onTap,
  });

  final ProPlan plan;
  final bool selected;
  final int? save;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        key: Key('plan-${plan.period.name}'),
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AuvieSpacing.s14,
            vertical: AuvieSpacing.s12,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? palette.foreground : palette.hairlineStrong,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: palette.foreground),
                ),
                child: selected
                    ? Center(
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: palette.foreground,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: AuvieSpacing.s14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          plan.period == ProPeriod.yearly
                              ? 'Yearly'
                              : 'Monthly',
                          style: AuvieTypography.serif(
                            17,
                            color: palette.foreground,
                          ),
                        ),
                        if (save != null) ...[
                          const SizedBox(width: AuvieSpacing.s8),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              border: Border.all(color: palette.accent),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 1,
                              ),
                              child: Text(
                                'SAVE $save%',
                                style: context.type.tag.copyWith(
                                  color: palette.accent,
                                  fontSize: 8.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(planNote(plan), style: context.type.tag),
                  ],
                ),
              ),
              Text(
                plan.price,
                style: AuvieTypography.serif(17, color: palette.foreground),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Already Pro: the plan, when it renews, and where to manage it.
class _Owned extends StatelessWidget {
  const new({
    required this.entitlement,
    required this.simulated,
    required this.onManage,
    required this.onReset,
  });

  final Entitlement entitlement;
  final bool simulated;
  final VoidCallback onManage;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final period = switch (entitlement.period) {
      ProPeriod.yearly => 'YEARLY',
      ProPeriod.monthly => 'MONTHLY',
      null => 'PRO',
    };
    final expires = entitlement.expiresAt;
    final when = expires == null
        ? null
        : entitlement.inTrial
        ? 'FREE UNTIL ${shortDate(expires)}'
        : 'RENEWS ${shortDate(expires)}';
    return Column(
      key: const Key('pro-owned'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EmphasisText(
          'You have *Pro.*',
          style: context.type.display.copyWith(fontSize: 26),
        ),
        const SizedBox(height: AuvieSpacing.s6),
        Text([period, ?when].join(' · '), style: context.type.tag),
        const SizedBox(height: AuvieSpacing.s18),
        OutlinedButton(
          key: const Key('pro-manage'),
          onPressed: onManage,
          child: const Text('MANAGE SUBSCRIPTION'),
        ),
        if (simulated) ...[
          const SizedBox(height: AuvieSpacing.s8),
          Center(
            child: CapsLink(
              'Back to free · simulated',
              key: const Key('pro-reset'),
              color: context.palette.mutedStrong,
              onTap: onReset,
            ),
          ),
        ],
      ],
    );
  }
}

/// No store in this build (or it didn't answer).
class _Unavailable extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: const Key('pro-unavailable'),
      padding: const EdgeInsets.symmetric(vertical: AuvieSpacing.s18),
      child: Text(
        "Pro isn't available yet. Every edit and export keeps working.",
        textAlign: TextAlign.center,
        style: context.type.body,
      ),
    );
  }
}

/// "12 OCT 2027".
String shortDate(DateTime date) {
  const months = [
    'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', //
    'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
  ];
  final local = date.toLocal();
  return '${local.day} ${months[local.month - 1]} ${local.year}';
}
