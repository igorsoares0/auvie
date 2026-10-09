import 'package:auvie/core/models/edit_state.dart';
import 'package:auvie/core/models/preset.dart';

/// The italic line under the photo: "Ektar, at 72%",
/// "Ektar 72%, three adjustments", "Two adjustments", "Original".
String describeEdit(EditState edit, Preset? preset) {
  final ref = edit.preset;
  final count =
      edit.adjustments.values.length +
      (edit.curves.isIdentity ? 0 : 1) +
      (edit.crop.isIdentity ? 0 : 1);
  String? counted(int n, String noun) =>
      n == 0 ? null : '${_numberWord(n)} $noun${n == 1 ? '' : 's'}';
  final rest = [
    ?counted(count, 'adjustment'),
    ?counted(edit.elements.length, 'element'),
  ].join(', ');

  if (ref == null || preset == null) {
    if (rest.isEmpty) return 'Original';
    return rest[0].toUpperCase() + rest.substring(1);
  }
  final name = presetBaseName(preset.name);
  final percent = (ref.intensity * 100).round();
  return rest.isEmpty ? '$name, at $percent%' : '$name $percent%, $rest';
}

/// "Ektar 02" → "Ektar"; names without a stock number stay whole.
String presetBaseName(String name) {
  final parts = name.split(' ');
  if (parts.length > 1 && int.tryParse(parts.last) != null) {
    return parts.sublist(0, parts.length - 1).join(' ');
  }
  return name;
}

/// "Ektar 02" → "02"; null when the name has no stock number.
String? presetStockNumber(String name) {
  final last = name.split(' ').last;
  return name.contains(' ') && int.tryParse(last) != null ? last : null;
}

/// The line under a preset card: "02 · 100", "400", "—".
String presetMeta(Preset? preset) {
  if (preset == null) return '—';
  final parts = [
    ?presetStockNumber(preset.name),
    if (preset.iso case final iso?) '$iso',
  ];
  return parts.isEmpty ? '—' : parts.join(' · ');
}

String _numberWord(int n) => const [
  'zero', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', //
  'eight', 'nine', 'ten', 'eleven', 'twelve', 'thirteen',
][n.clamp(0, 13)];
