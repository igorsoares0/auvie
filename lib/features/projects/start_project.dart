import 'package:auvie/app/router/routes.dart';
import 'package:auvie/core/models/project.dart';
import 'package:auvie/core/native/media_engine.dart';
import 'package:auvie/features/projects/project_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Opens the editor for [id].
void openProject(BuildContext context, String id, MediaType type) =>
    context.push(switch (type) {
      MediaType.photo => AppRoutes.photoEditor(id),
      MediaType.video => AppRoutes.videoEditor(id),
    });

/// Picks media, creates a project and opens its editor (Home → Photo /
/// Video, Export → NEW PHOTO). Returns false when cancelled or failed.
Future<bool> startProject(
  BuildContext context,
  WidgetRef ref,
  MediaType type,
) async {
  try {
    final project = await ref.read(projectStarterProvider).start(type);
    if (project == null || !context.mounted) return false;
    openProject(context, project.id, type);
    return true;
  } on MediaEngineException {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("That file couldn't be opened.")),
      );
    }
    return false;
  }
}
