import 'dart:async';

import 'package:auvie/app/theme/app_theme.dart';
import 'package:auvie/app/theme/spacing.dart';
import 'package:auvie/app/theme/typography.dart';
import 'package:auvie/app/widgets/tone_strip_bar.dart';
import 'package:auvie/core/content/catalog.dart';
import 'package:auvie/core/content/catalog_providers.dart';
import 'package:auvie/core/models/preset.dart';
import 'package:auvie/core/storage/database.dart';
import 'package:auvie/core/storage/storage_providers.dart';
import 'package:auvie/features/editor/photo/editor_session.dart';
import 'package:auvie/features/editor/photo/photo_editor_controller.dart';
import 'package:auvie/features/editor/presets/preset_providers.dart';
import 'package:auvie/features/editor/shell/edit_caption.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// FILM: choose a preset by category and set its intensity.
/// Pro presets preview freely; the paywall only appears at export (M7).
class FilmPanel extends ConsumerWidget {
  const new({required this.projectId, super.key});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = photoEditorProvider(projectId);
    final session = ref.watch(provider).requireValue;
    final controller = ref.read(provider.notifier);
    final catalog = ref.watch(catalogProvider).value;
    final favorites = ref.watch(favoritePresetsProvider).value ?? const [];
    if (catalog == null) return const SizedBox.shrink();

    final category = session.category ?? savedCategory;
    final presets = category == savedCategory
        ? [for (final id in favorites) ?catalog.presetById(id)]
        : catalog.presetsIn(category);
    final ref_ = session.edit.preset;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AuvieSpacing.s12),
        _Categories(
          catalog: catalog,
          active: category,
          onSelect: controller.selectCategory,
        ),
        const SizedBox(height: AuvieSpacing.s12),
        SizedBox(
          height: 150,
          child: presets.isEmpty && category == savedCategory
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AuvieSpacing.gutter,
                  ),
                  child: Text(
                    'Hold a film to keep it here.',
                    style: AuvieTypography.serif(
                      15,
                      italic: true,
                      color: context.palette.foreground3,
                    ),
                  ),
                )
              : ListView(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AuvieSpacing.gutter,
                  ),
                  children: [
                    _PresetCard(
                      uri: session.project.media.uri,
                      preset: null,
                      selected: ref_ == null,
                      onTap: () =>
                          controller.record(session.edit.withoutPreset()),
                    ),
                    for (final preset in presets)
                      _PresetCard(
                        uri: session.project.media.uri,
                        preset: preset,
                        selected: ref_?.presetId == preset.id,
                        onTap: () => controller.record(
                          session.edit.withPreset(preset.id),
                        ),
                        onHold: () async {
                          unawaited(HapticFeedback.mediumImpact());
                          await ref
                              .read(favoritesRepositoryProvider)
                              .toggle(FavoriteKind.preset, preset.id);
                        },
                      ),
                  ],
                ),
        ),
        if (ref_ != null)
          _Intensity(
            value: ref_.intensity,
            onChanged: (v) =>
                controller.preview(session.edit.withPresetIntensity(v)),
            onChangeEnd: (_) => controller.commit(),
          ),
      ],
    );
  }
}

class _Categories extends StatelessWidget {
  const new({
    required this.catalog,
    required this.active,
    required this.onSelect,
  });

  final Catalog catalog;
  final String active;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final entries = [
      for (final c in catalog.sortedCollections) (c.id, c.name),
      (savedCategory, 'Saved'),
    ];
    return SizedBox(
      height: 28,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        children: [
          for (final (id, name) in entries)
            Semantics(
              button: true,
              selected: id == active,
              child: GestureDetector(
                key: Key('category-$id'),
                behavior: HitTestBehavior.opaque,
                onTap: () => onSelect(id),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Center(
                    child: Text(
                      name.toUpperCase(),
                      style: context.type.label.copyWith(
                        fontSize: 10.5,
                        color: id == active
                            ? palette.foreground
                            : palette.muted,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PresetCard extends ConsumerWidget {
  const new({
    required this.uri,
    required this.preset,
    required this.selected,
    required this.onTap,
    this.onHold,
  });

  final String uri;
  final Preset? preset;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onHold;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final image = ref.watch(presetThumbnailProvider(uri, preset?.id)).value;
    final name = preset == null ? 'Original' : presetBaseName(preset!.name);
    return Padding(
      padding: const EdgeInsets.only(right: AuvieSpacing.s14),
      child: Semantics(
        button: true,
        selected: selected,
        label: preset?.name ?? 'Original',
        child: GestureDetector(
          key: Key('preset-${preset?.id ?? 'original'}'),
          onTap: onTap,
          onLongPress: onHold,
          child: SizedBox(
            width: 72,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 90,
                  child: Stack(
                    clipBehavior: Clip.none,
                    fit: StackFit.expand,
                    children: [
                      if (image == null)
                        ColoredBox(color: palette.hairline)
                      else
                        Image.memory(
                          image,
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                        ),
                      if (preset?.isPremium ?? false)
                        Positioned(
                          right: 4,
                          top: 4,
                          child: ColoredBox(
                            color: const Color(0xBF161412),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 3,
                                vertical: 2,
                              ),
                              child: Text(
                                'ATELIER',
                                style: context.type.tag.copyWith(
                                  fontSize: 8.5,
                                  color: const Color(0xFFEFE8DC),
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (selected)
                        Positioned(
                          left: -4,
                          top: -4,
                          right: -4,
                          bottom: -4,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              border: Border.all(color: palette.foreground),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 7),
                ToneStripBar(tone: preset?.tone),
                const SizedBox(height: 7),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AuvieTypography.serif(
                    14,
                    height: 1.2,
                    color: selected ? palette.foreground : palette.foreground2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  presetMeta(preset),
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  softWrap: false,
                  style: context.type.tag.copyWith(
                    fontSize: 10,
                    letterSpacing: 0.8,
                    color: selected && preset != null
                        ? palette.accent
                        : palette.muted,
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

class _Intensity extends StatelessWidget {
  const new({
    required this.value,
    required this.onChanged,
    required this.onChangeEnd,
  });

  final double value;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AuvieSpacing.gutter,
        AuvieSpacing.s12,
        AuvieSpacing.gutter,
        0,
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'Intensity',
                style: AuvieTypography.serif(
                  22,
                  italic: true,
                  color: palette.foreground,
                ),
              ),
              const Spacer(),
              Text(
                '${(value * 100).round()}',
                key: const Key('intensity-value'),
                style: AuvieTypography.serif(22, color: palette.accent),
              ),
            ],
          ),
          SizedBox(
            height: 30,
            child: Slider(
              key: const Key('intensity-slider'),
              value: value,
              onChanged: onChanged,
              onChangeEnd: onChangeEnd,
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}
