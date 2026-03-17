import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../domain/index.dart' show PipelineStage, StageTypeX;

class PipelineContent extends StatelessWidget {
  const PipelineContent({
    super.key,
    required this.pipeline,
    required this.theme,
  });

  final List<PipelineStage> pipeline;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    if (pipeline.isEmpty) return _EmptyState(theme: theme);

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor,
              spreadRadius: 1,
              blurRadius: 3,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Page heading ────────────────────────────────────────────────
            _PageHeading(
              count: pipeline.length,
              colorScheme: cs,
              textTheme: tt,
            ),

            const SizedBox(height: 16),

            // ── Timeline ────────────────────────────────────────────────────
            ...List.generate(
              pipeline.length,
              (i) => _TimelineItem(
                stage: pipeline[i],
                index: i,
                total: pipeline.length,
                colorScheme: cs,
                textTheme: tt,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Page heading  (mirrors Job Details "big title" energy)
// ---------------------------------------------------------------------------

class _PageHeading extends StatelessWidget {
  const _PageHeading({
    required this.count,
    required this.colorScheme,
    required this.textTheme,
  });

  final int count;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final tt = textTheme;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset(
              'assets/icons/common/solid/ic-material-account-tree.svg',
              width: 16,
              colorFilter:
                  ColorFilter.mode(theme.disabledColor, BlendMode.srcIn),
            ),
            const SizedBox(width: 6),
            Text(
              'Hiring pipeline',
              style: tt.labelMedium?.copyWith(
                color: theme.disabledColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '$count',
              style: tt.displayMedium,
            ),
            const SizedBox(width: 5),
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                count == 1 ? 'stage' : 'stages',
                style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        Text('Candidates progress through each stage in sequence.',
            style: tt.bodySmall),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Timeline item
// ---------------------------------------------------------------------------

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.stage,
    required this.index,
    required this.total,
    required this.colorScheme,
    required this.textTheme,
  });

  final PipelineStage stage;
  final int index;
  final int total;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  bool get isFirst => index == 0;
  bool get isLast => index == total - 1;

  @override
  Widget build(BuildContext context) {
    final cs = colorScheme;
    final tt = textTheme;
    final accent = stage.type.resolvedAccent(cs);
    final bg = stage.type.resolvedColor(cs);
    final theme = Theme.of(context);

    const double railW = 44.0;
    const double nodeSize = 36.0;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Left rail ──────────────────────────────────────────────────
          SizedBox(
            width: railW,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                // Connector line
                if (!isLast)
                  Positioned(
                    top: nodeSize,
                    bottom: 0,
                    left: (railW / 2) - 1,
                    child: Container(
                      width: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            accent.withValues(alpha: 0.40),
                            theme.cardColor.withValues(alpha: 0.52),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Node
                Container(
                  width: nodeSize,
                  height: nodeSize,
                  decoration: BoxDecoration(
                    color: isFirst ? accent : bg,
                    border: Border.all(
                      color: isFirst
                          ? Colors.transparent
                          : accent.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: isFirst
                        ? [
                            BoxShadow(
                              color: accent.withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    stage.type.icon,
                    width: 16,
                    height: 16,
                    colorFilter: ColorFilter.mode(
                      isFirst ? _contrastColor(accent) : accent,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 14),

          // ── Card ───────────────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
              child: _StageCard(
                stage: stage,
                index: index,
                total: total,
                isFirst: isFirst,
                accent: accent,
                bg: bg,
                colorScheme: cs,
                textTheme: tt,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _contrastColor(Color c) =>
      c.computeLuminance() > 0.7 ? Colors.black87 : Colors.white;
}

// ---------------------------------------------------------------------------
// Stage card
// ---------------------------------------------------------------------------

class _StageCard extends StatelessWidget {
  const _StageCard({
    required this.stage,
    required this.index,
    required this.total,
    required this.isFirst,
    required this.accent,
    required this.bg,
    required this.colorScheme,
    required this.textTheme,
  });

  final PipelineStage stage;
  final int index;
  final int total;
  final bool isFirst;
  final Color accent;
  final Color bg;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final tt = textTheme;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: isFirst ? accent.withValues(alpha: 0.08) : theme.canvasColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFirst
              ? accent.withValues(alpha: 0.5)
              : theme.disabledColor.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stage.name,
                  style: tt.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 7),
                _TypeBadge(
                  stage: stage,
                  accent: accent,
                  bg: bg,
                  textTheme: tt,
                ),
              ],
            ),
          ),

          // Step indicator — muted, right-aligned
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isFirst
                    ? accent.withValues(alpha: 0.28)
                    : theme.disabledColor.withValues(alpha: 0.15),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '${index + 1}',
              style: tt.labelMedium?.copyWith(color: theme.disabledColor),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Type badge
// ---------------------------------------------------------------------------

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({
    required this.stage,
    required this.accent,
    required this.bg,
    required this.textTheme,
  });

  final PipelineStage stage;
  final Color accent;
  final Color bg;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            stage.type.displayName,
            style: textTheme.labelSmall?.copyWith(
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 80, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.account_tree_outlined,
              size: 44, color: cs.onSurfaceVariant.withValues(alpha: 0.22)),
          const SizedBox(height: 14),
          Text(
            'No stages defined',
            style: tt.titleSmall?.copyWith(
              color: theme.disabledColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Edit the job posting to configure a hiring pipeline.',
            textAlign: TextAlign.center,
            style: tt.bodySmall?.copyWith(
              color: theme.disabledColor.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
