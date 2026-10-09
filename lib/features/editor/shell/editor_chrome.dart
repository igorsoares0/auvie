import 'package:auvie/app/theme/app_theme.dart';
import 'package:auvie/app/theme/spacing.dart';
import 'package:auvie/app/theme/typography.dart';
import 'package:auvie/app/widgets/auvie_icon.dart';
import 'package:auvie/app/widgets/caps_link.dart';
import 'package:auvie/features/editor/photo/editor_session.dart';
import 'package:flutter/material.dart';

/// CLOSE / "Roll 014 · 07" / EXPORT, or CANCEL / title / DONE while
/// typing (handoff 04).
class EditorHeader extends StatelessWidget {
  const new({
    required this.title,
    required VoidCallback onClose,
    required VoidCallback onExport,
    super.key,
  }) : _left = 'Close',
       _right = 'EXPORT',
       _onLeft = onClose,
       _onRight = onExport,
       _keys = const ('editor-close', 'editor-export');

  const new typing({
    required this.title,
    required VoidCallback onCancel,
    required VoidCallback onDone,
    super.key,
  }) : _left = 'Cancel',
       _right = 'DONE',
       _onLeft = onCancel,
       _onRight = onDone,
       _keys = const ('typing-cancel', 'typing-done');

  final String? title;
  final String _left;
  final String _right;
  final VoidCallback _onLeft;
  final VoidCallback _onRight;
  final (String, String) _keys;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final parts = (title ?? 'Untitled').split(' · ');
    final style = AuvieTypography.serif(
      15,
      letterSpacingEm: 0.04,
      color: palette.foreground,
    );
    return SizedBox(
      height: AuvieSpacing.headerHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AuvieSpacing.s12),
        child: Row(
          children: [
            CapsLink(
              _left,
              key: Key(_keys.$1),
              color: palette.mutedStrong,
              onTap: _onLeft,
            ),
            Expanded(
              child: Text.rich(
                TextSpan(
                  style: style,
                  children: [
                    TextSpan(text: parts.first),
                    if (parts.length > 1) ...[
                      TextSpan(
                        text: ' · ',
                        style: TextStyle(color: palette.muted),
                      ),
                      TextSpan(
                        text: parts.sublist(1).join(' · '),
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ],
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Semantics(
              button: true,
              child: GestureDetector(
                key: Key(_keys.$2),
                behavior: HitTestBehavior.opaque,
                onTap: _onRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(color: palette.foreground),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Text(_right, style: context.type.buttonLabel),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The state line under the photo, with undo / redo.
class EditorCaption extends StatelessWidget {
  const new({
    required this.caption,
    required this.canUndo,
    required this.canRedo,
    required this.onUndo,
    required this.onRedo,
    required this.showCompareHint,
    super.key,
  });

  final String caption;
  final bool canUndo;
  final bool canRedo;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final bool showCompareHint;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    Widget button(
      AuvieIcons icon,
      String label,
      VoidCallback f, {
      required bool enabled,
    }) {
      return Semantics(
        button: true,
        enabled: enabled,
        label: label,
        child: GestureDetector(
          key: Key('editor-$label'),
          behavior: HitTestBehavior.opaque,
          onTap: enabled ? f : null,
          child: SizedBox(
            width: AuvieSpacing.minHitTarget,
            height: AuvieSpacing.minHitTarget,
            child: Center(
              child: Opacity(
                opacity: enabled ? 1 : 0.35,
                child: AuvieIcon(icon, size: 19),
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left: AuvieSpacing.gutter, right: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              caption,
              key: const Key('editor-caption'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AuvieTypography.serif(
                15,
                italic: true,
                color: palette.foreground,
              ),
            ),
          ),
          button(AuvieIcons.undo, 'undo', onUndo, enabled: canUndo),
          button(AuvieIcons.redo, 'redo', onRedo, enabled: canRedo),
          if (showCompareHint) Text('HOLD TO COMPARE', style: context.type.tag),
        ],
      ),
    );
  }
}

/// FILM / ADJUST / TYPE / BRUSH / ADD.
class EditorToolbar extends StatelessWidget {
  const new({required this.active, required this.onSelect, super.key});

  final EditorTool active;
  final ValueChanged<EditorTool> onSelect;

  static const Map<EditorTool, AuvieIcons> _icons = {
    EditorTool.film: AuvieIcons.film,
    EditorTool.adjust: AuvieIcons.adjust,
    EditorTool.type: AuvieIcons.type,
    EditorTool.brush: AuvieIcons.brush,
    EditorTool.add: AuvieIcons.add,
  };

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: palette.hairline)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 4),
        child: Row(
          children: [
            for (final tool in EditorTool.values)
              Expanded(
                child: Semantics(
                  button: true,
                  selected: tool == active,
                  enabled: tool.isAvailable,
                  child: GestureDetector(
                    key: Key('tool-${tool.name}'),
                    behavior: HitTestBehavior.opaque,
                    onTap: tool.isAvailable ? () => onSelect(tool) : null,
                    child: Opacity(
                      opacity: tool.isAvailable ? 1 : 0.35,
                      child: _ToolItem(
                        icon: _icons[tool]!,
                        label: tool.name.toUpperCase(),
                        active: tool == active,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ToolItem extends StatelessWidget {
  const new({required this.icon, required this.label, required this.active});

  final AuvieIcons icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final color = active ? palette.foreground : palette.muted;
    return SizedBox(
      height: 54,
      child: Column(
        children: [
          AuvieIcon(icon, color: color),
          const SizedBox(height: 7),
          Text(label, style: context.type.tag.copyWith(color: color)),
          const SizedBox(height: 4),
          Container(
            width: 3,
            height: 3,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? palette.accent : Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }
}
