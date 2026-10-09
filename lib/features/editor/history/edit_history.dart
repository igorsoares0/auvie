import 'package:flutter/foundation.dart';

/// Undo/redo over immutable states (spec §28). Stores whole states, which is
/// cheap because an edit is only parameters, never pixels.
///
/// Continuous gestures (dragging a slider, moving an element) call [preview]
/// on every frame and [commit] at the end, so the whole gesture is a single
/// undo step.
@immutable
class EditHistory<T> {
  factory(T initial, {int limit = 100}) =>
      EditHistory._(const [], initial, const [], null, limit);

  const new _(
    this._past,
    this.present,
    this._future,
    this._gestureStart,
    this.limit,
  );

  final List<T> _past;
  final T present;
  final List<T> _future;

  /// The committed state before an uncommitted [preview], if any.
  final T? _gestureStart;

  /// Maximum number of undo steps kept.
  final int limit;

  bool get canUndo => _past.isNotEmpty || _hasPendingChange;
  bool get canRedo => _future.isNotEmpty && _gestureStart == null;

  bool get _hasPendingChange =>
      _gestureStart != null && _gestureStart != present;

  /// Records [next] as a new undo step. Equal states are ignored.
  EditHistory<T> record(T next) {
    final base = commit();
    if (next == base.present) return base;
    return EditHistory._(
      _trim([...base._past, base.present]),
      next,
      const [],
      null,
      limit,
    );
  }

  /// Shows [next] without creating an undo step yet.
  EditHistory<T> preview(T next) =>
      EditHistory._(_past, next, _future, _gestureStart ?? present, limit);

  /// Turns the previews since the last commit into one undo step.
  EditHistory<T> commit() {
    final start = _gestureStart;
    if (start == null) return this;
    if (start == present) {
      return EditHistory._(_past, present, _future, null, limit);
    }
    return EditHistory._(
      _trim([..._past, start]),
      present,
      const [],
      null,
      limit,
    );
  }

  EditHistory<T> undo() {
    final base = commit();
    if (base._past.isEmpty) return base;
    return EditHistory._(
      base._past.sublist(0, base._past.length - 1),
      base._past.last,
      [base.present, ...base._future],
      null,
      limit,
    );
  }

  EditHistory<T> redo() {
    if (!canRedo) return this;
    return EditHistory._(
      _trim([..._past, present]),
      _future.first,
      _future.sublist(1),
      null,
      limit,
    );
  }

  List<T> _trim(List<T> past) =>
      past.length > limit ? past.sublist(past.length - limit) : past;
}
