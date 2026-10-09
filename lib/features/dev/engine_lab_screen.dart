import 'dart:async';
import 'dart:convert';

import 'package:auvie/app/theme/app_theme.dart';
import 'package:auvie/app/theme/spacing.dart';
import 'package:auvie/core/content/catalog_providers.dart';
import 'package:auvie/core/models/adjustment.dart';
import 'package:auvie/core/models/edit_state.dart';
import 'package:auvie/core/models/preset.dart';
import 'package:auvie/core/models/project.dart';
import 'package:auvie/core/native/media_engine.dart';
import 'package:auvie/core/native/media_engine_provider.dart';
import 'package:auvie/core/native/preview_size.dart';
import 'package:auvie/core/native/render_params.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Debug/profile-only bench for the media engine (route `/dev/engine`): every
/// adjustment on a slider, presets with intensity, hold to compare, and the
/// current values as JSON for calibrating `assets/content/catalog.json`.
/// Not the editor UI — that is built in M3.
class EngineLabScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<EngineLabScreen> createState() => _EngineLabScreenState();
}

class _EngineLabScreenState extends ConsumerState<EngineLabScreen> {
  late final MediaEngine _engine;
  final GlobalKey<State<StatefulWidget>> _previewArea = GlobalKey();
  MediaRef? _media;
  PhotoPreview? _preview;
  EditState _edit = const EditState();
  Preset? _preset;
  String? _error;

  @override
  void initState() {
    super.initState();
    _engine = ref.read(mediaEngineProvider);
  }

  @override
  void dispose() {
    final preview = _preview;
    if (preview != null) unawaited(_engine.disposePreview(preview.textureId));
    super.dispose();
  }

  Future<void> _pick() async {
    try {
      final media = await _engine.pickMedia(MediaType.photo);
      if (media == null || !mounted) return;
      final area =
          _previewArea.currentContext!.findRenderObject()! as RenderBox;
      final maxPx = previewMaxPx(
        media: media,
        box: area.size,
        devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
      );
      final old = _preview;
      final preview = await _engine.createPhotoPreview(media.uri, maxPx: maxPx);
      if (old != null) await _engine.disposePreview(old.textureId);
      if (!mounted) return;
      setState(() {
        _media = media;
        _preview = preview;
        _error = null;
      });
      _push();
    } on MediaEngineException catch (e) {
      setState(() => _error = e.toString());
    }
  }

  void _apply(EditState edit, {Preset? preset}) {
    setState(() {
      _edit = edit;
      if (preset != null || edit.preset == null) _preset = preset;
    });
    _push();
  }

  void _push() {
    final preview = _preview;
    if (preview == null) return;
    unawaited(
      _engine.updateEdit(
        preview.textureId,
        RenderParams.fromEdit(
          _edit,
          _preset,
          mediaRatio: _media?.aspectRatio ?? 1,
        ),
      ),
    );
  }

  void _compare({required bool original}) {
    final preview = _preview;
    if (preview == null) return;
    unawaited(_engine.setShowOriginal(preview.textureId, original: original));
  }

  Future<void> _copyJson() async {
    final json = jsonEncode(_edit.adjustments.toJson());
    await Clipboard.setData(ClipboardData(text: json));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(json)));
  }

  Future<void> _renderOffscreen() async {
    final media = _media;
    if (media == null) return;
    final bytes = await _engine.renderPhoto(
      media.uri,
      RenderParams.fromEdit(
        _edit,
        _preset,
        mediaRatio: _media?.aspectRatio ?? 1,
      ),
      maxPx: 1080,
    );
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => Dialog(child: Image.memory(bytes)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final presets = ref.watch(catalogProvider).value?.presets ?? const [];
    final preview = _preview;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: AuvieSpacing.headerHeight,
              child: Row(
                children: [
                  const SizedBox(width: AuvieSpacing.s12),
                  Text('ENGINE LAB', style: context.type.label),
                  const Spacer(),
                  TextButton(
                    key: const Key('lab-pick'),
                    onPressed: _pick,
                    child: const Text('PICK'),
                  ),
                  TextButton(
                    onPressed: () => _apply(const EditState()),
                    child: const Text('RESET'),
                  ),
                  TextButton(onPressed: _copyJson, child: const Text('JSON')),
                  TextButton(
                    onPressed: _media == null ? null : _renderOffscreen,
                    child: const Text('RENDER'),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Center(
                key: _previewArea,
                child: preview == null
                    ? Text(
                        _error ?? 'Pick a photo. Hold it to see the original.',
                        style: context.type.body,
                        textAlign: TextAlign.center,
                      )
                    : AspectRatio(
                        aspectRatio: preview.width / preview.height,
                        child: GestureDetector(
                          onLongPressStart: (_) => _compare(original: true),
                          onLongPressEnd: (_) => _compare(original: false),
                          onLongPressCancel: () => _compare(original: false),
                          child: Texture(
                            key: const Key('lab-texture'),
                            textureId: preview.textureId,
                          ),
                        ),
                      ),
              ),
            ),
            Expanded(
              flex: 2,
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AuvieSpacing.s12,
                ),
                children: [
                  DropdownButton<String?>(
                    key: const Key('lab-preset'),
                    isExpanded: true,
                    value: _edit.preset?.presetId,
                    items: [
                      const DropdownMenuItem(child: Text('No preset')),
                      for (final p in presets)
                        DropdownMenuItem(value: p.id, child: Text(p.name)),
                    ],
                    onChanged: (id) {
                      final preset = presets
                          .where((p) => p.id == id)
                          .firstOrNull;
                      _apply(
                        preset == null
                            ? _edit.withoutPreset()
                            : _edit.withPreset(preset.id),
                        preset: preset,
                      );
                    },
                  ),
                  if (_edit.preset case final ref?)
                    _LabSlider(
                      name: 'intensity',
                      value: ref.intensity,
                      min: 0,
                      onChanged: (v) => _apply(_edit.withPresetIntensity(v)),
                    ),
                  for (final a in Adjustment.values)
                    _LabSlider(
                      name: a.name,
                      value: _edit.adjustments[a],
                      min: a.min,
                      onChanged: (v) => _apply(_edit.withAdjustment(a, v)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LabSlider extends StatelessWidget {
  const new({
    required this.name,
    required this.value,
    required this.min,
    required this.onChanged,
  });

  final String name;
  final double value;
  final double min;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 96,
          child: Text(name.toUpperCase(), style: context.type.tag),
        ),
        Expanded(
          child: Slider(
            key: Key('slider-$name'),
            value: value,
            min: min,
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 44,
          child: Text(
            value.toStringAsFixed(2),
            style: context.type.tag,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
