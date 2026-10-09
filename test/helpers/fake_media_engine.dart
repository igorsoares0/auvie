import 'dart:typed_data';

import 'package:auvie/core/models/project.dart';
import 'package:auvie/core/native/media_engine.dart';
import 'package:auvie/core/native/render_params.dart';

/// A valid 1×1 PNG, so widgets decoding the engine's images don't fail.
final onePixelPng = Uint8List.fromList(const [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, //
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, //
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, //
  0x0D, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0xF8, 0xCF, 0xC0, 0xF0, //
  0x1F, 0x00, 0x05, 0x00, 0x01, 0xFF, 0x89, 0x99, 0x3D, 0x1D, 0x00, 0x00, //
  0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]);

/// In-memory [MediaEngine] that records what the UI asked for.
class FakeMediaEngine implements MediaEngine {
  new({this.picked, this.previewSize = (width: 400, height: 300)});

  /// What [pickMedia] returns (null = the user cancelled).
  MediaRef? picked;
  ({int width, int height}) previewSize;

  final calls = <String>[];
  final updates = <(int, RenderParams)>[];
  final showOriginal = <bool>[];
  final disposed = <int>[];
  final renders = <RenderParams>[];
  var _nextTexture = 1;

  @override
  Future<MediaRef?> pickMedia(MediaType type) async {
    calls.add('pickMedia(${type.name})');
    return picked;
  }

  @override
  Future<MediaRef> probe(String uri) async {
    calls.add('probe($uri)');
    return picked!;
  }

  @override
  Future<Uint8List> thumbnail(String uri, {required int maxPx}) async {
    calls.add('thumbnail($uri, $maxPx)');
    return onePixelPng;
  }

  @override
  Future<PhotoPreview> createPhotoPreview(
    String uri, {
    required int maxPx,
  }) async {
    calls.add('createPhotoPreview($uri, $maxPx)');
    return (
      textureId: _nextTexture++,
      width: previewSize.width,
      height: previewSize.height,
    );
  }

  @override
  Future<void> updateEdit(int textureId, RenderParams params) async {
    updates.add((textureId, params));
  }

  @override
  Future<void> setShowOriginal(int textureId, {required bool original}) async {
    showOriginal.add(original);
  }

  @override
  Future<void> disposePreview(int textureId) async {
    disposed.add(textureId);
  }

  @override
  Future<Uint8List> renderPhoto(
    String uri,
    RenderParams params, {
    required int maxPx,
  }) async {
    calls.add('renderPhoto($uri, $maxPx)');
    renders.add(params);
    return onePixelPng;
  }
}
