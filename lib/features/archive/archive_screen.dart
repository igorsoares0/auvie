import 'dart:async';

import 'package:auvie/app/theme/app_theme.dart';
import 'package:auvie/app/theme/colors.dart';
import 'package:auvie/app/theme/spacing.dart';
import 'package:auvie/app/theme/typography.dart';
import 'package:auvie/app/widgets/auvie_icon.dart';
import 'package:auvie/app/widgets/caps_link.dart';
import 'package:auvie/app/widgets/film_art.dart';
import 'package:auvie/app/widgets/system_bars.dart';
import 'package:auvie/core/content/catalog.dart';
import 'package:auvie/core/content/catalog_providers.dart';
import 'package:auvie/core/models/preset.dart';
import 'package:auvie/core/models/project.dart';
import 'package:auvie/core/storage/database.dart';
import 'package:auvie/core/storage/storage_providers.dart';
import 'package:auvie/core/subscription/entitlement_providers.dart';
import 'package:auvie/core/telemetry/telemetry.dart';
import 'package:auvie/features/editor/presets/preset_providers.dart';
import 'package:auvie/features/projects/start_project.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The Archive (handoff 06, paper): this edition's featured collection,
/// then every film by collection. Tap a film to start a photo with it
/// (Pro films too: they preview freely, the paywall comes at export); hold
/// it to keep it in SAVED.
class ArchiveScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends ConsumerState<ArchiveScreen> {
  final _sections = <String, GlobalKey>{};
  bool _starting = false;

  GlobalKey _section(String id) => _sections.putIfAbsent(id, GlobalKey.new);

  Future<void> _start(Preset preset) async {
    if (_starting) return;
    _starting = true;
    try {
      ref.read(telemetryProvider).event(TelemetryEvent.presetApplied, {
        'preset': preset.id,
        'source': 'archive',
      });
      await startProject(context, ref, MediaType.photo, preset: preset);
    } finally {
      _starting = false;
    }
  }

  void _toggle(FavoriteKind kind, String id) {
    unawaited(HapticFeedback.mediumImpact());
    unawaited(ref.read(favoritesRepositoryProvider).toggle(kind, id));
  }

  void _show(String collectionId) {
    final target = _section(collectionId).currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(
      target,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(catalogProvider).value;
    final pro = ref.watch(proAccessProvider).isPro;
    final savedPresets = (ref.watch(favoritePresetsProvider).value ?? const [])
        .toSet();
    final savedCollections =
        (ref.watch(favoriteCollectionsProvider).value ?? const []).toSet();
    final palette = context.palette;

    if (catalog == null) {
      return const SystemBars(child: Scaffold(body: SizedBox.shrink()));
    }
    final collections = catalog.sortedCollections;
    final featured = catalog.featuredCollection;
    final edition = catalog.edition;

    return SystemBars(
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AuvieSpacing.gutter,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: AuvieSpacing.headerHeight,
                  child: Row(
                    children: [
                      Semantics(
                        button: true,
                        label: 'Home',
                        child: GestureDetector(
                          key: const Key('archive-back'),
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
                      const Spacer(),
                      Text(
                        '${collections.length} COLLECTIONS',
                        style: context.type.tag,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AuvieSpacing.s6),
                Text(
                  [
                    if (edition != null) ...[
                      'EDITION Nº ${edition.number}',
                      edition.season.toUpperCase(),
                    ],
                    'AVAILABLE OFFLINE',
                  ].join(' · '),
                  key: const Key('archive-edition'),
                  style: context.type.tag,
                ),
                const SizedBox(height: AuvieSpacing.s6),
                Text(
                  'The Archive',
                  style: context.type.display.copyWith(fontSize: 42),
                ),
                const SizedBox(height: AuvieSpacing.s18),
                if (featured != null)
                  _Featured(
                    collection: featured,
                    tone: _toneOf(catalog, featured.id),
                    onTap: () => _show(featured.id),
                  ),
                for (final collection in collections) ...[
                  const SizedBox(height: AuvieSpacing.s28),
                  _SectionHeader(
                    key: _section(collection.id),
                    collection: collection,
                    saved: savedCollections.contains(collection.id),
                    onSave: () =>
                        _toggle(FavoriteKind.collection, collection.id),
                  ),
                  for (final preset in catalog.presetsIn(collection.id))
                    _PresetRow(
                      preset: preset,
                      owned: pro || !preset.isPremium,
                      saved: savedPresets.contains(preset.id),
                      onTap: () => _start(preset),
                      onHold: () => _toggle(FavoriteKind.preset, preset.id),
                    ),
                ],
                const SizedBox(height: AuvieSpacing.s34),
                Text(
                  'Hold a film to keep it in SAVED.',
                  textAlign: TextAlign.center,
                  style: AuvieTypography.serif(
                    14,
                    italic: true,
                    color: palette.muted,
                  ),
                ),
                const SizedBox(height: AuvieSpacing.s22),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static ToneStrip _toneOf(Catalog catalog, String collectionId) =>
      catalog.presetsIn(collectionId).firstOrNull?.tone ?? FilmArt.nocturne;
}

/// "THIS WEEK" and the collection's name over its art, 176 pt.
class _Featured extends StatelessWidget {
  const new({
    required this.collection,
    required this.tone,
    required this.onTap,
  });

  final PresetCollection collection;
  final ToneStrip tone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'This week: ${collection.name}',
      child: GestureDetector(
        key: const Key('archive-featured'),
        onTap: onTap,
        child: SizedBox(
          height: 176,
          child: Stack(
            fit: StackFit.expand,
            children: [
              FilmArt(tone: tone, seed: 5),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.center,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x00161412), Color(0xCC161412)],
                  ),
                ),
              ),
              Positioned(
                left: AuvieSpacing.s14,
                right: AuvieSpacing.s14,
                bottom: AuvieSpacing.s12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'THIS WEEK',
                      style: context.type.tag.copyWith(color: AuvieColors.bone),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      collection.name,
                      style: AuvieTypography.serif(
                        26,
                        italic: true,
                        height: 1,
                        color: AuvieColors.bone,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const new({
    required this.collection,
    required this.saved,
    required this.onSave,
    super.key,
  });

  final PresetCollection collection;
  final bool saved;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: palette.hairlineStrong)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AuvieSpacing.s8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    collection.name,
                    style: AuvieTypography.serif(22, color: palette.foreground),
                  ),
                  if (collection.description case final description?)
                    Text(
                      description,
                      style: AuvieTypography.serif(
                        13,
                        italic: true,
                        color: palette.muted,
                      ),
                    ),
                ],
              ),
            ),
          ),
          CapsLink(
            saved ? 'Saved' : 'Save',
            key: Key('collection-save-${collection.id}'),
            color: saved ? palette.accent : palette.mutedStrong,
            onTap: onSave,
          ),
        ],
      ),
    );
  }
}

/// Tone strip, name, "STOCK · DESCRIPTION", OWNED / TRY.
class _PresetRow extends StatelessWidget {
  const new({
    required this.preset,
    required this.owned,
    required this.saved,
    required this.onTap,
    required this.onHold,
  });

  final Preset preset;
  final bool owned;
  final bool saved;
  final VoidCallback onTap;
  final VoidCallback onHold;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final tone = preset.tone ?? FilmArt.cendre;
    final details = [
      ?preset.author,
      ?preset.stock,
      ?preset.description,
    ].join(' · ').toUpperCase();
    return Semantics(
      button: true,
      label: preset.name,
      child: GestureDetector(
        key: Key('preset-row-${preset.id}'),
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        onLongPress: onHold,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: palette.hairline)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AuvieSpacing.s12),
            child: Row(
              children: [
                SizedBox(
                  width: 34,
                  height: 42,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final (color, flex) in [
                        (tone.highlight, 4),
                        (tone.mid, 4),
                        (tone.shadow, 2),
                      ])
                        Expanded(
                          flex: flex,
                          child: ColoredBox(color: Color(color)),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: AuvieSpacing.s14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              preset.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AuvieTypography.serif(
                                18,
                                color: palette.foreground,
                              ),
                            ),
                          ),
                          if (preset.isPremium) ...[
                            const SizedBox(width: AuvieSpacing.s8),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                border: Border.all(color: palette.foreground),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 1,
                                ),
                                child: Text(
                                  'ATELIER',
                                  style: context.type.tag.copyWith(
                                    fontSize: 7.5,
                                    color: palette.foreground,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        details,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.type.tag,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AuvieSpacing.s10),
                if (saved) ...[
                  Container(
                    key: Key('preset-saved-${preset.id}'),
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: palette.accent,
                    ),
                  ),
                  const SizedBox(width: AuvieSpacing.s8),
                ],
                Text(
                  owned ? 'OWNED' : 'TRY',
                  key: Key('preset-access-${preset.id}'),
                  style: context.type.tag.copyWith(
                    color: owned ? palette.muted : palette.foreground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
