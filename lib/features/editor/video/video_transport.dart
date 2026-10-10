import 'package:auvie/app/theme/app_theme.dart';
import 'package:auvie/app/theme/spacing.dart';
import 'package:auvie/app/theme/typography.dart';
import 'package:auvie/app/widgets/auvie_icon.dart';
import 'package:auvie/features/editor/shell/editor_controller.dart';
import 'package:auvie/features/editor/video/timeline_scale.dart';
import 'package:auvie/features/editor/video/video_playback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Play / pause, "00:04.12 OF 00:10", undo / redo and SOUND (handoff 05).
class VideoTransport extends ConsumerWidget {
  const new({required this.projectId, super.key});

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.palette;
    final playback = ref.watch(videoPlaybackProvider(projectId));
    final session = ref.watch(editorControllerProvider(projectId)).requireValue;
    final controller = ref.read(editorControllerProvider(projectId).notifier);
    final player = ref.read(videoPlaybackProvider(projectId).notifier);
    final timeline = session.timeline;
    final duration = session.durationMs;
    final trimmed = timeline.trimmedDurationMs(duration);
    final position = (playback.positionMs - timeline.trimStartMs).clamp(
      0,
      trimmed,
    );
    final code = timecode(position);
    final muted = timeline.muted || !playback.hasAudio;

    Widget iconButton(
      AuvieIcons icon,
      String key,
      VoidCallback onTap, {
      required bool enabled,
    }) => Semantics(
      button: true,
      enabled: enabled,
      label: key,
      child: GestureDetector(
        key: Key('editor-$key'),
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? onTap : null,
        child: SizedBox(
          width: 40,
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AuvieSpacing.gutter),
      child: Row(
        children: [
          Semantics(
            button: true,
            label: playback.playing ? 'Pause' : 'Play',
            child: GestureDetector(
              key: const Key('transport-play'),
              onTap: player.toggle,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: palette.foreground.withValues(alpha: 0.6),
                  ),
                ),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(left: playback.playing ? 0 : 2),
                    child: AuvieIcon(
                      playback.playing ? AuvieIcons.pause : AuvieIcons.play,
                      size: 17,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AuvieSpacing.s12),
          Expanded(
            child: Text.rich(
              key: const Key('timecode'),
              TextSpan(
                style: AuvieTypography.serif(17, color: palette.foreground),
                children: [
                  TextSpan(text: code.substring(0, 5)),
                  TextSpan(
                    text: code.substring(5),
                    style: TextStyle(color: palette.muted),
                  ),
                  TextSpan(
                    text: '  OF ${shortTime(trimmed)}',
                    style: AuvieTypography.sans(
                      10,
                      color: palette.muted,
                      letterSpacingEm: 0.08,
                    ),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.clip,
            ),
          ),
          iconButton(
            AuvieIcons.undo,
            'undo',
            controller.undo,
            enabled: session.history.canUndo,
          ),
          iconButton(
            AuvieIcons.redo,
            'redo',
            controller.redo,
            enabled: session.history.canRedo,
          ),
          const SizedBox(width: AuvieSpacing.s6),
          Semantics(
            button: true,
            enabled: playback.hasAudio,
            toggled: !muted,
            label: 'Sound',
            child: GestureDetector(
              key: const Key('transport-sound'),
              behavior: HitTestBehavior.opaque,
              onTap: playback.hasAudio ? controller.toggleMute : null,
              child: SizedBox(
                height: AuvieSpacing.minHitTarget,
                child: Row(
                  children: [
                    Text(
                      'SOUND',
                      style: AuvieTypography.sans(
                        10.5,
                        color: palette.muted,
                        letterSpacingEm: 0.16,
                      ),
                    ),
                    const SizedBox(width: AuvieSpacing.s10),
                    AuvieIcon(
                      muted ? AuvieIcons.mute : AuvieIcons.sound,
                      size: 20,
                      color: muted ? palette.muted : palette.foreground,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
