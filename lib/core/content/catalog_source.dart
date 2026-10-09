import 'dart:convert';

import 'package:auvie/core/content/catalog.dart';
import 'package:flutter/services.dart';

/// Where the catalog comes from. Bundled now; remote in M8 (spec §46).
abstract interface class CatalogSource {
  Future<Catalog> load();
}

class CatalogLoadException implements Exception {
  const new(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() =>
      'CatalogLoadException: $message${cause == null ? '' : ' ($cause)'}';
}

/// The catalog shipped inside the app (`assets/content/catalog.json`).
class BundledCatalogSource implements CatalogSource {
  const new(this._bundle, {this.path = defaultPath});

  static const defaultPath = 'assets/content/catalog.json';

  final AssetBundle _bundle;
  final String path;

  @override
  Future<Catalog> load() async {
    final Catalog catalog;
    try {
      final source = await _bundle.loadString(path);
      catalog = Catalog.fromJson(jsonDecode(source) as Map<String, dynamic>);
    } on Object catch (e) {
      throw CatalogLoadException('Could not read $path', e);
    }
    final issues = catalog.validate();
    if (issues.isNotEmpty) {
      throw CatalogLoadException('Invalid catalog: ${issues.join('; ')}');
    }
    return catalog;
  }
}
