import 'package:flutter/material.dart';

import 'package:employeeos/core/index.dart' show AppPallete;
import '../../../../../domain/entities/filter_models.dart' show FileTypeFilter;

class FileTypeFilterTrigger extends StatelessWidget {
  final Set<FileTypeFilter> selectedTypes;
  final bool isActive;
  final ThemeData theme;

  const FileTypeFilterTrigger({
    super.key,
    required this.selectedTypes,
    required this.isActive,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: selectedTypes.isEmpty
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'All types',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.tertiary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  Icons.arrow_drop_down_rounded,
                  color: theme.colorScheme.tertiary,
                ),
              ],
            )
          : _buildSelectedTypesDisplay(),
    );
  }

  Widget _buildSelectedTypesDisplay() {
    const double maxTextWidth = 180;
    final names = selectedTypes.map((ft) => ft.name).toList();
    String display = '';
    int count = 0;
    final textStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.tertiary,
      fontWeight: FontWeight.w600,
    );

    for (int i = 0; i < names.length; i++) {
      final name = names[i];
      final testDisplay = display.isEmpty ? name : '$display, $name';
      final tp = TextPainter(
        text: TextSpan(text: testDisplay, style: textStyle),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout();

      if (tp.width > maxTextWidth && count > 0) {
        break;
      }
      display = testDisplay;
      count++;
    }

    int remaining = names.length - count;
    String finalDisplay = display;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(finalDisplay, style: textStyle),
            if (remaining > 0) ...[
              const SizedBox(width: 6),
              _buildRemainingTypesNumber(remaining),
            ],
          ],
        ),
        Icon(
          Icons.arrow_drop_down_rounded,
          color: theme.colorScheme.tertiary,
        ),
      ],
    );
  }

  Widget _buildRemainingTypesNumber(int remaining) {
    return Container(
      decoration: BoxDecoration(
        color: AppPallete.infoMain.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        child: Text(
          '+$remaining',
          style: theme.textTheme.labelLarge?.copyWith(
            color: AppPallete.infoMain,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
