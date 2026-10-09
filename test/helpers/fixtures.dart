import 'package:auvie/core/models/adjustment.dart';
import 'package:auvie/core/models/adjustments.dart';
import 'package:auvie/core/models/crop.dart';
import 'package:auvie/core/models/edit_state.dart';
import 'package:auvie/core/models/elements.dart';
import 'package:auvie/core/models/preset.dart';
import 'package:auvie/core/models/project.dart';
import 'package:auvie/core/models/tone_curve.dart';
import 'package:auvie/core/models/video_timeline.dart';

const photoMedia = MediaRef(
  uri: 'content://media/picker/0/photo/1',
  type: MediaType.photo,
  width: 4000,
  height: 3000,
);

const videoMedia = MediaRef(
  uri: 'content://media/picker/0/video/2',
  type: MediaType.video,
  width: 1080,
  height: 1920,
  durationMs: 10000,
);

/// One element of every type, with non-default values.
final allElements = <EditElement>[
  const EditElement.text(
    id: 't1',
    text: 'Summer, 1998',
    style: TextStyleSpec(
      fontFamily: 'Jost',
      fontWeight: 500,
      italic: true,
      align: TextAlignment.left,
      letterSpacing: 0.1,
      shadow: TextShadowSpec(),
      outline: TextOutlineSpec(width: 0.002),
      background: TextBackgroundSpec(color: 0xFF161412),
    ),
    textPresetId: 'editorial',
    transform: ElementTransform(x: 0.3, y: 0.7, scale: 1.5, rotation: 0.2),
    opacity: 0.9,
    time: TimeRange(startMs: 1000, endMs: 4000),
  ),
  const EditElement.textPath(
    id: 'tp1',
    text: 'along the line',
    path: [
      StrokePoint(x: 0.1, y: 0.5),
      StrokePoint(x: 0.5, y: 0.4),
      StrokePoint(x: 0.9, y: 0.5),
    ],
  ),
  const EditElement.brush(
    id: 'b1',
    brushType: BrushType.chalk,
    size: 0.02,
    color: 0xFFE0573C,
    strokes: [
      BrushStroke(
        points: [
          StrokePoint(x: 0.2, y: 0.2, pressure: 0.4),
          StrokePoint(x: 0.3, y: 0.25, pressure: 0.6),
        ],
      ),
    ],
  ),
  const EditElement.sticker(id: 's1', assetId: 'star', opacity: 0.8),
  const EditElement.overlay(
    id: 'o1',
    assetId: 'leak_01',
    blend: OverlayBlend.softLight,
    opacity: 0.6,
  ),
  const EditElement.frame(id: 'f1', assetId: 'border_white'),
];

EditState richEdit() => EditState(
  adjustments: Adjustments.of(const {
    Adjustment.exposure: 0.2,
    Adjustment.grain: 0.3,
  }),
  curves: const ToneCurves(
    master: ToneCurve(
      points: [CurvePoint(x: 0, y: 0.05), CurvePoint(x: 1, y: 1)],
    ),
  ),
  preset: const PresetRef(presetId: 'ektar_02', intensity: 0.72),
  crop: const CropTransform(
    aspect: CropAspect.square,
    rect: NormalizedRect(left: 0.125, width: 0.75),
    quarterTurns: 1,
    straighten: 3.5,
    flipHorizontal: true,
  ),
  elements: allElements,
  video: const VideoTimeline(trimStartMs: 500, trimEndMs: 8000, muted: true),
);

Project richProject() => Project(
  id: 'project-1',
  media: videoMedia,
  createdAt: DateTime.utc(2026, 10, 8, 12),
  updatedAt: DateTime.utc(2026, 10, 8, 12, 30, 15, 250),
  edit: richEdit(),
  name: 'Roll 014',
);
