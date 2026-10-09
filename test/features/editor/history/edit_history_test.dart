import 'package:auvie/features/editor/history/edit_history.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('starts with nothing to undo or redo', () {
    final history = EditHistory(0);
    expect(history.present, 0);
    expect(history.canUndo, isFalse);
    expect(history.canRedo, isFalse);
    expect(history.undo().present, 0);
    expect(history.redo().present, 0);
  });

  test('undoes and redoes recorded states', () {
    final history = EditHistory(0).record(1).record(2);

    final undone = history.undo();
    expect(undone.present, 1);
    expect(undone.canRedo, isTrue);

    expect(undone.undo().present, 0);
    expect(undone.undo().canUndo, isFalse);
    expect(undone.redo().present, 2);
  });

  test('ignores recording an equal state', () {
    final history = EditHistory(0).record(1).record(1);
    expect(history.undo().present, 0);
  });

  test('recording after an undo drops the redo branch', () {
    final history = EditHistory(0).record(1).undo().record(5);
    expect(history.canRedo, isFalse);
    expect(history.undo().present, 0);
  });

  group('gestures', () {
    test('previews then commit make one undo step', () {
      final history = EditHistory(0).preview(1).preview(2).preview(3).commit();
      expect(history.present, 3);
      expect(history.undo().present, 0);
      expect(history.undo().canUndo, isFalse);
    });

    test('undo during a gesture returns to before the gesture', () {
      final history = EditHistory(0).record(1).preview(2).preview(3);
      expect(history.canUndo, isTrue);
      expect(history.canRedo, isFalse);

      final undone = history.undo();
      expect(undone.present, 1);
      expect(undone.redo().present, 3);
    });

    test('a gesture that ends where it started adds no step', () {
      final history = EditHistory(0).record(1).preview(2).preview(1).commit();
      expect(history.undo().present, 0);
    });

    test('recording during a gesture commits the gesture first', () {
      final history = EditHistory(0).preview(1).record(2);
      expect(history.undo().present, 1);
      expect(history.undo().undo().present, 0);
    });

    test('commit without previews does nothing', () {
      final history = EditHistory(0).record(1);
      expect(history.commit().undo().present, 0);
    });

    test('a new gesture after undo drops the redo branch', () {
      final history = EditHistory(0).record(1).undo().preview(7).commit();
      expect(history.canRedo, isFalse);
      expect(history.undo().present, 0);
    });
  });

  test('keeps at most `limit` undo steps', () {
    var history = EditHistory(0, limit: 3);
    for (var i = 1; i <= 5; i++) {
      history = history.record(i);
    }
    var steps = 0;
    while (history.canUndo) {
      history = history.undo();
      steps++;
    }
    expect(steps, 3);
    expect(history.present, 2);
  });

  test('the limit also applies to gestures and redo', () {
    var history = EditHistory(0, limit: 2).record(1).record(2);
    history = history.preview(3).commit();
    expect(history.undo().undo().canUndo, isFalse);

    history = history.undo().redo();
    expect(history.present, 3);
    expect(history.undo().undo().canUndo, isFalse);
  });
}
