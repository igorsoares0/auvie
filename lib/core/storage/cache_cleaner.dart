import 'dart:io';

import 'package:auvie/core/storage/app_paths.dart';
import 'package:path/path.dart' as p;

/// What the app keeps that can be thrown away (Settings → STORAGE): the
/// app's copies of exports (kept for sharing; the gallery has its own) and
/// element layers left behind by an interrupted export. Projects and their
/// thumbnails are never touched.
class CacheCleaner {
  new(this._paths, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final Future<AppPaths> _paths;
  final DateTime Function() _clock;

  /// Files this recent may belong to an export still running.
  static const busyWindow = Duration(minutes: 10);

  Future<List<Directory>> _dirs() async {
    final paths = await _paths;
    return [paths.exports, Directory(p.join(paths.cache.path, 'layers'))];
  }

  Future<List<File>> _files() async => [
    for (final dir in await _dirs())
      if (dir.existsSync()) ...dir.listSync(recursive: true).whereType<File>(),
  ];

  /// Bytes that [clear] could free.
  Future<int> size() async {
    var total = 0;
    for (final file in await _files()) {
      total += file.lengthSync();
    }
    return total;
  }

  /// Deletes every cached file not touched within [busyWindow] (an export
  /// may be writing it). Returns the bytes freed.
  Future<int> clear() => _deleteOlderThan(busyWindow);

  /// Startup housekeeping: what an interrupted export left over a day ago.
  Future<int> cleanStale() => _deleteOlderThan(const Duration(days: 1));

  Future<int> _deleteOlderThan(Duration age) async {
    final cutoff = _clock().subtract(age);
    var freed = 0;
    for (final file in await _files()) {
      try {
        if (file.lastModifiedSync().isBefore(cutoff)) {
          final length = file.lengthSync();
          file.deleteSync();
          freed += length;
        }
      } on FileSystemException {
        // Gone already, or in use: skip it.
      }
    }
    for (final dir in await _dirs()) {
      if (!dir.existsSync()) continue;
      for (final sub in dir.listSync().whereType<Directory>()) {
        if (sub.listSync(recursive: true).whereType<File>().isEmpty) {
          sub.deleteSync(recursive: true);
        }
      }
    }
    return freed;
  }
}
