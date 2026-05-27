import 'package:employeeos/core/index.dart' show getFileIcon;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../domain/entities/filter_models.dart' show FileTypeFilter;

class FileTypeChip extends StatelessWidget {
  final FileTypeFilter filter;
  final bool isSelected;
  final ThemeData theme;
  final VoidCallback onTap;

  const FileTypeChip({
    super.key,
    required this.filter,
    required this.isSelected,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8)
            .copyWith(left: isSelected ? 7 : 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary.withOpacity(0.3)
                : theme.dividerColor.withAlpha(100),
          ),
          color:
              isSelected ? theme.colorScheme.primary.withOpacity(0.08) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              SvgPicture.asset(
                'assets/icons/common/solid/ic-solar_close-circle-bold.svg',
                height: 20,
                width: 20,
                color: theme.colorScheme.primary.withAlpha(200),
              ),
              const SizedBox(width: 5),
            ],
            SvgPicture.asset(
              getFileIcon(filter.name),
              height: 20,
              width: 20,
            ),
            const SizedBox(width: 6),
            Text(
              filter.name,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
