import 'package:auvie/app/theme/app_theme.dart';
import 'package:auvie/app/theme/spacing.dart';
import 'package:auvie/app/theme/typography.dart';
import 'package:auvie/core/models/color_mix.dart';
import 'package:auvie/features/editor/adjustments/lens_ruler.dart';
import 'package:auvie/features/editor/adjustments/ruler_scale.dart';
import 'package:auvie/features/editor/shell/editor_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// HSL: pick a color range by its swatch, then HUE / SATURATION /
/// LUMINANCE on the ruler, like the other adjustments. A dot under a swatch
/// marks the ranges already changed.
class ColorMixControls extends ConsumerWidget {
  const new({required this.projectId, super.key});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = editorControllerProvider(projectId);
    final session = ref.watch(provider).requireValue;
    final controller = ref.read(provider.notifier);
    final edit = session.edit;
    final mix = edit.colorMix;
    final band = session.colorBand;
    final channel = ColorChannel
        .values[session.parameter.clamp(0, ColorChannel.values.length - 1)];
    final value = mix(band, channel);

    void select(int delta) {
      final next = (channel.index + delta).clamp(
        0,
        ColorChannel.values.length - 1,
      );
      controller.selectParameter(next);
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _Swatches(
          active: band,
          isEdited: mix.isEdited,
          onSelect: controller.selectColorBand,
        ),
        const SizedBox(height: AuvieSpacing.s6),
        _ChannelTabs(
          active: channel,
          isEdited: (c) => mix(band, c) != 0,
          onSelect: (c) => controller.selectParameter(c.index),
        ),
        GestureDetector(
          key: const Key('hsl-header'),
          behavior: HitTestBehavior.opaque,
          onHorizontalDragEnd: (d) {
            final v = d.primaryVelocity ?? 0;
            if (v.abs() > 100) select(v < 0 ? 1 : -1);
          },
          child: SizedBox(
            height: 28,
            width: double.infinity,
            child: Center(
              child: Text(
                formatColorMixValue(value),
                key: const Key('hsl-value'),
                style: AuvieTypography.serif(
                  24,
                  height: 1,
                  color: value == 0
                      ? context.palette.foreground2
                      : context.palette.accent,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AuvieSpacing.gutter,
            AuvieSpacing.s6,
            AuvieSpacing.gutter,
            0,
          ),
          child: LensRuler(
            key: ValueKey(('hsl-ruler', band, channel)),
            scale: RulerScale.bipolar,
            labels: const ['−1.0', '0', '+1.0'],
            value: value,
            onPreview: (v) => controller.preview(
              edit.copyWith(colorMix: mix.withValue(band, channel, v)),
            ),
            onCommit: controller.commit,
            onReset: () => controller.record(
              edit.copyWith(colorMix: mix.withValue(band, channel, 0)),
            ),
          ),
        ),
      ],
    );
  }
}

/// "+0.20", "−0.34", "0.00".
String formatColorMixValue(double value) {
  final text = value.abs().toStringAsFixed(2);
  if (value.abs() < 0.005) return text;
  return value < 0 ? '−$text' : '+$text';
}

extension ColorBandLabel on ColorBand {
  /// "Red", "Aqua"…
  String get label => name[0].toUpperCase() + name.substring(1);
}

class _Swatches extends StatelessWidget {
  const new({
    required this.active,
    required this.isEdited,
    required this.onSelect,
  });

  final ColorBand active;
  final bool Function(ColorBand) isEdited;
  final ValueChanged<ColorBand> onSelect;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AuvieSpacing.gutter),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (final band in ColorBand.values)
            Semantics(
              button: true,
              selected: band == active,
              label: band.label,
              child: GestureDetector(
                key: Key('hsl-band-${band.name}'),
                behavior: HitTestBehavior.opaque,
                onTap: () => onSelect(band),
                child: SizedBox(
                  width: 36,
                  height: AuvieSpacing.minHitTarget,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: band == active
                                ? palette.foreground
                                : Colors.transparent,
                          ),
                        ),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(band.swatch),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        key: isEdited(band)
                            ? Key('hsl-band-${band.name}-edited')
                            : null,
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isEdited(band)
                              ? palette.accent
                              : Colors.transparent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ChannelTabs extends StatelessWidget {
  const new({
    required this.active,
    required this.isEdited,
    required this.onSelect,
  });

  final ColorChannel active;
  final bool Function(ColorChannel) isEdited;
  final ValueChanged<ColorChannel> onSelect;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return SizedBox(
      height: AuvieSpacing.minHitTarget - 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final channel in ColorChannel.values)
            Semantics(
              button: true,
              selected: channel == active,
              child: GestureDetector(
                key: Key('hsl-channel-${channel.name}'),
                behavior: HitTestBehavior.opaque,
                onTap: () => onSelect(channel),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AuvieSpacing.s8,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            channel.name.toUpperCase(),
                            style: context.type.tag.copyWith(
                              fontSize: 10.5,
                              color: channel == active
                                  ? palette.foreground
                                  : palette.muted,
                            ),
                          ),
                          if (isEdited(channel)) ...[
                            const SizedBox(width: 4),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: palette.accent,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 5),
                      Container(
                        height: 1,
                        width: 28,
                        color: channel == active
                            ? palette.foreground
                            : Colors.transparent,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
