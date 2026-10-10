import 'package:auvie/app/theme/app_theme.dart';
import 'package:auvie/app/theme/spacing.dart';
import 'package:auvie/app/widgets/emphasis_text.dart';
import 'package:auvie/core/native/media_engine.dart';
import 'package:auvie/features/export/export_controller.dart';
import 'package:auvie/features/export/export_options.dart';
import 'package:flutter/material.dart';

/// S5: a paper sheet over the dimmed screen. The cause is named, the edit
/// is safe, and the primary action is the fix (a smaller size).
class ExportErrorSheet extends StatelessWidget {
  const new({
    required this.failed,
    required this.smaller,
    required this.onSmaller,
    required this.onRetry,
    required this.onDismiss,
    this.subject = 'photo',
    super.key,
  });

  /// "photo" or "video".
  final String subject;

  final ExportFailed failed;

  /// The smaller export offered, e.g. "LARGE · 12 MP" (null: none).
  final String? smaller;
  final VoidCallback onSmaller;
  final VoidCallback onRetry;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final storage = failed.error == MediaEngineError.storageFull;
    final missing = failed.missingBytes;
    final headline = storage
        ? missing == null
              ? 'Your phone needs *more space.*'
              : 'Your phone needs *${megabytes(missing)}* more space.'
        : "The $subject couldn't be *saved.*";
    final body = storage
        ? 'Your edit is safe. Free up space, or export a smaller copy now — '
              'you can always export the original later.'
        : 'Your edit is safe. Try again in a moment.';

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: onDismiss,
            child: const ColoredBox(color: Color(0x8C0B0A09)),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Theme(
            data: AuvieTheme.paper(),
            child: Builder(
              builder: (context) {
                final palette = context.palette;
                return Material(
                  key: const Key('export-error'),
                  color: palette.background,
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
                          storage ? 'NOT SAVED · STORAGE FULL' : 'NOT SAVED',
                          style: context.type.tag.copyWith(
                            color: palette.accent,
                          ),
                        ),
                        const SizedBox(height: AuvieSpacing.s8),
                        EmphasisText(
                          headline,
                          style: context.type.display.copyWith(fontSize: 26),
                        ),
                        const SizedBox(height: AuvieSpacing.s10),
                        Text(body, style: context.type.body),
                        const SizedBox(height: AuvieSpacing.s18),
                        if (storage && smaller != null)
                          FilledButton(
                            key: const Key('export-smaller'),
                            onPressed: onSmaller,
                            child: Text('EXPORT $smaller'),
                          ),
                        const SizedBox(height: AuvieSpacing.s6),
                        TextButton(
                          key: const Key('export-retry'),
                          onPressed: onRetry,
                          style: TextButton.styleFrom(
                            minimumSize: const Size.fromHeight(
                              AuvieSpacing.ghostButtonHeight,
                            ),
                            foregroundColor: palette.foreground,
                          ),
                          child: const Text('TRY AGAIN'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
