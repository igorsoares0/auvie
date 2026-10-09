import 'package:auvie/app/theme/app_theme.dart';
import 'package:auvie/app/theme/spacing.dart';
import 'package:auvie/app/theme/typography.dart';
import 'package:auvie/app/widgets/auvie_icon.dart';
import 'package:auvie/app/widgets/caps_link.dart';
import 'package:auvie/core/models/crop.dart';
import 'package:auvie/features/editor/adjustments/lens_ruler.dart';
import 'package:auvie/features/editor/adjustments/ruler_scale.dart';
import 'package:auvie/features/editor/photo/photo_editor_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

extension CropAspectLabel on CropAspect {
  String get label => switch (this) {
    CropAspect.original => 'ORIGINAL',
    CropAspect.square => '1:1',
    CropAspect.portrait4x5 => '4:5',
    CropAspect.portrait3x4 => '3:4',
    CropAspect.story9x16 => '9:16',
    CropAspect.landscape16x9 => '16:9',
  };
}

/// CROP: aspect, straighten, rotate, flip and reset. The crop area itself
/// is dragged on the photo (CropOverlay).
class CropControls extends ConsumerWidget {
  const new({required this.projectId, super.key});

  final String projectId;

  static String degrees(double value) {
    final text = '${value.abs().toStringAsFixed(1)}°';
    if (value.abs() < 0.05) return '0.0°';
    return value < 0 ? '−$text' : '+$text';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = photoEditorProvider(projectId);
    final session = ref.watch(provider).requireValue;
    final controller = ref.read(provider.notifier);
    final edit = session.edit;
    final crop = edit.crop;
    final ratio = session.project.media.aspectRatio;
    final palette = context.palette;

    void record(CropTransform next) =>
        controller.record(edit.copyWith(crop: next));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AuvieSpacing.gutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AuvieSpacing.s14),
          SizedBox(
            height: 28,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (final aspect in CropAspect.values)
                  Semantics(
                    button: true,
                    selected: aspect == crop.aspect,
                    child: GestureDetector(
                      key: Key('aspect-${aspect.name}'),
                      behavior: HitTestBehavior.opaque,
                      onTap: () =>
                          record(crop.withAspect(aspect, mediaRatio: ratio)),
                      child: Center(
                        child: Text(
                          aspect.label,
                          style: context.type.label.copyWith(
                            fontSize: 10.5,
                            color: aspect == crop.aspect
                                ? palette.foreground
                                : palette.muted,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AuvieSpacing.s12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'Straighten',
                style: AuvieTypography.serif(
                  22,
                  italic: true,
                  color: palette.foreground,
                ),
              ),
              const Spacer(),
              Text(
                degrees(crop.straighten),
                key: const Key('straighten-value'),
                style: AuvieTypography.serif(
                  22,
                  color: crop.straighten == 0
                      ? palette.foreground2
                      : palette.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: AuvieSpacing.s8),
          LensRuler(
            scale: RulerScale.straighten,
            labels: const ['−45°', '0°', '+45°'],
            value: crop.straighten,
            onPreview: (v) => controller.preview(
              edit.copyWith(crop: crop.withStraighten(v, mediaRatio: ratio)),
            ),
            onCommit: controller.commit,
            onReset: () => record(crop.withStraighten(0, mediaRatio: ratio)),
          ),
          const SizedBox(height: AuvieSpacing.s8),
          Row(
            children: [
              _IconAction(
                key: const Key('crop-rotate'),
                icon: AuvieIcons.rotate,
                label: 'Rotate',
                onTap: () => record(crop.rotatedClockwise(mediaRatio: ratio)),
              ),
              const SizedBox(width: AuvieSpacing.s18),
              _IconAction(
                key: const Key('crop-flip'),
                icon: AuvieIcons.flip,
                label: 'Flip',
                onTap: () => record(crop.flippedHorizontally()),
              ),
              const Spacer(),
              CapsLink(
                'Reset',
                key: const Key('crop-reset'),
                color: crop.isIdentity ? palette.muted : palette.foreground,
                onTap: crop.isIdentity
                    ? null
                    : () => record(const CropTransform()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  const new({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
  });

  final AuvieIcons icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          height: AuvieSpacing.minHitTarget,
          child: Row(
            children: [
              AuvieIcon(icon, size: 20),
              const SizedBox(width: AuvieSpacing.s8),
              Text(
                label.toUpperCase(),
                style: context.type.label.copyWith(
                  color: context.palette.foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
