import 'package:auvie/app/widgets/pending_screen.dart';
import 'package:flutter/material.dart';

class VideoEditorScreen extends StatelessWidget {
  const new({required this.projectId, super.key});

  final String projectId;

  @override
  Widget build(BuildContext context) {
    return const PendingScreen(title: 'Video editor', milestone: 'M6');
  }
}
