import 'package:auvie/core/models/edit_state.dart';
import 'package:auvie/core/models/project.dart';
import 'package:auvie/features/editor/adjustments/adjustment_family.dart';
import 'package:auvie/features/editor/history/edit_history.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'editor_session.freezed.dart';

/// Tools of the photo editor toolbar.
enum EditorTool {
  film,
  adjust,

  /// TYPE, BRUSH and ADD are built in M5.
  type,
  brush,
  add;

  bool get isAvailable => this == film || this == adjust;
}

/// Special FILM category listing favorites.
const savedCategory = 'saved';

/// Everything on screen in the photo editor, besides the pixels.
@freezed
abstract class EditorSession with _$EditorSession {
  const factory({
    required Project project,
    required EditHistory<EditState> history,
    @Default(EditorTool.film) EditorTool tool,
    @Default(AdjustmentFamily.light) AdjustmentFamily family,

    /// Index into [family]'s adjustments.
    @Default(0) int parameter,

    /// Collection id, or [savedCategory].
    String? category,
  }) = _EditorSession;

  const new _();

  EditState get edit => history.present;
}
