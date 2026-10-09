import 'dart:io';

import 'package:auvie/app/router/routes.dart';
import 'package:auvie/app/theme/app_theme.dart';
import 'package:auvie/app/theme/colors.dart';
import 'package:auvie/app/theme/spacing.dart';
import 'package:auvie/app/theme/typography.dart';
import 'package:auvie/app/widgets/auvie_icon.dart';
import 'package:auvie/app/widgets/caps_link.dart';
import 'package:auvie/app/widgets/emphasis_text.dart';
import 'package:auvie/app/widgets/film_art.dart';
import 'package:auvie/app/widgets/system_bars.dart';
import 'package:auvie/app/widgets/wordmark.dart';
import 'package:auvie/core/content/catalog.dart';
import 'package:auvie/core/content/catalog_providers.dart';
import 'package:auvie/core/models/project.dart';
import 'package:auvie/core/native/media_engine.dart';
import 'package:auvie/core/storage/project_repository.dart';
import 'package:auvie/features/projects/project_providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Home (handoff 01 / S1): two primary actions, recent work as a contact
/// sheet, the current collection at the foot. No tab bar.
class HomeScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _starting = false;

  Future<void> _start(MediaType type) async {
    if (_starting) return;
    setState(() => _starting = true);
    try {
      final project = await ref.read(projectStarterProvider).start(type);
      if (project != null && mounted) _open(project.id, type);
    } on MediaEngineException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("That file couldn't be opened.")),
        );
      }
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  void _open(String id, MediaType type) => context.push(switch (type) {
    MediaType.photo => AppRoutes.photoEditor(id),
    MediaType.video => AppRoutes.videoEditor(id),
  });

  @override
  Widget build(BuildContext context) {
    final recents = ref.watch(recentProjectsProvider).value ?? const [];
    final catalog = ref.watch(catalogProvider).value;
    final empty = recents.isEmpty;

    return SystemBars(
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AuvieSpacing.gutter,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _Header(),
                      const SizedBox(height: AuvieSpacing.s22),
                      EmphasisText(
                        empty
                            ? 'Your first *print* starts here.'
                            : 'What are we *developing* today?',
                        style: context.type.display,
                      ),
                      const SizedBox(height: AuvieSpacing.s28),
                      Row(
                        children: [
                          Expanded(
                            child: _MediaTile(
                              key: const Key('home-photo'),
                              filled: true,
                              icon: AuvieIcons.photo,
                              title: 'Photo',
                              caption: 'From library',
                              onTap: () => _start(MediaType.photo),
                            ),
                          ),
                          const SizedBox(width: AuvieSpacing.s10),
                          Expanded(
                            child: _MediaTile(
                              key: const Key('home-video'),
                              filled: false,
                              icon: AuvieIcons.video,
                              title: 'Video',
                              caption: 'Trim · Grade · Type',
                              onTap: () => _start(MediaType.video),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AuvieSpacing.s34),
                      const Divider(),
                      const SizedBox(height: AuvieSpacing.s14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'RECENT',
                            style: context.type.label.copyWith(
                              color: context.palette.foreground,
                            ),
                          ),
                          Text(
                            empty
                                ? 'NONE YET'
                                : 'ON THIS DEVICE · ${recents.length}',
                            style: context.type.label,
                          ),
                        ],
                      ),
                      const SizedBox(height: AuvieSpacing.s12),
                      if (empty)
                        const _EmptyRecents()
                      else
                        _RecentGrid(
                          recents: recents,
                          catalog: catalog,
                          onOpen: (p) => _open(p.id, p.mediaType),
                        ),
                      if (!kReleaseMode)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: CapsLink(
                            'Engine lab',
                            key: const Key('home-engine-lab'),
                            color: context.palette.muted,
                            onTap: () => context.push(AppRoutes.engineLab),
                          ),
                        ),
                      const SizedBox(height: AuvieSpacing.s14),
                    ],
                  ),
                ),
              ),
              _CollectionFooter(catalog: catalog, firstUse: empty),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final accent = context.palette.accent;
    return SizedBox(
      height: AuvieSpacing.headerHeight,
      child: Row(
        children: [
          const Wordmark(),
          const Spacer(),
          Semantics(
            button: true,
            label: 'Pro',
            child: GestureDetector(
              key: const Key('home-pro'),
              behavior: HitTestBehavior.opaque,
              onTap: () => context.push(AppRoutes.pro),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: DecoratedBox(
                  decoration: BoxDecoration(border: Border.all(color: accent)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    child: Text(
                      'PRO',
                      style: context.type.tag.copyWith(
                        color: accent,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AuvieSpacing.s14),
          CapsLink('Settings', onTap: () => context.push(AppRoutes.settings)),
        ],
      ),
    );
  }
}

class _MediaTile extends StatelessWidget {
  const new({
    required this.filled,
    required this.icon,
    required this.title,
    required this.caption,
    required this.onTap,
    super.key,
  });

  final bool filled;
  final AuvieIcons icon;
  final String title;
  final String caption;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final foreground = filled ? palette.background : palette.foreground;
    return Semantics(
      button: true,
      label: title,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 150,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: filled ? palette.foreground : null,
            border: filled ? null : Border.all(color: palette.foreground),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AuvieIcon(icon, color: foreground),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AuvieTypography.serif(
                      28,
                      height: 1,
                      italic: true,
                      color: foreground,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    caption.toUpperCase(),
                    style: context.type.tag.copyWith(
                      fontSize: 9.5,
                      color: filled ? AuvieColors.mutedDark2 : palette.muted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyRecents extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            for (var i = 0; i < 3; i++) ...[
              if (i > 0) const SizedBox(width: AuvieSpacing.s8),
              Expanded(
                child: SizedBox(
                  height: 118,
                  child: CustomPaint(
                    painter: _DashedBorderPainter(palette.hairlineStrong),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: AuvieSpacing.s14),
        Text(
          'Edits you start will be kept here, exactly where you left them.',
          style: AuvieTypography.serif(
            16,
            height: 1.4,
            italic: true,
            color: palette.foreground3,
          ),
        ),
      ],
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  new(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    const dash = 3.0;
    void line(Offset a, Offset b) {
      final length = (b - a).distance;
      final dir = (b - a) / length;
      for (var d = 0.0; d < length; d += dash * 2) {
        canvas.drawLine(
          a + dir * d,
          a + dir * (d + dash).clamp(0, length),
          paint,
        );
      }
    }

    final r = (Offset.zero & size).deflate(0.5);
    line(r.topLeft, r.topRight);
    line(r.topRight, r.bottomRight);
    line(r.bottomRight, r.bottomLeft);
    line(r.bottomLeft, r.topLeft);
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) => old.color != color;
}

class _RecentGrid extends StatelessWidget {
  const new({
    required this.recents,
    required this.catalog,
    required this.onOpen,
  });

  final List<ProjectSummary> recents;
  final Catalog? catalog;
  final ValueChanged<ProjectSummary> onOpen;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = AuvieSpacing.s8;
        final width = (constraints.maxWidth - gap * 2) / 3;
        return Wrap(
          spacing: gap,
          runSpacing: AuvieSpacing.s18,
          children: [
            for (final project in recents)
              SizedBox(
                width: width,
                child: _RecentCell(
                  project: project,
                  presetName: project.presetId == null
                      ? null
                      : catalog?.presetById(project.presetId!)?.name,
                  onTap: () => onOpen(project),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _RecentCell extends StatelessWidget {
  const new({
    required this.project,
    required this.presetName,
    required this.onTap,
  });

  final ProjectSummary project;
  final String? presetName;
  final VoidCallback onTap;

  static String duration(int ms) {
    final seconds = (ms / 1000).round();
    return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final thumbnail = project.thumbnailPath;
    final kind = project.mediaType == MediaType.photo ? 'PHOTO' : 'VIDEO';
    return Semantics(
      button: true,
      label: project.name ?? kind,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 118,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (thumbnail == null)
                    ColoredBox(color: palette.hairline)
                  else
                    Image.file(
                      File(thumbnail),
                      fit: BoxFit.cover,
                      cacheWidth: 360,
                      errorBuilder: (_, _, _) =>
                          ColoredBox(color: palette.hairline),
                    ),
                  if (project.durationMs case final ms?)
                    Positioned(
                      right: 5,
                      bottom: 5,
                      child: ColoredBox(
                        color: const Color(0xCC161412),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 3,
                          ),
                          child: Text(
                            duration(ms),
                            style: context.type.tag.copyWith(
                              color: palette.background,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AuvieSpacing.s8),
            Text(
              project.name ?? 'Untitled',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AuvieTypography.serif(
                16,
                height: 1.1,
                italic: true,
                color: palette.foreground,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              '$kind · ${(presetName ?? 'Original').toUpperCase()}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.type.tag.copyWith(fontSize: 9.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _CollectionFooter extends StatelessWidget {
  const new({required this.catalog, required this.firstUse});

  final Catalog? catalog;
  final bool firstUse;

  @override
  Widget build(BuildContext context) {
    final collections = catalog?.sortedCollections ?? const [];
    if (collections.isEmpty) return const SizedBox.shrink();
    // The newest collection is the last one in catalog order.
    final collection = collections.last;
    final tone =
        catalog!.presetsIn(collection.id).firstOrNull?.tone ?? FilmArt.nocturne;
    final palette = context.palette;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: palette.hairlineStrong)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AuvieSpacing.gutter,
          vertical: AuvieSpacing.s14,
        ),
        child: Row(
          children: [
            SizedBox(width: 44, height: 44, child: FilmArt(tone: tone)),
            const SizedBox(width: AuvieSpacing.s14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    firstUse ? 'START WITH A COLLECTION' : 'NEW COLLECTION',
                    style: context.type.tag.copyWith(
                      fontSize: 9.5,
                      color: palette.accent,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    collection.name,
                    style: AuvieTypography.serif(
                      22,
                      height: 1,
                      color: palette.foreground,
                    ),
                  ),
                ],
              ),
            ),
            CapsLink(
              'Discover',
              key: const Key('home-discover'),
              onTap: () => context.push(AppRoutes.archive),
            ),
          ],
        ),
      ),
    );
  }
}
