import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../domain/entities/pipeline_stage.dart';
import 'sheet_stage_title.dart';

class AddStageSheet extends StatelessWidget {
  const AddStageSheet({
    super.key,
    required this.theme,
    required this.available,
    required this.onAdd,
    required this.scrollController,
  });

  final ThemeData theme;
  final List<PipelineStage> available;
  final ValueChanged<PipelineStage> onAdd;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 0),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Column(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 4),
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/icons/common/solid/ic-solar_add-circle-bold.svg',
                          width: 18,
                          colorFilter: ColorFilter.mode(
                            theme.scaffoldBackgroundColor,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Add a stage',
                          style: tt.titleMedium
                              ?.copyWith(color: theme.scaffoldBackgroundColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: available.length,
                itemBuilder: (context, index) {
                  final stage = available[index];
                  final accent = stage.type.resolvedAccent(cs);
                  final bg = stage.type.resolvedColor(cs);
                  return SheetStageTile(
                    stage: stage,
                    accent: accent,
                    bg: bg,
                    textTheme: tt,
                    colorScheme: cs,
                    onTap: () => onAdd(stage),
                  );
                },
              ),
            ),
            // Stage tiles
            // ...available.map((stage) {
            //   final accent = stage.type.resolvedAccent(cs);
            //   final bg = stage.type.resolvedColor(cs);
            //   return SheetStageTile(
            //     stage: stage,
            //     accent: accent,
            //     bg: bg,
            //     textTheme: tt,
            //     colorScheme: cs,
            //     onTap: () => onAdd(stage),
            //   );
            // }),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
