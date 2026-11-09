import 'package:auvie/app/theme/app_theme.dart';
import 'package:auvie/app/theme/spacing.dart';
import 'package:auvie/app/theme/typography.dart';
import 'package:auvie/core/content/catalog_providers.dart';
import 'package:auvie/features/editor/shell/edit_caption.dart';
import 'package:auvie/features/projects/edits_clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// What the edit actions sheet chose.
enum EditAction { copy, paste, delete }

/// The copied edits in words, for PASTE EDITS; null when none.
String? copiedEditsCaption(WidgetRef ref) {
  final edits = ref.read(editsClipboardProvider);
  if (edits == null) return null;
  final id = edits.preset?.presetId;
  final preset = id == null
      ? null
      : ref.read(catalogProvider).value?.presetById(id);
  return describeCopiedEdits(edits, preset);
}

/// COPY EDITS / PASTE EDITS (/ DELETE on Home) for one edit, on a paper
/// sheet like the delete one. [clipboard] describes the copied edits
/// ("Ektar 72%, two adjustments"); null when nothing was copied yet.
Future<EditAction?> showEditActions(
  BuildContext context, {
  required String? name,
  required String? clipboard,
  bool canDelete = true,
}) => showModalBottomSheet<EditAction>(
  context: context,
  backgroundColor: Colors.transparent,
  barrierColor: const Color(0x8C0B0A09),
  builder: (context) => Theme(
    data: AuvieTheme.paper(),
    child: _EditActionsSheet(
      name: name ?? 'Untitled',
      clipboard: clipboard,
      canDelete: canDelete,
    ),
  ),
);

class _EditActionsSheet extends StatelessWidget {
  const new({
    required this.name,
    required this.clipboard,
    required this.canDelete,
  });

  final String name;
  final String? clipboard;
  final bool canDelete;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    void choose(EditAction action) => Navigator.of(context).pop(action);
    return Material(
      key: const Key('edit-actions-sheet'),
      color: palette.background,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AuvieSpacing.gutter,
            AuvieSpacing.s10,
            AuvieSpacing.gutter,
            AuvieSpacing.s6,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 32,
                  height: 2,
                  color: palette.hairlineStrong,
                ),
              ),
              const SizedBox(height: AuvieSpacing.s14),
              Text(
                'THIS EDIT',
                style: context.type.tag.copyWith(color: palette.accent),
              ),
              const SizedBox(height: AuvieSpacing.s6),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AuvieTypography.serif(
                  24,
                  italic: true,
                  color: palette.foreground,
                ),
              ),
              const SizedBox(height: AuvieSpacing.s12),
              _ActionRow(
                actionKey: const Key('edit-action-copy'),
                label: 'Copy edits',
                caption: 'Film, adjustments, curves and color.',
                onTap: () => choose(EditAction.copy),
              ),
              _ActionRow(
                actionKey: const Key('edit-action-paste'),
                label: 'Paste edits',
                caption: clipboard ?? 'Copy an edit first.',
                onTap: clipboard == null
                    ? null
                    : () => choose(EditAction.paste),
              ),
              if (canDelete)
                _ActionRow(
                  actionKey: const Key('edit-action-delete'),
                  label: 'Delete',
                  caption: 'The original stays in your gallery.',
                  color: palette.accent,
                  onTap: () => choose(EditAction.delete),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const new({
    required this.actionKey,
    required this.label,
    required this.caption,
    required this.onTap,
    this.color,
  });

  final Key actionKey;
  final String label;
  final String caption;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final enabled = onTap != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: GestureDetector(
        key: actionKey,
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Opacity(
          opacity: enabled ? 1 : 0.4,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: palette.hairline)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AuvieSpacing.s12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: context.type.label.copyWith(
                      color: color ?? palette.foreground,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AuvieTypography.serif(
                      14,
                      italic: true,
                      color: palette.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
