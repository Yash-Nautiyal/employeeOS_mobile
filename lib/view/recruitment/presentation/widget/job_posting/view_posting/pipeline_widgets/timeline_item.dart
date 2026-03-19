import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../domain/index.dart' show PipelineStage, StageTypeX;
import 'stage_card.dart';

class TimelineItem extends StatelessWidget {
  const TimelineItem({
    super.key,
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
              child: StageCard(
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
