import 'package:auvie/app/theme/app_theme.dart';
import 'package:auvie/app/theme/spacing.dart';
import 'package:auvie/core/models/elements.dart';
import 'package:auvie/features/editor/elements/text_renderer.dart';
import 'package:auvie/features/editor/photo/photo_editor_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Typing a text: the editor dims and the keyboard comes up; the photo
/// shows the text live. CANCEL / DONE are in the header (handoff 04).
class TextEditOverlay extends ConsumerStatefulWidget {
  const new({required this.projectId, super.key});

  final String projectId;

  /// Size the typed text is previewed at (logical px of the reference box).
  static const previewBox = Size(360, 360);

  @override
  ConsumerState<TextEditOverlay> createState() => _TextEditOverlayState();
}

class _TextEditOverlayState extends ConsumerState<TextEditOverlay> {
  late final TextEditingController _text;

  @override
  void initState() {
    super.initState();
    final session = ref
        .read(photoEditorProvider(widget.projectId))
        .requireValue;
    final initial = switch (session.element(session.editingElementId)) {
      final TextElement e => e.text,
      final TextPathElement e => e.text,
      _ => '',
    };
    _text = TextEditingController(text: initial);
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref
        .watch(photoEditorProvider(widget.projectId))
        .requireValue;
    final editing = session.element(session.editingElementId);
    final style = switch (editing) {
      final TextElement e => e.style,
      final TextPathElement e => e.style,
      _ => const TextStyleSpec(),
    };
    final shown = TextRenderer.textStyle(style, TextEditOverlay.previewBox);
    final palette = context.palette;

    return ColoredBox(
      color: palette.veil,
      child: Padding(
        padding: const EdgeInsets.all(AuvieSpacing.gutter),
        child: Center(
          child: TextField(
            key: const Key('text-input'),
            controller: _text,
            autofocus: true,
            maxLines: null,
            textAlign: switch (style.align) {
              TextAlignment.left => TextAlign.left,
              TextAlignment.center => TextAlign.center,
              TextAlignment.right => TextAlign.right,
            },
            textCapitalization: TextCapitalization.sentences,
            cursorColor: palette.accent,
            style: shown.copyWith(fontSize: shown.fontSize!.clamp(22, 48)),
            decoration: InputDecoration.collapsed(
              hintText: 'Type something',
              hintStyle: shown.copyWith(
                fontSize: shown.fontSize!.clamp(22, 48),
                color: palette.muted,
              ),
            ),
            onChanged: ref
                .read(photoEditorProvider(widget.projectId).notifier)
                .typeText,
          ),
        ),
      ),
    );
  }
}
