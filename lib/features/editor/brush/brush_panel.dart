import 'package:auvie/app/theme/app_theme.dart';
import 'package:auvie/app/theme/spacing.dart';
import 'package:auvie/core/models/elements.dart';
import 'package:auvie/features/editor/elements/brush_renderer.dart';
import 'package:auvie/features/editor/elements/text_presets.dart';
import 'package:auvie/features/editor/photo/photo_editor_controller.dart';
import 'package:auvie/features/editor/shell/panel_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

extension BrushTypeLabel on BrushType {
  String get label => name[0].toUpperCase() + name.substring(1);
}

/// BRUSH: draw freely on the photo with six brushes (spec §21).
class BrushPanel extends ConsumerWidget {
  const new({required this.projectId, super.key});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = photoEditorProvider(projectId);
    final brush = ref.watch(provider.select((s) => s.requireValue.brush));
    final controller = ref.read(provider.notifier);

    return Padding(
      padding: const EdgeInsets.only(top: AuvieSpacing.s14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 66,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AuvieSpacing.gutter,
              ),
              children: [
                for (final type in BrushType.values)
                  SpecimenCard(
                    key: Key('brush-${type.name}'),
                    label: type.label,
                    selected: brush.type == type,
                    sample: CustomPaint(
                      painter: _BrushSample(type, context.palette.foreground),
                      child: const SizedBox.expand(),
                    ),
                    onTap: () => controller.setBrush((
                      type: type,
                      size: brush.size,
                      color: brush.color,
                      opacity: brush.opacity,
                    )),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AuvieSpacing.gutter,
              AuvieSpacing.s14,
              AuvieSpacing.gutter,
              0,
            ),
            child: Column(
              children: [
                LabeledSlider(
                  label: 'Size',
                  sliderKey: const Key('brush-size'),
                  value: brush.size,
                  min: 0.002,
                  max: 0.03,
                  display: '${(brush.size * 1000).round()}',
                  onChanged: (v) => controller.setBrush((
                    type: brush.type,
                    size: v,
                    color: brush.color,
                    opacity: brush.opacity,
                  )),
                ),
                InkSwatches(
                  colors: inkColors,
                  selected: brush.color,
                  onSelect: (c) => controller.setBrush((
                    type: brush.type,
                    size: brush.size,
                    color: c,
                    opacity: brush.opacity,
                  )),
                ),
                LabeledSlider(
                  label: 'Opacity',
                  sliderKey: const Key('brush-opacity'),
                  value: brush.opacity,
                  min: 0.1,
                  display: '${(brush.opacity * 100).round()}',
                  onChanged: (v) => controller.setBrush((
                    type: brush.type,
                    size: brush.size,
                    color: brush.color,
                    opacity: v,
                  )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A short wave drawn with the brush, for its specimen card.
class _BrushSample extends CustomPainter {
  new(this.type, this.color);

  final BrushType type;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final points = [
      for (var i = 0; i <= 12; i++)
        Offset(
          size.width * (0.05 + 0.9 * i / 12),
          size.height * (0.55 + 0.25 * (i.isEven ? -1 : 1) * (i / 12)),
        ),
    ];
    BrushRenderer.paintStroke(
      canvas,
      type: type,
      points: points,
      pressure: List.filled(points.length, null),
      width: 2.2,
      color: color,
      seed: type.index,
    );
  }

  @override
  bool shouldRepaint(_BrushSample old) =>
      old.type != type || old.color != color;
}
