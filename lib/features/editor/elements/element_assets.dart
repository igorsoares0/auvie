import 'package:auvie/core/content/catalog.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// What drawing elements needs from content: loaded sticker pictures and
/// the catalog entries of overlays and frames.
class ElementAssets {
  const new({required this.catalog, this.stickers = const {}});

  final Catalog catalog;

  /// Sticker asset id → picture drawn in white (tinted when drawn).
  final Map<String, PictureInfo> stickers;

  /// Width / height of a sticker's artwork.
  double stickerRatio(String assetId) {
    final size = stickers[assetId]?.size;
    if (size == null || size.height == 0) return 1;
    return size.width / size.height;
  }

  Map<String, Object?> params(String assetId) =>
      catalog.assetById(assetId)?.params ?? const {};
}
