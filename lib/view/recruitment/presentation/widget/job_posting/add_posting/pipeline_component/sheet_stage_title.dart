import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../domain/job_posting/entities/pipeline_stage.dart'
    show PipelineStage, StageTypeX;

class SheetStageTile extends StatefulWidget {
  const SheetStageTile({
    super.key,
    required this.stage,
    required this.accent,
    required this.bg,
    required this.textTheme,
    required this.colorScheme,
    required this.onTap,
  });

  final PipelineStage stage;
  final Color accent;
  final Color bg;
  final TextTheme textTheme;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  @override
  State<SheetStageTile> createState() => _SheetStageTileState();
}

class _SheetStageTileState extends State<SheetStageTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tt = widget.textTheme;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _pressed
              ? widget.bg.withValues(alpha: 0.8)
              : theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _pressed
                ? widget.accent.withValues(alpha: 0.4)
                : theme.dividerColor.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: widget.bg,
                border: Border.all(
                    color: widget.accent.withValues(alpha: 0.35), width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SvgPicture.asset(
                widget.stage.type.icon,
                colorFilter: ColorFilter.mode(widget.accent, BlendMode.srcIn),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.stage.name,
                    style: tt.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.stage.type.displayName,
                    style: tt.bodySmall,
                  ),
                ],
              ),
            ),
            SvgPicture.asset(
              'assets/icons/common/solid/ic-mingcute_add-line.svg',
              width: 18,
              colorFilter: ColorFilter.mode(
                theme.colorScheme.primary,
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
