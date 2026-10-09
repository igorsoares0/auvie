import 'package:auvie/core/platform/share_service.dart';

/// Records shared files instead of opening the share sheet.
class FakeShareService implements ShareService {
  final shared = <String>[];

  @override
  Future<void> shareFile(String path, {String? mimeType}) async {
    shared.add(path);
  }
}
