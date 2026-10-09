import 'package:auvie/core/models/elements.dart';
import 'package:auvie/features/editor/elements/brush_renderer.dart';
import 'package:auvie/features/editor/elements/element_assets.dart';
import 'package:auvie/features/editor/elements/element_geometry.dart';
import 'package:auvie/features/editor/elements/frame_renderer.dart';
import 'package:auvie/features/editor/elements/overlay_renderer.dart';
import 'package:auvie/features/editor/elements/text_renderer.dart';
import 'package:auvie/features/editor/text/path_text_painter.dart';
import 'package:flutter/rendering.dart';

/// Blend mode of an element when composited over the photo.
BlendMode blendOf(EditElement element) => switch (element) {
  OverlayElement(:final blend) => switch (blend) {
    OverlayBlend.screen => BlendMode.screen,
    OverlayBlend.multiply => BlendMode.multiply,
    OverlayBlend.overlay => BlendMode.overlay,
    OverlayBlend.softLight => BlendMode.softLight,
    OverlayBlend.normal => BlendMode.srcOver,
  },
  _ => BlendMode.srcOver,
};

double opacityOf(EditElement element) => switch (element) {
  TextElement(:final opacity) ||
  TextPathElement(:final opacity) ||
  BrushElement(:final opacity) ||
  StickerElement(:final opacity) ||
  OverlayElement(:final opacity) => opacity.clamp(0, 1).toDouble(),
  FrameElement() => 1,
};

/// Draws elements over the photo — the one implementation behind the
/// preview, thumbnails and exports (spec §18–26).
abstract final class ElementDrawing {
  /// Draws [element]'s content without its opacity and blend (exports
  /// apply those when compositing; [paintAll] applies them here).
  static void paintContent(
    Canvas canvas,
    EditElement element,
    Size size,
    ElementAssets assets,
  ) {
    final frame = ElementGeometry.of(element, size, assets);
    canvas.save();
    frame?.transform(canvas);
    switch (element) {
      case final TextElement e:
        TextRenderer.paint(canvas, e.text, e.style, size);
      case final TextPathElement e:
        canvas.translate(-frame!.pivot.dx, -frame.pivot.dy);
        PathTextPainter(
          text: e.style.uppercase ? e.text.toUpperCase() : e.text,
          style: TextRenderer.textStyle(e.style, size),
          points: [
            for (final p in e.path) Offset(p.x * size.width, p.y * size.height),
          ],
        ).paint(canvas, size);
      case final BrushElement e:
        BrushRenderer.paintElement(canvas, e, size, origin: frame!.pivot);
      case final StickerElement e:
        final picture = assets.stickers[e.assetId];
        if (picture != null) {
          final box = frame!.local;
          canvas
            ..saveLayer(
              box,
              Paint()
                ..colorFilter = ColorFilter.mode(
                  Color(e.color),
                  BlendMode.srcIn,
                ),
            )
            ..translate(box.left, box.top)
            ..scale(
              box.width / picture.size.width,
              box.height / picture.size.height,
            )
            ..drawPicture(picture.picture)
            ..restore();
        }
      case final OverlayElement e:
        OverlayRenderer.paint(
          canvas,
          size,
          assets.params(e.assetId),
          seed: e.id,
        );
      case final FrameElement e:
        FrameRenderer.paint(canvas, size, assets.params(e.assetId));
    }
    canvas.restore();
  }

  /// Draws all [elements] in z-order, each with its opacity and blend.
  static void paintAll(
    Canvas canvas,
    List<EditElement> elements,
    Size size,
    ElementAssets assets, {
    String? hidden,
  }) {
    final all = Offset.zero & size;
    canvas
      ..save()
      ..clipRect(all);
    for (final element in elements) {
      if (element.id == hidden) continue;
      final opacity = opacityOf(element);
      final blend = blendOf(element);
      final layered = opacity < 1 || blend != BlendMode.srcOver;
      if (layered) {
        canvas.saveLayer(
          all,
          Paint()
            ..color = Color.fromRGBO(0, 0, 0, opacity)
            ..blendMode = blend,
        );
      }
      paintContent(canvas, element, size, assets);
      if (layered) canvas.restore();
    }
    canvas.restore();
  }
}

class ElementsPainter extends CustomPainter {
  new({required this.elements, required this.assets, this.hidden});

  final List<EditElement> elements;
  final ElementAssets assets;

  /// Element not drawn (being edited elsewhere).
  final String? hidden;

  @override
  void paint(Canvas canvas, Size size) =>
      ElementDrawing.paintAll(canvas, elements, size, assets, hidden: hidden);

  @override
  bool shouldRepaint(ElementsPainter old) =>
      old.elements != elements || old.assets != assets || old.hidden != hidden;
}
