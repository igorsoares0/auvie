import 'package:auvie/features/editor/shell/editor_screen.dart';
import 'package:flutter/material.dart';

/// The photo editor: [EditorScreen] on a photo project.
class PhotoEditorScreen extends StatelessWidget {
  const new({required this.projectId, super.key});

  final String projectId;

  @override
  Widget build(BuildContext context) => EditorScreen(projectId: projectId);
}
