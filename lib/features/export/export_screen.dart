import 'dart:async';

import 'package:auvie/app/router/routes.dart';
import 'package:auvie/app/theme/app_theme.dart';
import 'package:auvie/app/theme/colors.dart';
import 'package:auvie/app/theme/spacing.dart';
import 'package:auvie/app/theme/typography.dart';
import 'package:auvie/app/widgets/auvie_icon.dart';
import 'package:auvie/app/widgets/caps_link.dart';
import 'package:auvie/app/widgets/emphasis_text.dart';
import 'package:auvie/app/widgets/pending_screen.dart';
import 'package:auvie/core/models/project.dart';
import 'package:auvie/core/native/media_engine.dart';
import 'package:auvie/core/native/media_engine_provider.dart';
import 'package:auvie/core/platform/share_service.dart';
import 'package:auvie/features/editor/shell/edit_caption.dart';
import 'package:auvie/features/export/export_controller.dart';
import 'package:auvie/features/export/export_error_sheet.dart';
import 'package:auvie/features/export/export_options.dart';
import 'package:auvie/features/export/export_providers.dart';
import 'package:auvie/features/projects/project_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Export (handoff 07) and its states: exporting (S3), saved (S4),
/// error (S5). Errors never discard the edit.
class ExportScreen extends ConsumerWidget {
  const new({required this.projectId, super.key});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = exportControllerProvider(projectId);
    ref.listen(provider, (previous, next) {
      final phase = next.value?.phase;
      final before = previous?.value?.phase;
      if (phase is ExportDone && phase.thenShare && before is! ExportDone) {
        unawaited(_share(ref, phase.result, next.requireValue.options.format));
      }
    });
    final async = ref.watch(provider);
    final session = async.value;
    final running = session?.phase is ExportRunning;

    return PopScope(
      canPop: !running,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && running) unawaited(ref.read(provider.notifier).cancel());
      },
      child: Scaffold(
        body: SafeArea(
          child: switch (async) {
            AsyncData(value: final s)
                when s.project.media.type == MediaType.video =>
              const PendingScreen(title: 'Export', milestone: 'M6'),
            AsyncData(value: final s) => switch (s.phase) {
              ExportRunning() => _Exporting(projectId: projectId, session: s),
              ExportDone(:final result) => _Done(
                projectId: projectId,
                session: s,
                result: result,
              ),
              ExportFailed() || ExportIdle() => Stack(
                children: [
                  _Options(projectId: projectId, session: s),
                  if (s.phase case final ExportFailed failed)
                    ExportErrorSheet(
                      failed: failed,
                      smaller: s.options.size.smaller,
                      smallerPixels: s.options.size.smaller == null
                          ? null
                          : s.pixels(s.options.size.smaller),
                      onSmaller: () =>
                          ref.read(provider.notifier).retrySmaller(),
                      onRetry: () => ref.read(provider.notifier).start(),
                      onDismiss: ref.read(provider.notifier).reset,
                    ),
                ],
              ),
            },
            AsyncError() => Center(
              child: Text(
                "This edit can't be exported.",
                style: context.type.body,
              ),
            ),
            _ => const SizedBox.shrink(),
          },
        ),
      ),
    );
  }

  static Future<void> _share(
    WidgetRef ref,
    ExportResult result,
    ExportFormat format,
  ) => ref
      .read(shareServiceProvider)
      .shareFile(result.filePath, mimeType: format.mimeType);
}

/// The developed, cropped photo.
class _Photo extends ConsumerWidget {
  const new({required this.projectId, this.fit = BoxFit.contain});

  final String projectId;
  final BoxFit fit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bytes = ref.watch(exportPreviewProvider(projectId)).value;
    if (bytes == null) return ColoredBox(color: context.palette.hairline);
    return Image.memory(bytes, fit: fit, gaplessPlayback: true);
  }
}

class _Title extends StatelessWidget {
  const new({this.leading});

  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AuvieSpacing.headerHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            'Export',
            style: AuvieTypography.serif(15, color: context.palette.foreground),
          ),
          if (leading != null)
            Align(alignment: Alignment.centerLeft, child: leading),
        ],
      ),
    );
  }
}

class _Options extends ConsumerWidget {
  const new({required this.projectId, required this.session});

  final String projectId;
  final ExportSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(exportControllerProvider(projectId).notifier);
    final palette = context.palette;
    final options = session.options;
    final project = session.project;
    final pixels = session.pixels();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AuvieSpacing.gutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Title(
            leading: CapsLink(
              'Edit',
              key: const Key('export-back'),
              color: palette.mutedStrong,
              onTap: () => context.pop(),
            ),
          ),
          const SizedBox(height: AuvieSpacing.s18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 92,
                height: 116,
                child: _Photo(projectId: projectId, fit: BoxFit.cover),
              ),
              const SizedBox(width: AuvieSpacing.s14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AuvieSpacing.s14),
                    Text(
                      project.name ?? 'Untitled',
                      style: AuvieTypography.serif(
                        20,
                        italic: true,
                        color: palette.foreground,
                      ),
                    ),
                    const SizedBox(height: AuvieSpacing.s8),
                    Text(
                      describeEdit(project.edit, session.preset).toUpperCase(),
                      style: context.type.tag,
                    ),
                    const SizedBox(height: AuvieSpacing.s6),
                    Text(
                      '${pixels.width} × ${pixels.height} · '
                      '${aspectLabel(pixels.width, pixels.height)}',
                      key: const Key('export-dimensions'),
                      style: context.type.tag,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AuvieSpacing.s22),
          Text('FORMAT', style: context.type.label),
          const SizedBox(height: AuvieSpacing.s8),
          _Segmented(
            keyPrefix: 'format',
            items: [
              for (final f in ExportFormat.values) (f.name, f.label, f.note),
            ],
            selected: options.format.name,
            italicNote: true,
            onSelect: (name) => controller.setOptions((
              format: ExportFormat.values.byName(name),
              size: options.size,
              keepMetadata: options.keepMetadata,
            )),
          ),
          const SizedBox(height: AuvieSpacing.s18),
          Text('SIZE', style: context.type.label),
          const SizedBox(height: AuvieSpacing.s8),
          _Segmented(
            keyPrefix: 'size',
            items: [
              for (final s in ExportSize.values)
                (s.name, s.label.toUpperCase(), megapixels(session.pixels(s))),
            ],
            selected: options.size.name,
            onSelect: (name) => controller.setOptions((
              format: options.format,
              size: ExportSize.values.byName(name),
              keepMetadata: options.keepMetadata,
            )),
          ),
          const SizedBox(height: AuvieSpacing.s18),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Keep location & camera data',
                      style: AuvieTypography.serif(
                        16,
                        color: palette.foreground,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      options.format == ExportFormat.png
                          ? 'JPEG ONLY'
                          : 'EXIF · GPS',
                      style: context.type.tag,
                    ),
                  ],
                ),
              ),
              Switch(
                key: const Key('export-metadata'),
                value: options.keepMetadata,
                activeThumbColor: palette.background,
                activeTrackColor: palette.foreground,
                inactiveThumbColor: palette.muted,
                inactiveTrackColor: Colors.transparent,
                trackOutlineColor: WidgetStatePropertyAll(
                  palette.hairlineStrong,
                ),
                onChanged: (v) => controller.setOptions((
                  format: options.format,
                  size: options.size,
                  keepMetadata: v,
                )),
              ),
            ],
          ),
          const Spacer(),
          FilledButton(
            key: const Key('export-save'),
            onPressed: controller.start,
            child: const Text('SAVE TO PHOTOS'),
          ),
          const SizedBox(height: AuvieSpacing.s6),
          TextButton(
            key: const Key('export-share'),
            onPressed: () => controller.start(thenShare: true),
            style: TextButton.styleFrom(
              minimumSize: const Size.fromHeight(
                AuvieSpacing.ghostButtonHeight,
              ),
              foregroundColor: palette.foreground,
            ),
            child: const Text('SHARE…'),
          ),
          const SizedBox(height: AuvieSpacing.s8),
        ],
      ),
    );
  }
}

/// Segmented control, 46 pt, filled selection (handoff "Export").
class _Segmented extends StatelessWidget {
  const new({
    required this.keyPrefix,
    required this.items,
    required this.selected,
    required this.onSelect,
    this.italicNote = false,
  });

  final String keyPrefix;

  /// (id, label, note).
  final List<(String, String, String)> items;
  final String selected;
  final ValueChanged<String> onSelect;
  final bool italicNote;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      height: 46,
      decoration: BoxDecoration(
        border: Border.all(color: palette.hairlineStrong),
      ),
      child: Row(
        children: [
          for (final (i, (id, label, note)) in items.indexed) ...[
            if (i > 0) VerticalDivider(width: 1, color: palette.hairlineStrong),
            Expanded(
              child: Semantics(
                button: true,
                selected: id == selected,
                child: GestureDetector(
                  key: Key('$keyPrefix-$id'),
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onSelect(id),
                  child: ColoredBox(
                    color: id == selected
                        ? palette.foreground
                        : Colors.transparent,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          label,
                          style: context.type.tag.copyWith(
                            fontSize: 10,
                            color: id == selected
                                ? palette.background
                                : palette.foreground,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          note,
                          style: italicNote
                              ? AuvieTypography.serif(
                                  12,
                                  italic: true,
                                  color: id == selected
                                      ? palette.background
                                      : palette.muted,
                                )
                              : context.type.tag.copyWith(
                                  color: id == selected
                                      ? palette.background
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
        ],
      ),
    );
  }
}

/// S3: the frame develops from the top while the export runs.
class _Exporting extends ConsumerWidget {
  const new({required this.projectId, required this.session});

  final String projectId;
  final ExportSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phase = session.phase as ExportRunning;
    final palette = context.palette;
    final percent = (phase.fraction * 100).floor();
    final frame = (session.project.name ?? 'Untitled').split(' · ').last;
    final eta = phase.etaSeconds;
    final details = [
      session.options.format.label,
      session.options.size.label.toUpperCase(),
      if (eta != null) 'ABOUT $eta SECOND${eta == 1 ? '' : 'S'}',
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AuvieSpacing.gutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Title(),
          const SizedBox(height: AuvieSpacing.s18),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: session.project.edit.crop.outputRatio(
                  session.project.media.aspectRatio,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final developed = constraints.maxHeight * phase.fraction;
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        _Photo(projectId: projectId, fit: BoxFit.cover),
                        Positioned(
                          left: 0,
                          right: 0,
                          top: developed,
                          bottom: 0,
                          child: const ColoredBox(color: Color(0xB8161412)),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          top: developed,
                          height: 1,
                          child: ColoredBox(color: palette.accent),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: AuvieSpacing.s22),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$percent',
                  style: AuvieTypography.serif(
                    44,
                    height: 1,
                    color: palette.foreground,
                  ),
                ),
                TextSpan(
                  text: '%',
                  style: AuvieTypography.serif(22, color: palette.muted),
                ),
              ],
            ),
            key: const Key('export-percent'),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AuvieSpacing.s10),
          Text(
            'Developing frame $frame…',
            textAlign: TextAlign.center,
            style: AuvieTypography.serif(
              16,
              italic: true,
              color: palette.foreground2,
            ),
          ),
          const SizedBox(height: AuvieSpacing.s8),
          Text(details, textAlign: TextAlign.center, style: context.type.tag),
          const SizedBox(height: AuvieSpacing.s14),
          SizedBox(
            height: 1,
            child: LayoutBuilder(
              builder: (context, constraints) => Stack(
                children: [
                  Positioned.fill(
                    child: ColoredBox(color: palette.hairlineStrong),
                  ),
                  SizedBox(
                    width: constraints.maxWidth * phase.fraction,
                    child: ColoredBox(color: palette.foreground),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AuvieSpacing.s34),
          Center(
            child: CapsLink(
              'Cancel',
              key: const Key('export-cancel'),
              onTap: () => ref
                  .read(exportControllerProvider(projectId).notifier)
                  .cancel(),
            ),
          ),
          const SizedBox(height: AuvieSpacing.s12),
        ],
      ),
    );
  }
}

/// S4: the print, mounted.
class _Done extends ConsumerWidget {
  const new({
    required this.projectId,
    required this.session,
    required this.result,
  });

  final String projectId;
  final ExportSession session;
  final ExportResult result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final controller = ref.read(exportControllerProvider(projectId).notifier);
    final name = (session.project.name ?? 'Untitled').toUpperCase();

    void backToEdit() {
      controller.reset();
      context.pop();
    }

    Future<void> newPhoto() async {
      final project = await ref
          .read(projectStarterProvider)
          .start(MediaType.photo);
      if (project != null && context.mounted) {
        context.go(AppRoutes.photoEditor(project.id));
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AuvieSpacing.gutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: AuvieSpacing.headerHeight,
            child: Align(
              alignment: Alignment.centerRight,
              child: CapsLink(
                '×',
                key: const Key('export-close'),
                onTap: backToEdit,
              ),
            ),
          ),
          const SizedBox(height: AuvieSpacing.s8),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: result.width / result.height,
                child: DecoratedBox(
                  decoration: const BoxDecoration(color: AuvieColors.bone),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: _Photo(projectId: projectId, fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AuvieSpacing.s22),
          Text(
            'SAVED TO PHOTOS',
            textAlign: TextAlign.center,
            style: context.type.tag,
          ),
          const SizedBox(height: AuvieSpacing.s8),
          EmphasisText(
            'Printed. *Beautifully.*',
            style: context.type.display.copyWith(fontSize: 30),
          ).centered(),
          const SizedBox(height: AuvieSpacing.s8),
          Text(
            '$name · ${megabytes(result.bytes)}',
            textAlign: TextAlign.center,
            style: context.type.tag,
          ),
          const SizedBox(height: AuvieSpacing.s18),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border.symmetric(
                horizontal: BorderSide(color: palette.hairline),
              ),
            ),
            child: Row(
              children: [
                _DoneAction(
                  key: const Key('export-done-share'),
                  icon: AuvieIcons.share,
                  label: 'Share',
                  onTap: () =>
                      ExportScreen._share(ref, result, session.options.format),
                ),
                VerticalDivider(width: 1, color: palette.hairline),
                _DoneAction(
                  key: const Key('export-done-copy'),
                  icon: AuvieIcons.dup,
                  label: 'Copy',
                  onTap: () async {
                    await ref
                        .read(mediaEngineProvider)
                        .copyToClipboard(result.mediaUri);
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text('Copied')));
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AuvieSpacing.s28),
          FilledButton(
            key: const Key('export-back-to-edit'),
            onPressed: backToEdit,
            child: const Text('BACK TO EDIT'),
          ),
          const SizedBox(height: AuvieSpacing.s6),
          TextButton(
            key: const Key('export-new-photo'),
            onPressed: newPhoto,
            style: TextButton.styleFrom(
              minimumSize: const Size.fromHeight(
                AuvieSpacing.ghostButtonHeight,
              ),
              foregroundColor: palette.foreground,
            ),
            child: const Text('NEW PHOTO'),
          ),
          const SizedBox(height: AuvieSpacing.s8),
        ],
      ),
    );
  }
}

class _DoneAction extends StatelessWidget {
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
    return Expanded(
      child: Semantics(
        button: true,
        label: label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: SizedBox(
            height: 64,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AuvieIcon(icon, size: 18),
                const SizedBox(height: AuvieSpacing.s8),
                Text(
                  label.toUpperCase(),
                  style: context.type.tag.copyWith(
                    color: context.palette.foreground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

extension on Widget {
  Widget centered() => Center(child: this);
}
