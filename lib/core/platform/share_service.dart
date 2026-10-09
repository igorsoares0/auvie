import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';

part 'share_service.g.dart';

/// The system share sheet, behind an interface so tests can record shares.
abstract interface class ShareService {
  Future<void> shareFile(String path, {String? mimeType});
}

class SharePlusService implements ShareService {
  const new();

  @override
  Future<void> shareFile(String path, {String? mimeType}) async {
    await SharePlus.instance.share(
      ShareParams(files: [XFile(path, mimeType: mimeType)]),
    );
  }
}

@Riverpod(keepAlive: true)
ShareService shareService(Ref ref) => const SharePlusService();
