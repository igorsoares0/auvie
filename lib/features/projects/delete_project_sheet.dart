import 'package:auvie/app/theme/app_theme.dart';
import 'package:auvie/app/theme/spacing.dart';
import 'package:auvie/app/widgets/emphasis_text.dart';
import 'package:flutter/material.dart';

/// Asks before deleting an edit (paper sheet, like S5). True to delete.
Future<bool> confirmDeleteProject(BuildContext context, {String? name}) async {
  final delete = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: const Color(0x8C0B0A09),
    builder: (context) => Theme(
      data: AuvieTheme.paper(),
      child: _DeleteSheet(name: name ?? 'this edit'),
    ),
  );
  return delete ?? false;
}

class _DeleteSheet extends StatelessWidget {
  const new({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Material(
      key: const Key('delete-sheet'),
      color: palette.background,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AuvieSpacing.gutter,
            AuvieSpacing.s10,
            AuvieSpacing.gutter,
            AuvieSpacing.s12,
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
                'DELETE THIS EDIT',
                style: context.type.tag.copyWith(color: palette.accent),
              ),
              const SizedBox(height: AuvieSpacing.s8),
              EmphasisText(
                'Delete *$name?*',
                style: context.type.display.copyWith(fontSize: 26),
              ),
              const SizedBox(height: AuvieSpacing.s10),
              Text(
                'The original stays in your gallery. This edit and its '
                'history are gone for good.',
                style: context.type.body,
              ),
              const SizedBox(height: AuvieSpacing.s18),
              FilledButton(
                key: const Key('delete-confirm'),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('DELETE'),
              ),
              const SizedBox(height: AuvieSpacing.s6),
              TextButton(
                key: const Key('delete-cancel'),
                onPressed: () => Navigator.of(context).pop(false),
                style: TextButton.styleFrom(
                  minimumSize: const Size.fromHeight(
                    AuvieSpacing.ghostButtonHeight,
                  ),
                  foregroundColor: palette.foreground,
                ),
                child: const Text('KEEP IT'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
