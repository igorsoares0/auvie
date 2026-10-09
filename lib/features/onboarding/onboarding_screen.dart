import 'package:auvie/app/router/routes.dart';
import 'package:auvie/app/settings/app_settings.dart';
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
import 'package:auvie/features/editor/text/path_text_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// First launch: O1 cover, O2 film, O3 type, O4 access (handoff §Onboarding).
///
/// Android's Photo Picker needs no gallery permission, so O4 explains that
/// instead of asking for access, and there is no "no access" state.
class OnboardingScreen extends ConsumerStatefulWidget {
  const new({super.key});

  /// Pages after the cover, each with a progress mark.
  static const storyPages = 3;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pages = PageController();

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  Future<void> _next() => _pages.nextPage(
    duration: const Duration(milliseconds: 320),
    curve: Curves.easeOut,
  );

  Future<void> _finish() async {
    await ref.read(appSettingsProvider).markOnboardingSeen();
    if (mounted) context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pages,
      children: [
        _Cover(onBegin: _next, onHavePro: () => context.push(AppRoutes.pro)),
        _StoryPage(
          index: 0,
          onSkip: _finish,
          onNext: _next,
          art: const _FilmComparison(),
          eyebrow: 'I — Film',
          headline: 'Develop with *real emulsions,* not filters.',
          body:
              'Every preset is modelled on a film stock. Try any of them on '
              'your own photo before you decide.',
        ),
        _StoryPage(
          index: 1,
          onSkip: _finish,
          onNext: _next,
          art: const _TypeDemo(),
          eyebrow: 'II — Type & film',
          headline: 'Write *along a line* you draw.',
          body:
              'Text Brush, a proper type library, and the same tools for your '
              'videos.',
        ),
        _AccessPage(onContinue: _finish),
      ],
    );
  }
}

/// A column that fills the screen (so [Spacer]s work) and scrolls when the
/// screen is too short for it.
class _FillOrScroll extends StatelessWidget {
  const new({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AuvieSpacing.gutter),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}

/// O1: full-bleed, always dark.
class _Cover extends StatelessWidget {
  const new({required this.onBegin, required this.onHavePro});

  final VoidCallback onBegin;
  final VoidCallback onHavePro;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AuvieTheme.darkroom(),
      child: SystemBars(
        child: Builder(
          builder: (context) {
            final palette = context.palette;
            return Scaffold(
              body: Stack(
                fit: StackFit.expand,
                children: [
                  const FilmArt(tone: FilmArt.ektar, seed: 7),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x00161412), Color(0xEB161412)],
                        stops: [0.35, 1],
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AuvieSpacing.gutter,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: AuvieSpacing.s18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Nº 01',
                                style: context.type.tag.copyWith(
                                  color: palette.foreground,
                                ),
                              ),
                              Text(
                                'PHOTO · FILM · TYPE',
                                style: context.type.tag.copyWith(
                                  color: palette.foreground,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Text('Auvie', style: context.type.coverTitle),
                          const SizedBox(height: AuvieSpacing.s14),
                          Text(
                            'A darkroom for the photographs and films on '
                            'your phone.',
                            style: AuvieTypography.serif(
                              17,
                              height: 1.35,
                              italic: true,
                              color: palette.foreground,
                            ),
                          ),
                          const SizedBox(height: AuvieSpacing.s22),
                          FilledButton(
                            onPressed: onBegin,
                            child: const Text('BEGIN'),
                          ),
                          const SizedBox(height: AuvieSpacing.s6),
                          TextButton(
                            onPressed: onHavePro,
                            style: TextButton.styleFrom(
                              minimumSize: const Size.fromHeight(
                                AuvieSpacing.ghostButtonHeight,
                              ),
                              foregroundColor: palette.foreground,
                            ),
                            child: const Text('I ALREADY HAVE PRO'),
                          ),
                          const SizedBox(height: AuvieSpacing.s12),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const new({this.onSkip});

  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AuvieSpacing.headerHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Wordmark(),
          if (onSkip != null) CapsLink('Skip', onTap: onSkip),
        ],
      ),
    );
  }
}

/// Active mark 18×2, inactive 6×2 at 30%.
class ProgressMarks extends StatelessWidget {
  const new({required this.count, required this.active, super.key});

  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    final color = context.palette.foreground;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < count; i++)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Container(
              key: i == active ? const Key('progress-active') : null,
              width: i == active ? 18 : 6,
              height: 2,
              color: i == active ? color : color.withValues(alpha: 0.3),
            ),
          ),
      ],
    );
  }
}

class _StoryText extends StatelessWidget {
  const new({required this.eyebrow, required this.headline, this.body});

  final String eyebrow;
  final String headline;
  final String? body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(eyebrow.toUpperCase(), style: context.type.tag),
        const SizedBox(height: AuvieSpacing.s12),
        EmphasisText(
          headline,
          style: context.type.display.copyWith(fontSize: 34),
        ),
        if (body != null) ...[
          const SizedBox(height: AuvieSpacing.s14),
          Text(body!, style: context.type.body),
        ],
      ],
    );
  }
}

/// O2, O3: art, story, progress and NEXT.
class _StoryPage extends StatelessWidget {
  const new({
    required this.index,
    required this.onSkip,
    required this.onNext,
    required this.art,
    required this.eyebrow,
    required this.headline,
    required this.body,
  });

  final int index;
  final VoidCallback onSkip;
  final VoidCallback onNext;
  final Widget art;
  final String eyebrow;
  final String headline;
  final String body;

  @override
  Widget build(BuildContext context) {
    return SystemBars(
      child: Scaffold(
        body: SafeArea(
          child: _FillOrScroll(
            children: [
              _PageHeader(onSkip: onSkip),
              const SizedBox(height: AuvieSpacing.s14),
              art,
              const SizedBox(height: AuvieSpacing.s28),
              _StoryText(eyebrow: eyebrow, headline: headline, body: body),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ProgressMarks(
                    count: OnboardingScreen.storyPages,
                    active: index,
                  ),
                  CapsLink(
                    'Next',
                    onTap: onNext,
                    trailing: const AuvieIcon(AuvieIcons.arrow, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: AuvieSpacing.s12),
            ],
          ),
        ),
      ),
    );
  }
}

/// O2 art: the same frame as Original / Ektar / Cendre.
class _FilmComparison extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    const columns = [
      ('Original', FilmArt.ektar, null),
      ('Ektar · 02', FilmArt.ektar, _warm),
      ('Cendre · 11', FilmArt.cendre, null),
    ];
    return SizedBox(
      height: 300,
      child: Row(
        children: [
          for (final (i, (caption, tone, filter)) in columns.indexed) ...[
            if (i > 0) const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: filter == null
                        ? FilmArt(tone: tone, seed: 3)
                        : ColorFiltered(
                            colorFilter: filter,
                            child: FilmArt(tone: tone, seed: 3),
                          ),
                  ),
                  const SizedBox(height: AuvieSpacing.s8),
                  Text(caption.toUpperCase(), style: context.type.tag),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  static const _warm = ColorFilter.matrix([
    1.1, 0, 0, 0, 8, //
    0, 1.0, 0, 0, 0, //
    0, 0, 0.85, 0, 0, //
    0, 0, 0, 1, 0,
  ]);
}

/// O3 art: a frame with text written along a drawn line.
class _TypeDemo extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const FilmArt(tone: FilmArt.nocturne, seed: 11),
          LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final h = constraints.maxHeight;
              return CustomPaint(
                painter: PathTextPainter(
                  text: 'the long summer, Riviera —',
                  style: AuvieTypography.serif(
                    20,
                    italic: true,
                    color: AuvieColors.bone,
                  ),
                  points: [
                    Offset(w * 0.06, h * 0.72),
                    Offset(w * 0.3, h * 0.58),
                    Offset(w * 0.55, h * 0.62),
                    Offset(w * 0.8, h * 0.46),
                    Offset(w * 0.95, h * 0.4),
                  ],
                  guide: AuvieColors.bone.withValues(alpha: 0.6),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// O4, adapted to Android: the system picker needs no permission.
class _AccessPage extends StatelessWidget {
  const new({required this.onContinue});

  final VoidCallback onContinue;

  static const _promises = [
    ('i', 'Edits stay on your phone', 'Nothing is uploaded'),
    ('ii', 'You pick each photo', 'No access to your gallery'),
    ('iii', 'Originals are never altered', 'Every edit is a copy'),
  ];

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return SystemBars(
      child: Scaffold(
        body: SafeArea(
          child: _FillOrScroll(
            children: [
              const _PageHeader(),
              const SizedBox(height: AuvieSpacing.s14),
              SizedBox(
                height: 120,
                child: GridView.count(
                  crossAxisCount: 4,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    for (var i = 0; i < 8; i++)
                      Opacity(
                        opacity: i < 3 ? 1 : 0.25,
                        child: FilmArt(
                          tone: [
                            FilmArt.ektar,
                            FilmArt.nocturne,
                            FilmArt.cendre,
                          ][i % 3],
                          seed: i,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AuvieSpacing.s28),
              const _StoryText(
                eyebrow: 'III — Your library',
                headline: 'Auvie only sees *what you choose.*',
              ),
              const SizedBox(height: AuvieSpacing.s18),
              for (final (numeral, title, detail) in _promises)
                DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: palette.hairline)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AuvieSpacing.s10,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 28,
                          child: Text(
                            numeral,
                            style: AuvieTypography.serif(
                              14,
                              italic: true,
                              color: palette.muted,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title, style: context.type.itemName),
                              const SizedBox(height: 2),
                              Text(
                                detail.toUpperCase(),
                                style: context.type.tag,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const Spacer(),
              FilledButton(
                onPressed: onContinue,
                child: const Text('CONTINUE'),
              ),
              const SizedBox(height: AuvieSpacing.s12),
            ],
          ),
        ),
      ),
    );
  }
}
