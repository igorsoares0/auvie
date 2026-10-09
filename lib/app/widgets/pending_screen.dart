import 'package:auvie/app/theme/app_theme.dart';
import 'package:auvie/app/theme/spacing.dart';
import 'package:auvie/app/widgets/wordmark.dart';
import 'package:flutter/material.dart';

/// Temporary body for routes whose screen is built in a later milestone.
class PendingScreen extends StatelessWidget {
  const new({
    required this.title,
    required this.milestone,
    super.key,
    this.action,
  });

  final String title;

  /// Milestone that builds this screen (see docs/PLANO-IMPLEMENTACAO-ANDROID.md).
  final String milestone;

  /// Optional link under the title (e.g. to a debug screen).
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AuvieSpacing.gutter),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: AuvieSpacing.headerHeight,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Wordmark(),
                ),
              ),
              const Spacer(),
              Text(title, style: context.type.display),
              const SizedBox(height: AuvieSpacing.s12),
              Text(
                'IN PROGRESS · $milestone'.toUpperCase(),
                style: context.type.label,
              ),
              ?action,
              const SizedBox(height: AuvieSpacing.s34),
            ],
          ),
        ),
      ),
    );
  }
}
