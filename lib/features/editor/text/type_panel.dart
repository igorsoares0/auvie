import 'package:auvie/app/theme/app_theme.dart';
import 'package:auvie/app/theme/spacing.dart';
import 'package:auvie/core/models/elements.dart';
import 'package:auvie/features/editor/elements/text_presets.dart';
import 'package:auvie/features/editor/elements/text_renderer.dart';
import 'package:auvie/features/editor/photo/editor_session.dart';
import 'package:auvie/features/editor/photo/photo_editor_controller.dart';
import 'package:auvie/features/editor/shell/panel_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// TYPE (handoff 04): SET TYPE / TEXT BRUSH, typeface specimens, SIZE, INK,
/// and the STYLE row (align, shadow, outline, fill, opacity).
class TypePanel extends ConsumerWidget {
  const new({required this.projectId, super.key});

  final String projectId;

  /// SIZE shows the font size on a 0–100 scale (25 ≈ the handoff's value).
  static String sizeLabel(double fontSize) => '${(fontSize * 400).round()}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = photoEditorProvider(projectId);
    final session = ref.watch(provider).requireValue;
    final controller = ref.read(provider.notifier);
    final selected = session.selected;
    final (style, presetId, opacity) = switch (selected) {
      TextElement e => (e.style, e.textPresetId, e.opacity),
      TextPathElement e => (e.style, null, e.opacity),
      _ => (
        session.textPreset.style.copyWith(color: session.textColor),
        session.textPreset.name,
        1.0,
      ),
    };
    final hasText = selected is TextElement || selected is TextPathElement;

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
              keyPrefix: 'type-mode',
              options: const [
                (TypeMode.setType, 'Set type'),
                (TypeMode.textBrush, 'Text brush'),
              ],
              selected: session.typeMode,
              onSelect: controller.setTypeMode,
            ),
          ),
          const SizedBox(height: AuvieSpacing.s12),
          SizedBox(
            height: 66,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AuvieSpacing.gutter,
              ),
              children: [
                for (final preset in TextPreset.values)
                  SpecimenCard(
                    key: Key('preset-text-${preset.name}'),
                    label: preset.label,
                    selected: presetId == preset.name,
                    sample: Text(
                      preset.style.uppercase ? 'AA' : 'Aa',
                      style: TextRenderer.textStyle(
                        preset.style.copyWith(
                          color: context.palette.foreground.toARGB32(),
                        ),
                        const Size(320, 320),
                      ),
                      maxLines: 1,
                    ),
                    onTap: () =>
                        controller.styleText(preset.apply, preset: preset),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AuvieSpacing.gutter,
              AuvieSpacing.s10,
              AuvieSpacing.gutter,
              0,
            ),
            child: Column(
              children: [
                LabeledSlider(
                  label: 'Size',
                  sliderKey: const Key('text-size'),
                  value: style.fontSize,
                  min: 0.02,
                  max: 0.16,
                  display: sizeLabel(style.fontSize),
                  onChanged: hasText
                      ? (v) => controller.previewTextStyle(
                          (s) => s.copyWith(fontSize: v),
                        )
                      : null,
                  onChangeEnd: (_) => controller.commit(),
                ),
                InkSwatches(
                  colors: inkColors,
                  selected: style.color,
                  onSelect: (c) => controller.styleText(
                    (s) => s.copyWith(color: c),
                    color: c,
                  ),
                ),
                const SizedBox(height: AuvieSpacing.s6),
                if (hasText)
                  _StyleRow(
                    style: style,
                    opacity: opacity,
                    onStyle: controller.styleText,
                    onOpacity: controller.setSelectedOpacity,
                  )
                else
                  SizedBox(
                    height: 30,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        session.typeMode == TypeMode.setType
                            ? 'TAP THE PHOTO TO ADD TEXT'
                            : 'DRAW A LINE ON THE PHOTO',
                        key: const Key('type-hint'),
                        style: context.type.tag,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StyleRow extends StatelessWidget {
  const new({
    required this.style,
    required this.opacity,
    required this.onStyle,
    required this.onOpacity,
  });

  final TextStyleSpec style;
  final double opacity;
  final ValueChanged<TextStyleSpec Function(TextStyleSpec)> onStyle;
  final ValueChanged<double> onOpacity;

  static const _opacities = [1.0, 0.75, 0.5, 0.25];

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    Widget option(
      String key,
      String label, {
      required bool on,
      required VoidCallback onTap,
    }) => GestureDetector(
      key: Key('text-style-$key'),
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        height: 30,
        child: Center(
          child: Text(
            label,
            style: context.type.label.copyWith(
              fontSize: 10,
              color: on ? palette.foreground : palette.muted,
            ),
          ),
        ),
      ),
    );

    final align = switch (style.align) {
      TextAlignment.left => 'LEFT',
      TextAlignment.center => 'CENTER',
      TextAlignment.right => 'RIGHT',
    };
    final next = TextAlignment
        .values[(style.align.index + 1) % TextAlignment.values.length];
    final lightInk = Color(style.color).computeLuminance() > 0.5;
    final nextOpacity =
        _opacities[(_opacities.indexOf(
                  _opacities.reduce(
                    (a, b) => (a - opacity).abs() < (b - opacity).abs() ? a : b,
                  ),
                ) +
                1) %
            _opacities.length];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        option(
          'align',
          align,
          on: true,
          onTap: () => onStyle((s) => s.copyWith(align: next)),
        ),
        option(
          'shadow',
          'SHADOW',
          on: style.shadow != null,
          onTap: () => onStyle(
            (s) => s.copyWith(
              shadow: s.shadow == null ? const TextShadowSpec() : null,
            ),
          ),
        ),
        option(
          'outline',
          'OUTLINE',
          on: style.outline != null,
          onTap: () => onStyle(
            (s) => s.copyWith(
              outline: s.outline == null
                  ? TextOutlineSpec(color: lightInk ? 0xFF0B0A09 : 0xFFF6F0E6)
                  : null,
            ),
          ),
        ),
        option(
          'fill',
          'FILL',
          on: style.background != null,
          onTap: () => onStyle(
            (s) => s.copyWith(
              background: s.background == null
                  ? TextBackgroundSpec(
                      color: lightInk ? 0xFF0B0A09 : 0xFFF6F0E6,
                    )
                  : null,
            ),
          ),
        ),
        option(
          'opacity',
          '${(opacity * 100).round()}%',
          on: opacity < 1,
          onTap: () => onOpacity(nextOpacity),
        ),
      ],
    );
  }
}
