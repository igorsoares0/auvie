import 'package:auvie/core/native/android_media_engine.dart';
import 'package:auvie/core/native/media_engine.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'media_engine_provider.g.dart';

@Riverpod(keepAlive: true)
MediaEngine mediaEngine(Ref ref) => AndroidMediaEngine();
