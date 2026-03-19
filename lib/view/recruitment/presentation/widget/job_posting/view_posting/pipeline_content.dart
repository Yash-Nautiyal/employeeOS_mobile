import 'package:flutter/material.dart';

import '../../../../domain/index.dart' show PipelineStage;
import '../../../index.dart' show PageHeading, TimelineItem;

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
        decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark
                ? const Color.fromARGB(255, 23, 30, 37)
                : theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: theme.shadowColor, blurRadius: 5, spreadRadius: 1),
            ]),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Page heading ────────────────────────────────────────────────
            PageHeading(
              count: pipeline.length,
              colorScheme: cs,
              textTheme: tt,
            ),

            const SizedBox(height: 16),

            // ── Timeline ────────────────────────────────────────────────────
            ...List.generate(
              pipeline.length,
              (i) => TimelineItem(
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
