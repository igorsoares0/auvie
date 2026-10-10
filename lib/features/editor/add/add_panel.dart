import 'package:auvie/app/theme/app_theme.dart';
import 'package:auvie/app/theme/colors.dart';
import 'package:auvie/app/theme/spacing.dart';
import 'package:auvie/core/content/catalog.dart';
import 'package:auvie/core/content/catalog_providers.dart';
import 'package:auvie/core/models/elements.dart';
import 'package:auvie/features/editor/elements/frame_renderer.dart';
import 'package:auvie/features/editor/elements/overlay_renderer.dart';
import 'package:auvie/features/editor/shell/editor_controller.dart';
import 'package:auvie/features/editor/shell/editor_session.dart';
import 'package:auvie/features/editor/shell/panel_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Blend named in an overlay's catalog params.
OverlayBlend overlayBlendFrom(Object? name) =>
    OverlayBlend.values
        .where(
          (b) =>
              b.name == name ||
              (name == 'soft-light' && b == OverlayBlend.softLight),
        )
        .firstOrNull ??
    OverlayBlend.screen;

/// ADD: stickers, overlays and frames from the catalog.
class AddPanel extends ConsumerWidget {
  const new({required this.projectId, super.key});

  final String projectId;

  static const List<OverlayBlend> _blends = [
    OverlayBlend.screen,
    OverlayBlend.softLight,
    OverlayBlend.overlay,
    OverlayBlend.multiply,
    OverlayBlend.normal,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = editorControllerProvider(projectId);
    final session = ref.watch(provider).requireValue;
    final controller = ref.read(provider.notifier);
    final catalog = ref.watch(catalogProvider).value;
    if (catalog == null) return const SizedBox.shrink();

    final type = switch (session.addTab) {
      AddTab.stickers => ContentAssetType.sticker,
      AddTab.overlays => ContentAssetType.overlay,
      AddTab.frames => ContentAssetType.frame,
    };
    final elements = session.edit.elements;
    final overlays = elements.whereType<OverlayElement>().toList();
    final frames = elements
        .whereType<FrameElement>()
        .map((f) => f.assetId)
        .toSet();
    final active = {...overlays.map((o) => o.assetId), ...frames};
    final lastOverlay = overlays.lastOrNull;

    return Padding(
      padding: const EdgeInsets.only(top: AuvieSpacing.s12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AuvieSpacing.gutter,
            ),
            child: SegmentedToggle(
              keyPrefix: 'add-tab',
              options: const [
                (AddTab.stickers, 'Stickers'),
                (AddTab.overlays, 'Overlays'),
                (AddTab.frames, 'Frames'),
              ],
              selected: session.addTab,
              onSelect: controller.setAddTab,
            ),
          ),
          const SizedBox(height: AuvieSpacing.s14),
          SizedBox(
            height: 92,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AuvieSpacing.gutter,
              ),
              children: [
                for (final asset in catalog.assetsOfType(type))
                  _AssetCard(
                    asset: asset,
                    active: active.contains(asset.id),
                    onTap: () => switch (asset.type) {
                      ContentAssetType.sticker => controller.addSticker(
                        asset.id,
                      ),
                      ContentAssetType.overlay => controller.toggleOverlay(
                        asset.id,
                        blend: overlayBlendFrom(asset.params['blend']),
                        opacity:
                            (asset.params['opacity'] as num?)?.toDouble() ?? 1,
                      ),
                      ContentAssetType.frame => controller.toggleFrame(
                        asset.id,
                      ),
                      ContentAssetType.font => null,
                    },
                  ),
              ],
            ),
          ),
          if (session.addTab == AddTab.overlays && lastOverlay != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AuvieSpacing.gutter,
                AuvieSpacing.s8,
                AuvieSpacing.gutter,
                0,
              ),
              child: Column(
                children: [
                  LabeledSlider(
                    label: 'Opacity',
                    sliderKey: const Key('overlay-opacity'),
                    value: lastOverlay.opacity,
                    display: '${(lastOverlay.opacity * 100).round()}',
                    onChanged: (v) =>
                        controller.setOverlayOpacity(lastOverlay.id, v),
                    onChangeEnd: (_) => controller.commit(),
                  ),
                  SizedBox(
                    height: 30,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 62,
                          child: Text(
                            'BLEND',
                            style: context.type.label.copyWith(fontSize: 10),
                          ),
                        ),
                        GestureDetector(
                          key: const Key('overlay-blend'),
                          behavior: HitTestBehavior.opaque,
                          onTap: () => controller.setOverlayBlend(
                            lastOverlay.id,
                            _blends[(_blends.indexOf(lastOverlay.blend) + 1) %
                                _blends.length],
                          ),
                          child: Text(
                            _blendLabel(lastOverlay.blend),
                            style: context.type.label.copyWith(
                              fontSize: 10,
                              color: context.palette.foreground,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  static String _blendLabel(OverlayBlend b) => switch (b) {
    OverlayBlend.screen => 'SCREEN',
    OverlayBlend.softLight => 'SOFT LIGHT',
    OverlayBlend.overlay => 'OVERLAY',
    OverlayBlend.multiply => 'MULTIPLY',
    OverlayBlend.normal => 'NORMAL',
  };
}

class _AssetCard extends StatelessWidget {
  const new({required this.asset, required this.active, required this.onTap});

  final ContentAsset asset;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final preview = switch (asset.type) {
      ContentAssetType.sticker => Padding(
        padding: const EdgeInsets.all(12),
        child: SvgPicture.asset(
          asset.file,
          theme: SvgTheme(currentColor: palette.foreground),
        ),
      ),
      ContentAssetType.overlay => ColoredBox(
        color: const Color(0xFF3D3832),
        child: CustomPaint(
          painter: _Generated(
            (canvas, size) => OverlayRenderer.paint(
              canvas,
              size,
              asset.params,
              seed: asset.id,
            ),
          ),
        ),
      ),
      ContentAssetType.frame => ColoredBox(
        color: const Color(0xFF6F665C),
        child: CustomPaint(
          painter: _Generated(
            (canvas, size) => FrameRenderer.paint(canvas, size, asset.params),
          ),
        ),
      ),
      ContentAssetType.font => const SizedBox.shrink(),
    };
    return Padding(
      padding: const EdgeInsets.only(right: AuvieSpacing.s10),
      child: Semantics(
        button: true,
        selected: active,
        label: asset.name,
        child: GestureDetector(
          key: Key('asset-${asset.id}'),
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: SizedBox(
            width: 66,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: active
                          ? palette.foreground
                          : palette.hairlineStrong,
                    ),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRect(child: preview),
                      if (asset.isPremium)
                        Positioned(
                          right: 3,
                          top: 3,
                          child: ColoredBox(
                            color: const Color(0xBF161412),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 3,
                                vertical: 1,
                              ),
                              child: Text(
                                'ATELIER',
                                style: context.type.tag.copyWith(
                                  fontSize: 7.5,
                                  color: AuvieColors.bone,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  asset.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.type.tag.copyWith(
                    fontSize: 10,
                    letterSpacing: 0.8,
                    color: active ? palette.foreground : palette.muted,
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

class _Generated extends CustomPainter {
  new(this.draw);

  final void Function(Canvas, Size) draw;

  @override
  void paint(Canvas canvas, Size size) => draw(canvas, size);

  @override
  bool shouldRepaint(_Generated old) => false;
}
