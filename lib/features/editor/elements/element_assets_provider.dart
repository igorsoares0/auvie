import 'package:auvie/core/content/catalog.dart';
import 'package:auvie/core/content/catalog_providers.dart';
import 'package:auvie/features/editor/elements/element_assets.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'element_assets_provider.g.dart';

/// Loads every sticker of [catalog] (drawn white, tinted at paint time).
Future<ElementAssets> loadElementAssets(Catalog catalog) async {
  final stickers = <String, PictureInfo>{};
  for (final asset in catalog.assetsOfType(ContentAssetType.sticker)) {
    stickers[asset.id] = await vg.loadPicture(
      SvgAssetLoader(
        asset.file,
        theme: const SvgTheme(currentColor: Color(0xFFFFFFFF)),
      ),
      null,
    );
  }
  return ElementAssets(catalog: catalog, stickers: stickers);
}

@Riverpod(keepAlive: true)
Future<ElementAssets> elementAssets(Ref ref) async {
  final assets = await loadElementAssets(
    await ref.watch(catalogProvider.future),
  );
  ref.onDispose(() {
    for (final s in assets.stickers.values) {
      s.picture.dispose();
    }
  });
  return assets;
}
