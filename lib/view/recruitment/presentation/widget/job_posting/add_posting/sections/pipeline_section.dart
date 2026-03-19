import 'package:employeeos/core/common/components/custom_textbutton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../data/mock/department_presets_mock.dart'
    show nextPipelineStageId;
import '../../../../../domain/entities/pipeline_stage.dart';
import '../pipeline_component/add_sheet_stage.dart';
import '../pipeline_component/stage_row.dart';


class PipelineSection extends StatefulWidget {
  const PipelineSection({
    super.key,
    required this.theme,
    required this.stages,
    required this.onChanged,
    required this.stagePool,
  });

  final ThemeData theme;
  final List<PipelineStage> stages;
  final ValueChanged<List<PipelineStage>> onChanged;
  final List<PipelineStage> stagePool;

  @override
  State<PipelineSection> createState() => _PipelineSectionState();
}

class _PipelineSectionState extends State<PipelineSection>
    with SingleTickerProviderStateMixin {
  // Tracks which stage id is being dragged so we can dim others
  int? _draggingIndex;

  // The last added stage id – drives the entrance animation
  String? _justAddedId;

  void _removeAt(int index) {
    final next = List<PipelineStage>.from(widget.stages)..removeAt(index);
    widget.onChanged(next);
  }

  void _reorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex--;
    final next = List<PipelineStage>.from(widget.stages);
    final item = next.removeAt(oldIndex);
    next.insert(newIndex, item);
    setState(() => _draggingIndex = null);
    widget.onChanged(next);
  }

  void _addStage(BuildContext context, PipelineStage fromPool) {
    final added = fromPool.copyWith(id: nextPipelineStageId());
    setState(() => _justAddedId = added.id);
    widget.onChanged([...widget.stages, added]);
    Navigator.of(context).pop();
    // Clear the "just added" marker after the animation completes
    Future.delayed(const Duration(milliseconds: 600),
        () => setState(() => _justAddedId = null));
  }

  void _showAddStageSheet(BuildContext context) {
    final namesInPipeline = widget.stages.map((s) => s.name).toSet();
    final available = widget.stagePool
        .where((s) => !namesInPipeline.contains(s.name))
        .toList();
    if (available.isEmpty) return;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: widget.theme.scaffoldBackgroundColor.withValues(alpha: 0.5),
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.35,
        minChildSize: 0.25,
        maxChildSize: 0.7,
        expand: false,
        builder: (ctx, scrollController) => AddStageSheet(
          theme: widget.theme,
          available: available,
          onAdd: (stage) => _addStage(ctx, stage),
          scrollController: scrollController,
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final cs = widget.theme.colorScheme;
    final tt = widget.theme.textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: widget.theme.dividerColor.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section header ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/common/solid/ic-material-account-tree.svg',
                  width: 16,
                  colorFilter: ColorFilter.mode(
                      widget.theme.colorScheme.tertiary, BlendMode.srcIn),
                ),
                const SizedBox(width: 6),
                Text('Pipeline Stages', style: tt.labelMedium),
                const Spacer(),
                if (widget.stages.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                        '${widget.stages.length} stage${widget.stages.length == 1 ? '' : 's'}',
                        style: tt.labelSmall),
                  ),
              ],
            ),
          ),

          // ── Connector line (only when stages exist) ────────────────────
          if (widget.stages.isNotEmpty)
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              onReorderStart: (i) => setState(() => _draggingIndex = i),
              onReorderEnd: (_) => setState(() => _draggingIndex = null),
              onReorder: _reorder,
              proxyDecorator: (child, index, animation) =>
                  _ProxyDecorator(animation: animation, child: child),
              itemCount: widget.stages.length,
              itemBuilder: (context, index) {
                final stage = widget.stages[index];
                final isLast = index == widget.stages.length - 1;
                final isNew = stage.id == _justAddedId;
                final isDimmed =
                    _draggingIndex != null && _draggingIndex != index;

                return StageRow(
                  key: ValueKey(stage.id),
                  index: index,
                  stage: stage,
                  colorScheme: cs,
                  textTheme: tt,
                  theme: widget.theme,
                  isLast: isLast,
                  isNew: isNew,
                  isDimmed: isDimmed,
                  onRemove: () => _removeAt(index),
                );
              },
            ),

          // ── Empty state ────────────────────────────────────────────────
          if (widget.stages.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 15,
                    color: widget.theme.disabledColor,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'No stages yet. Select a department to load a preset, or add stages manually.',
                      style: tt.bodySmall,
                    ),
                  ),
                ],
              ),
            ),

          // ── Add stage button ───────────────────────────────────────────
          const SizedBox(height: 10),
          CustomTextButton(
            backgroundColor:
                widget.theme.colorScheme.primary.withValues(alpha: 0.2),
            onClick: () => _showAddStageSheet(context),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/common/solid/ic-solar_add-circle-bold.svg',
                  width: 18,
                  colorFilter: ColorFilter.mode(
                    widget.theme.colorScheme.primary,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Add stage',
                  style: tt.labelMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Drag proxy decorator (elevation shadow while dragging)
// ---------------------------------------------------------------------------

class _ProxyDecorator extends StatelessWidget {
  const _ProxyDecorator({
    required this.child,
    required this.animation,
  });

  final Widget child;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (ctx, ch) {
        final t =
            CurvedAnimation(parent: animation, curve: Curves.easeInOut).value;
        final scale = lerpDouble(1.0, 1.015, t)!;
        return Transform.scale(
          scale: scale,
          child: Material(
            elevation: lerpDouble(0, 8, t)!,
            shadowColor: Colors.black.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(9),
            child: ch,
          ),
        );
      },
      child: child,
    );
  }
}

double? lerpDouble(double a, double b, double t) => a + (b - a) * t;
