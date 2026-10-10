import 'package:auvie/core/models/edit_state.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'project.freezed.dart';
part 'project.g.dart';

enum MediaType { photo, video }

/// Reference to the user's original media, which is never modified.
@freezed
abstract class MediaRef with _$MediaRef {
  const factory({
    /// Persistable content:// URI from the Android Photo Picker.
    required String uri,
    required MediaType type,

    /// Size after EXIF / container rotation is applied.
    required int width,
    required int height,

    /// Videos only.
    int? durationMs,
  }) = _MediaRef;

  const new _();

  factory fromJson(Map<String, dynamic> json) => _$MediaRefFromJson(json);

  double get aspectRatio => width / height;
}

/// A local, non-destructive edit of one photo or video (spec §9).
@freezed
abstract class Project with _$Project {
  const factory({
    required String id,
    required MediaRef media,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(EditState()) EditState edit,
    String? name,
  }) = _Project;

  factory fromJson(Map<String, dynamic> json) => _$ProjectFromJson(json);
}

/// The video frame that stands for a project (thumbnails, Export): the
/// first frame kept by the trim. 0 for photos.
int posterTimeMs(Project project) => project.edit.video?.trimStartMs ?? 0;
