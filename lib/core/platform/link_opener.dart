import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:url_launcher/url_launcher.dart';

part 'link_opener.g.dart';

/// Terms of use and privacy policy. Provisional until the site exists (M9).
final Uri termsUrl = Uri.parse('https://auvie.app/terms');
final Uri privacyUrl = Uri.parse('https://auvie.app/privacy');

/// Opens web pages outside the app, behind an interface so tests can record
/// them.
abstract interface class LinkOpener {
  /// False when nothing could open [url].
  Future<bool> open(Uri url);
}

class UrlLauncherOpener implements LinkOpener {
  const new();

  @override
  Future<bool> open(Uri url) =>
      launchUrl(url, mode: LaunchMode.externalApplication);
}

@Riverpod(keepAlive: true)
LinkOpener linkOpener(Ref ref) => const UrlLauncherOpener();
