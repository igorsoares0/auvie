import 'package:auvie/app/theme/app_theme.dart';
import 'package:auvie/app/theme/spacing.dart';
import 'package:auvie/app/theme/typography.dart';
import 'package:flutter/material.dart';

/// Two or three equal options with a filled selection (SET TYPE / TEXT
/// BRUSH in handoff 04).
class SegmentedToggle<T> extends StatelessWidget {
  const new({
    required this.options,
    required this.selected,
    required this.onSelect,
    this.keyPrefix = 'toggle',
    super.key,
  });

  final List<(T, String)> options;
  final T selected;
  final ValueChanged<T> onSelect;
  final String keyPrefix;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      height: 36,
      decoration: BoxDecoration(
        border: Border.all(color: palette.hairlineStrong),
      ),
      child: Row(
        children: [
          for (final (value, label) in options)
            Expanded(
              child: Semantics(
                button: true,
                selected: value == selected,
                child: GestureDetector(
                  key: Key('$keyPrefix-$label'),
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onSelect(value),
                  child: ColoredBox(
                    color: value == selected
                        ? palette.foreground
                        : Colors.transparent,
                    child: Center(
                      child: Text(
                        label.toUpperCase(),
                        style: context.type.label.copyWith(
                          fontSize: 10.5,
                          color: value == selected
                              ? palette.background
                              : palette.muted,
                        ),
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

/// An 88×66 specimen card: a sample on top, a caps label below.
class SpecimenCard extends StatelessWidget {
  const new({
    required this.label,
    required this.sample,
    required this.selected,
    required this.onTap,
    this.premium = false,
    super.key,
  });

  final String label;
  final Widget sample;
  final bool selected;
  final bool premium;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.only(right: AuvieSpacing.s10),
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Container(
            width: 88,
            height: 66,
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              border: Border.all(
                color: selected ? palette.foreground : palette.hairlineStrong,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: sample),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        label.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                        softWrap: false,
                        style: context.type.tag.copyWith(
                          fontSize: 10,
                          letterSpacing: 0.8,
                          color: selected ? palette.foreground : palette.muted,
                        ),
                      ),
                    ),
                    if (premium)
                      Text(
                        '·',
                        style: context.type.tag.copyWith(color: palette.accent),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// SIZE / OPACITY rows: caps label, slider, value.
class LabeledSlider extends StatelessWidget {
  const new({
    required this.label,
    required this.value,
    required this.display,
    required this.onChanged,
    this.min = 0,
    this.max = 1,
    this.onChangeEnd,
    this.sliderKey,
    super.key,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final String display;
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeEnd;
  final Key? sliderKey;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: Row(
        children: [
          SizedBox(
            width: 62,
            child: Text(
              label.toUpperCase(),
              style: context.type.label.copyWith(fontSize: 10),
            ),
          ),
          Expanded(
            child: Slider(
              key: sliderKey,
              value: value.clamp(min, max),
              min: min,
              max: max,
              onChanged: onChanged,
              onChangeEnd: onChangeEnd,
              padding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(width: AuvieSpacing.s12),
          SizedBox(
            width: 34,
            child: Text(
              display,
              textAlign: TextAlign.right,
              style: AuvieTypography.serif(
                15,
                color: context.palette.foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// INK swatches: 22 pt squares in 40 pt hit areas, the chosen one outlined.
class InkSwatches extends StatelessWidget {
  const new({
    required this.colors,
    required this.selected,
    required this.onSelect,
    super.key,
  });

  final List<int> colors;
  final int? selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          SizedBox(
            width: 62,
            child: Text(
              'INK',
              style: context.type.label.copyWith(fontSize: 10),
            ),
          ),
          for (final color in colors)
            Semantics(
              button: true,
              selected: color == selected,
              child: GestureDetector(
                key: Key('ink-${color.toRadixString(16)}'),
                behavior: HitTestBehavior.opaque,
                onTap: () => onSelect(color),
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Center(
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: Color(color),
                        border: Border.all(
                          color: color == selected
                              ? palette.foreground
                              : palette.hairlineStrong,
                        ),
                      ),
                      foregroundDecoration: color == selected
                          ? BoxDecoration(
                              border: Border.all(
                                color: palette.background,
                                width: 2,
                              ),
                            )
                          : null,
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
