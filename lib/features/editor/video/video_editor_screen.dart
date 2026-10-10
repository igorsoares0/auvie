import 'package:auvie/features/editor/shell/editor_screen.dart';
import 'package:flutter/material.dart';

/// The video editor (handoff 05): [EditorScreen] on a video project, with
/// the transport row and the TRIM timeline.
class VideoEditorScreen extends StatelessWidget {
  const new({required this.projectId, super.key});

  final String projectId;

  @override
  Widget build(BuildContext context) => EditorScreen(projectId: projectId);
}
