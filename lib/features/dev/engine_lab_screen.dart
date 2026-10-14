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

/// What the lab's sliders change.
enum LabMode {
  /// The selected film's own settings (calibrating the catalog).
  film,

  /// The user's adjustments on top, as in the editor.
  adjust,

  /// How strong grain and sharpen are, for every film and photo.
  tuning,
}

/// Debug/profile-only bench for calibrating the look (route `/dev/engine`):
/// pick your photos, switch films, edit a film's settings live, tune grain
/// and sharpen, hold the photo to compare, then JSON copies everything to
/// bake into `assets/content/catalog.json` and `DevelopTuning.kt`.
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
  String? _error;
  LabMode _mode = LabMode.film;

  /// Films as edited in the lab, by id (catalog values until changed).
  final _films = <String, Preset>{};
  DevelopTuning? _tuning;

  @override
  void initState() {
    super.initState();
    _engine = ref.read(mediaEngineProvider);
    unawaited(_loadTuning());
  }

  Future<void> _loadTuning() async {
    try {
      final tuning = await _engine.developTuning();
      if (mounted) setState(() => _tuning = tuning);
    } on MediaEngineException catch (e) {
      debugPrint('Tuning: $e');
    }
  }

  @override
  void dispose() {
    final preview = _preview;
    if (preview != null) unawaited(_engine.disposePreview(preview.textureId));
    super.dispose();
  }

  Preset? get _film {
    final id = _edit.preset?.presetId;
    return id == null ? null : _films[id];
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

  void _apply(EditState edit) {
    setState(() => _edit = edit);
    _push();
  }

  void _editFilm(Adjustment adjustment, double value) {
    final film = _film;
    if (film == null) return;
    setState(() {
      _films[film.id] = film.copyWith(
        settings: film.settings.withValue(adjustment, value),
      );
    });
    _push();
  }

  void _resetFilm(List<Preset> catalog) {
    final film = _film;
    if (film == null) return;
    final original = catalog.where((p) => p.id == film.id).firstOrNull;
    if (original == null) return;
    setState(() => _films[film.id] = original);
    _push();
  }

  Future<void> _setTuning(DevelopTuning tuning) async {
    setState(() => _tuning = tuning);
    await _engine.setDevelopTuning(tuning);
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
          _film,
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

  static double _round(double v) => (v * 100).round() / 100;

  /// Everything calibrated so far, ready to paste into the chat.
  String _labJson() {
    final tuning = _tuning;
    return const JsonEncoder.withIndent('  ').convert({
      if (tuning != null)
        'tuning': {
          'grainAmount': _round(tuning.grainAmount),
          'sharpenAmount': _round(tuning.sharpenAmount),
          'grainCells': tuning.grainCells,
        },
      'presets': {
        for (final film in _films.values)
          film.id: {
            for (final MapEntry(:key, :value) in film.settings.values.entries)
              key.name: _round(value),
          },
      },
      if (!_edit.adjustments.isNeutral)
        'adjustments': {
          for (final MapEntry(:key, :value) in _edit.adjustments.values.entries)
            key.name: _round(value),
        },
    });
  }

  Future<void> _copyJson() async {
    final json = _labJson();
    unawaited(
      Clipboard.setData(
        ClipboardData(text: json),
      ).catchError((Object e) => debugPrint('Clipboard: $e')),
    );
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Copied'),
        content: SingleChildScrollView(child: SelectableText(json)),
      ),
    );
  }

  Future<void> _renderOffscreen() async {
    final media = _media;
    if (media == null) return;
    final bytes = await _engine.renderPhoto(
      media.uri,
      RenderParams.fromEdit(_edit, _film, mediaRatio: media.aspectRatio),
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
    final catalog = ref.watch(catalogProvider).value?.presets ?? const [];
    for (final preset in catalog) {
      _films.putIfAbsent(preset.id, () => preset);
    }
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
                    key: const Key('lab-json'),
                    onPressed: _copyJson,
                    child: const Text('JSON'),
                  ),
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
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AuvieSpacing.s12,
                ),
                children: [
                  _Chip(
                    key: const Key('lab-film-none'),
                    label: 'NONE',
                    selected: _edit.preset == null,
                    onTap: () => _apply(_edit.withoutPreset()),
                  ),
                  for (final preset in catalog)
                    _Chip(
                      key: Key('lab-film-${preset.id}'),
                      label: preset.name.toUpperCase(),
                      selected: _edit.preset?.presetId == preset.id,
                      onTap: () => _apply(_edit.withPreset(preset.id)),
                    ),
                ],
              ),
            ),
            SegmentedButton<LabMode>(
              segments: const [
                ButtonSegment(value: LabMode.film, label: Text('FILM')),
                ButtonSegment(value: LabMode.adjust, label: Text('ADJUST')),
                ButtonSegment(value: LabMode.tuning, label: Text('TUNING')),
              ],
              selected: {_mode},
              showSelectedIcon: false,
              onSelectionChanged: (s) => setState(() => _mode = s.single),
            ),
            Expanded(
              flex: 2,
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AuvieSpacing.s12,
                ),
                children: switch (_mode) {
                  LabMode.film => _filmSliders(catalog),
                  LabMode.adjust => [
                    for (final a in Adjustment.values)
                      _LabSlider(
                        sliderKey: Key('slider-${a.name}'),
                        name: a.name,
                        value: _edit.adjustments[a],
                        min: a.min,
                        onChanged: (v) => _apply(_edit.withAdjustment(a, v)),
                      ),
                    TextButton(
                      onPressed: () => _apply(
                        _edit.copyWith(
                          adjustments: const EditState().adjustments,
                        ),
                      ),
                      child: const Text('RESET ADJUSTMENTS'),
                    ),
                  ],
                  LabMode.tuning => _tuningSliders(),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _filmSliders(List<Preset> catalog) {
    final film = _film;
    final ref = _edit.preset;
    if (film == null || ref == null) {
      return [
        Padding(
          padding: const EdgeInsets.all(AuvieSpacing.s12),
          child: Text(
            'Choose a film above to edit its settings.',
            style: context.type.body,
          ),
        ),
      ];
    }
    return [
      _LabSlider(
        sliderKey: const Key('slider-intensity'),
        name: 'intensity',
        value: ref.intensity,
        min: 0,
        onChanged: (v) => _apply(_edit.withPresetIntensity(v)),
      ),
      for (final a in Adjustment.values)
        _LabSlider(
          sliderKey: Key('film-${a.name}'),
          name: a.name,
          value: film.settings[a],
          min: a.min,
          onChanged: (v) => _editFilm(a, v),
        ),
      TextButton(
        key: const Key('lab-film-reset'),
        onPressed: () => _resetFilm(catalog),
        child: Text('RESET ${film.name.toUpperCase()}'),
      ),
    ];
  }

  List<Widget> _tuningSliders() {
    final tuning = _tuning;
    if (tuning == null) return const [];
    return [
      _LabSlider(
        sliderKey: const Key('tuning-grain'),
        name: 'grain ×',
        value: tuning.grainAmount,
        min: 0,
        max: 1.5,
        onChanged: (v) => _setTuning((
          grainAmount: v,
          sharpenAmount: tuning.sharpenAmount,
          grainCells: tuning.grainCells,
        )),
      ),
      _LabSlider(
        sliderKey: const Key('tuning-cells'),
        name: 'grain cells',
        value: tuning.grainCells.toDouble(),
        min: 300,
        max: 2000,
        decimals: 0,
        onChanged: (v) => _setTuning((
          grainAmount: tuning.grainAmount,
          sharpenAmount: tuning.sharpenAmount,
          grainCells: v.round(),
        )),
      ),
      _LabSlider(
        sliderKey: const Key('tuning-sharpen'),
        name: 'sharpen ×',
        value: tuning.sharpenAmount,
        min: 0,
        max: 8,
        onChanged: (v) => _setTuning((
          grainAmount: tuning.grainAmount,
          sharpenAmount: v,
          grainCells: tuning.grainCells,
        )),
      ),
      Padding(
        padding: const EdgeInsets.all(AuvieSpacing.s12),
        child: Text(
          'Grain and sharpen strengths apply to every film. Judge grain on '
          'RENDER too: the export is where it counts.',
          style: context.type.tag,
        ),
      ),
    ];
  }
}

class _Chip extends StatelessWidget {
  const new({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AuvieSpacing.s6),
      child: ChoiceChip(
        label: Text(label, style: context.type.tag),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class _LabSlider extends StatelessWidget {
  const new({
    required this.sliderKey,
    required this.name,
    required this.value,
    required this.min,
    required this.onChanged,
    this.max = 1,
    this.decimals = 2,
  });

  final Key sliderKey;
  final String name;
  final double value;
  final double min;
  final double max;
  final int decimals;
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
            key: sliderKey,
            value: value.clamp(min, max),
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 48,
          child: Text(
            value.toStringAsFixed(decimals),
            style: context.type.tag,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
