import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TableHeaderSelector extends StatelessWidget {
  const TableHeaderSelector({
    super.key,
    required this.selectedCount,
    required this.onClear,
    required this.onSelectAll,
  });

  final int selectedCount;
  final VoidCallback? onClear;
  final VoidCallback? onSelectAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasSel = selectedCount > 0;

    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: hasSel
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Checkbox(
            value: hasSel,
            tristate: true,
            onChanged: (value) {
              if (value == true) {
                onSelectAll?.call();
              } else {
                onClear?.call();
              }
            },
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          const SizedBox(width: 10),
          Text(
            hasSel ? '$selectedCount selected' : 'Files',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.primaryColor,
            ),
          ),
          const Spacer(),
          SvgPicture.asset(
            'assets/icons/common/solid/ic-solar-add-folder-bold.svg',
            color: theme.primaryColor,
          ),
          const SizedBox(width: 10),
          SvgPicture.asset(
            'assets/icons/common/solid/ic-solar_share-bold.svg',
            color: theme.primaryColor,
          ),
          const SizedBox(width: 10),
          SvgPicture.asset(
            'assets/icons/common/solid/ic-solar_trash-bin-trash-bold.svg',
            color: theme.primaryColor,
          ),
        ],
      ),
    );
  }
}
