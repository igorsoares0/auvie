import 'package:auvie/app/theme/app_theme.dart';
import 'package:auvie/app/theme/spacing.dart';
import 'package:auvie/app/theme/typography.dart';
import 'package:auvie/app/widgets/auvie_icon.dart';
import 'package:auvie/core/models/adjustment.dart';
import 'package:auvie/features/editor/adjustments/adjustment_family.dart';
import 'package:auvie/features/editor/adjustments/curve_editor.dart';
import 'package:auvie/features/editor/adjustments/lens_ruler.dart';
import 'package:auvie/features/editor/adjustments/ruler_scale.dart';
import 'package:auvie/features/editor/crop/crop_controls.dart';
import 'package:auvie/features/editor/shell/editor_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ADJUST: one parameter at a time on a ruler; its family's parameters are
/// named above it, and the families row switches groups.
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ParameterTabs(
            adjustments: adjustments,
            active: session.parameter,
            isEdited: (a) => edit.adjustments[a] != 0,
            onSelect: controller.selectParameter,
          ),
          GestureDetector(
            key: const Key('parameter-header'),
            behavior: HitTestBehavior.opaque,
            onHorizontalDragEnd: (d) {
              final v = d.primaryVelocity ?? 0;
              if (v.abs() > 100) controller.stepParameter(v < 0 ? 1 : -1);
            },
            child: SizedBox(
              height: 28,
              width: double.infinity,
              child: Center(
                child: Text(
                  adjustment.format(value),
                  key: const Key('parameter-value'),
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

/// Every parameter of the family by name: tap one to edit it. The active
/// one is underlined; an accent dot marks those already changed.
class _ParameterTabs extends StatefulWidget {
  const new({
    required this.adjustments,
    required this.active,
    required this.isEdited,
    required this.onSelect,
  });

  final List<Adjustment> adjustments;
  final int active;
  final bool Function(Adjustment) isEdited;
  final ValueChanged<int> onSelect;

  @override
  State<_ParameterTabs> createState() => _ParameterTabsState();
}

class _ParameterTabsState extends State<_ParameterTabs> {
  final _keys = <Adjustment, GlobalKey>{};

  GlobalKey _keyOf(Adjustment adjustment) =>
      _keys.putIfAbsent(adjustment, GlobalKey.new);

  @override
  void didUpdateWidget(_ParameterTabs old) {
    super.didUpdateWidget(old);
    if (old.active == widget.active && old.adjustments == widget.adjustments) {
      return;
    }
    // Keeps the active name in view, also when it was swiped to.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = _keyOf(widget.adjustments[widget.active]).currentContext;
      if (target == null || !target.mounted) return;
      Scrollable.ensureVisible(
        target,
        alignment: 0.5,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return SizedBox(
      height: AuvieSpacing.minHitTarget - 4,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AuvieSpacing.gutter),
        child: Row(
          children: [
            for (final (i, adjustment) in widget.adjustments.indexed)
              _ParameterTab(
                key: _keyOf(adjustment),
                tabKey: Key('parameter-${adjustment.name}'),
                label: adjustment.label.toUpperCase(),
                active: i == widget.active,
                edited: widget.isEdited(adjustment),
                color: i == widget.active ? palette.foreground : palette.muted,
                accent: palette.accent,
                onTap: () => widget.onSelect(i),
              ),
          ],
        ),
      ),
    );
  }
}

class _ParameterTab extends StatelessWidget {
  const new({
    required this.tabKey,
    required this.label,
    required this.active,
    required this.edited,
    required this.color,
    required this.accent,
    required this.onTap,
    super.key,
  });

  final Key tabKey;
  final String label;
  final bool active;
  final bool edited;
  final Color color;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: active,
      child: GestureDetector(
        key: tabKey,
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(right: AuvieSpacing.s14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: context.type.tag.copyWith(
                      fontSize: 10.5,
                      color: color,
                    ),
                  ),
                  if (edited) ...[
                    const SizedBox(width: 4),
                    Container(
                      key: Key('$label-edited'),
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 5),
              Container(
                height: 1,
                width: 28,
                color: active ? color : Colors.transparent,
              ),
            ],
          ),
        ),
      ),
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
