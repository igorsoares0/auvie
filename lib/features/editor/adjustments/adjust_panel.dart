import 'package:auvie/app/theme/app_theme.dart';
import 'package:auvie/app/theme/spacing.dart';
import 'package:auvie/app/theme/typography.dart';
import 'package:auvie/app/widgets/auvie_icon.dart';
import 'package:auvie/features/editor/adjustments/adjustment_family.dart';
import 'package:auvie/features/editor/adjustments/curve_editor.dart';
import 'package:auvie/features/editor/adjustments/lens_ruler.dart';
import 'package:auvie/features/editor/adjustments/ruler_scale.dart';
import 'package:auvie/features/editor/crop/crop_controls.dart';
import 'package:auvie/features/editor/shell/editor_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ADJUST: one parameter at a time on a ruler; swipe the name to change it;
/// the families row switches groups.
class AdjustPanel extends ConsumerWidget {
  const new({required this.projectId, super.key});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = editorControllerProvider(projectId);
    final session = ref.watch(provider).requireValue;
    final controller = ref.read(provider.notifier);
    final edit = session.edit;
    final family = session.family;

    final Widget body;
    if (family == AdjustmentFamily.crop) {
      body = CropControls(projectId: projectId);
    } else if (family == AdjustmentFamily.curve) {
      body = CurveEditor(
        curves: edit.curves,
        onPreview: (c) => controller.preview(edit.copyWith(curves: c)),
        onCommit: controller.commit,
        onRecord: (c) => controller.record(edit.copyWith(curves: c)),
      );
    } else {
      final adjustments = family.adjustments;
      final adjustment = adjustments[session.parameter];
      final value = edit.adjustments[adjustment];
      body = Column(
        children: [
          GestureDetector(
            key: const Key('parameter-header'),
            behavior: HitTestBehavior.opaque,
            onHorizontalDragEnd: (d) {
              final v = d.primaryVelocity ?? 0;
              if (v.abs() > 100) controller.stepParameter(v < 0 ? 1 : -1);
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AuvieSpacing.gutter,
                AuvieSpacing.s18,
                AuvieSpacing.gutter,
                0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    adjustment.label,
                    key: const Key('parameter-name'),
                    style: context.type.parameterName,
                  ),
                  const SizedBox(width: AuvieSpacing.s10),
                  _PositionDots(
                    count: adjustments.length,
                    active: session.parameter,
                  ),
                  const Spacer(),
                  Text(
                    adjustment.format(value),
                    key: const Key('parameter-value'),
                    style: AuvieTypography.serif(
                      28,
                      height: 1,
                      color: value == 0
                          ? context.palette.foreground2
                          : context.palette.accent,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AuvieSpacing.gutter,
              AuvieSpacing.s12,
              AuvieSpacing.gutter,
              0,
            ),
            child: LensRuler(
              scale: RulerScale.forAdjustment(adjustment),
              labels: adjustment.rulerLabels,
              value: value,
              onPreview: (v) =>
                  controller.preview(edit.withAdjustment(adjustment, v)),
              onCommit: controller.commit,
              onReset: () =>
                  controller.record(edit.withAdjustment(adjustment, 0)),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Expanded(child: body),
        _Families(active: family, onSelect: controller.selectFamily),
        const SizedBox(height: AuvieSpacing.s12),
      ],
    );
  }
}

class _PositionDots extends StatelessWidget {
  const new({required this.count, required this.active});

  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < count; i++)
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: Container(
              width: i == active ? 5 : 4,
              height: i == active ? 5 : 4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i == active ? palette.foreground : null,
                border: i == active ? null : Border.all(color: palette.muted),
              ),
            ),
          ),
      ],
    );
  }
}

class _Families extends StatelessWidget {
  const new({required this.active, required this.onSelect});

  final AdjustmentFamily active;
  final ValueChanged<AdjustmentFamily> onSelect;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AuvieSpacing.gutter),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (final family in AdjustmentFamily.values)
            Semantics(
              button: true,
              selected: family == active,
              child: GestureDetector(
                key: Key('family-${family.name}'),
                behavior: HitTestBehavior.opaque,
                onTap: () => onSelect(family),
                child: Opacity(
                  opacity: 1,
                  child: SizedBox(
                    width: 52,
                    child: Column(
                      children: [
                        AuvieIcon(
                          family.icon,
                          size: 28,
                          color: family == active
                              ? palette.foreground
                              : palette.muted,
                        ),
                        const SizedBox(height: 9),
                        Text(
                          family.label,
                          style: context.type.tag.copyWith(
                            fontSize: 10,
                            color: family == active
                                ? palette.foreground
                                : palette.muted,
                          ),
                        ),
                      ],
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
