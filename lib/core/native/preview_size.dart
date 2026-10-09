import 'dart:math' as math;
import 'dart:ui';

import 'package:auvie/core/models/project.dart';

/// Longer side, in physical pixels, at which [media] appears when fitted
/// inside [box].
///
/// Previews render at exactly this size: per-pixel effects (sharpen, grain)
/// then look on screen as they were computed instead of being averaged away
/// by scaling, and the GPU spends no time on pixels the screen can't show.
/// Never above the original's size.
int previewMaxPx({
  required MediaRef media,
  required Size box,
  required double devicePixelRatio,
}) {
  const minimum = 256;
  final original = math.max(media.width, media.height);
  if (box.isEmpty) return math.min(minimum, original);
  final scale = math.min(box.width / media.width, box.height / media.height);
  final shown = (original * scale * devicePixelRatio).round();
  return shown.clamp(math.min(minimum, original), original);
}

/// Pixel size of an image of [aspectRatio] (width / height) fitted inside
/// [box]: the size a preview renders at so it maps 1:1 to the screen.
({int width, int height}) previewPixelSize({
  required double aspectRatio,
  required Size box,
  required double devicePixelRatio,
}) {
  if (box.isEmpty) return (width: 1, height: 1);
  final boxRatio = box.width / box.height;
  final (w, h) = aspectRatio > boxRatio
      ? (box.width, box.width / aspectRatio)
      : (box.height * aspectRatio, box.height);
  return (
    width: math.max(1, (w * devicePixelRatio).round()),
    height: math.max(1, (h * devicePixelRatio).round()),
  );
}
