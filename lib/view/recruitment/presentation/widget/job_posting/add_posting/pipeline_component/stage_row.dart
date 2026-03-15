import 'package:employeeos/view/recruitment/domain/entities/pipeline_stage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class StageRow extends StatefulWidget {
  const StageRow({
    super.key,
    required this.index,
    required this.stage,
    required this.colorScheme,
    required this.textTheme,
    required this.theme,
    required this.isLast,
    required this.isNew,
    required this.isDimmed,
    required this.onRemove,
  });

  final int index;
  final PipelineStage stage;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final ThemeData theme;
  final bool isLast;
  final bool isNew;
  final bool isDimmed;
  final VoidCallback onRemove;

  @override
  State<StageRow> createState() => _StageRowState();
}

class _StageRowState extends State<StageRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  bool _hovering = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0.04, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    // New stages animate in; existing stages appear instantly
    if (widget.isNew) {
      _ctrl.forward();
    } else {
      _ctrl.value = 1.0;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = widget.colorScheme;
    final tt = widget.textTheme;
    final stage = widget.stage;
    final accent = stage.type.resolvedAccent(cs);
    final bg = stage.type.resolvedColor(cs);

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: AnimatedOpacity(
          opacity: widget.isDimmed ? 0.45 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Left column: step indicator + connector ────────────────
                SizedBox(
                  width: 36,
                  child: Column(
                    children: [
                      // Step bubble
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: bg,
                          border: Border.all(
                              color: accent.withValues(alpha: 0.2), width: 1.5),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            stage.type.icon,
                            width: 13,
                            colorFilter:
                                ColorFilter.mode(accent, BlendMode.srcIn),
                          ),
                        ),
                      ),
                      // Connector
                      if (!widget.isLast)
                        Expanded(
                          child: Center(
                            child: Container(
                              width: 1.5,
                              color: cs.outlineVariant.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // ── Stage card ─────────────────────────────────────────────
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: widget.isLast ? 0 : 8),
                    child: MouseRegion(
                      onEnter: (_) => setState(() => _hovering = true),
                      onExit: (_) => setState(() => _hovering = false),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: _hovering
                              ? cs.surfaceContainerHighest
                              : widget.theme.scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(
                            color: _hovering
                                ? accent.withValues(alpha: 0.35)
                                : widget.theme.dividerColor
                                    .withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            // Drag handle
                            ReorderableDragStartListener(
                              index: widget.index,
                              child: MouseRegion(
                                cursor: SystemMouseCursors.grab,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Icon(
                                    Icons.drag_indicator,
                                    size: 18,
                                    color: widget.theme.disabledColor,
                                  ),
                                ),
                              ),
                            ),

                            // Stage name + type badge
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    stage.name,
                                    style: tt.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: widget.theme.colorScheme.tertiary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: bg,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      stage.type.displayName,
                                      style: tt.labelSmall?.copyWith(
                                        color: accent,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 10.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Delete button
                            AnimatedOpacity(
                              opacity: _hovering ? 1.0 : 0.45,
                              duration: const Duration(milliseconds: 160),
                              child: IconButton(
                                icon: const Icon(Icons.close_rounded),
                                iconSize: 16,
                                color: cs.onSurfaceVariant,
                                splashRadius: 16,
                                style: IconButton.styleFrom(
                                  minimumSize: const Size(32, 32),
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  hoverColor: cs.error.withValues(alpha: 0.1),
                                ),
                                onPressed: widget.onRemove,
                                tooltip: 'Remove stage',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
