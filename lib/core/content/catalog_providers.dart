import 'package:auvie/core/content/catalog.dart';
import 'package:auvie/core/content/catalog_source.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'catalog_providers.g.dart';

@Riverpod(keepAlive: true)
CatalogSource catalogSource(Ref ref) => BundledCatalogSource(rootBundle);

@Riverpod(keepAlive: true)
Future<Catalog> catalog(Ref ref) => ref.watch(catalogSourceProvider).load();
