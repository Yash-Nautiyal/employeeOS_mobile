import 'package:flutter/material.dart';

import '../../../../../domain/index.dart' show PipelineStage;

class StageCard extends StatelessWidget {
  const StageCard({
    super.key,
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