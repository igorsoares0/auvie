import 'dart:typed_data';

import 'package:auvie/core/native/media_engine_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'video_media_providers.g.dart';

/// A missing or unreadable video won't appear by retrying.
Duration? _noRetry(int retryCount, Object error) => null;

/// Frames of the FILM strip, spread evenly over the whole clip.
@Riverpod(retry: _noRetry)
Future<List<Uint8List>> filmFrames(Ref ref, String uri, int count) =>
    ref.read(mediaEngineProvider).videoFrames(uri, count: count, maxPx: 160);

/// Slices of the SOUND lane's waveform.
const soundBuckets = 120;

/// The SOUND lane's waveform; null when the video has no sound.
@Riverpod(retry: _noRetry)
Future<List<double>?> soundWave(Ref ref, String uri) =>
    ref.read(mediaEngineProvider).waveform(uri, buckets: soundBuckets);
