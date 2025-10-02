import 'package:flutter/material.dart';

class TableHeaderRow extends StatelessWidget {
  const TableHeaderRow({
    super.key,
    required this.widthName,
    required this.widthSize,
    required this.widthType,
    required this.widthModified,
    required this.widthShared,
    required this.widthActions,
    required this.checkboxValue,
    required this.onCheckboxChanged,
    required this.selectedCount,
    required this.onClear,
  });

  final double widthName,
      widthSize,
      widthType,
      widthModified,
      widthShared,
      widthActions;
  final bool? checkboxValue; // tri-state
  final ValueChanged<bool?> onCheckboxChanged;
  final int selectedCount;
  final VoidCallback? onClear;
  @override
  Widget build(BuildContext context) {
    final hasSel = selectedCount > 0;

    final theme = Theme.of(context);
    TextStyle head = theme.textTheme.labelLarge!.copyWith(
      fontWeight: FontWeight.w700,
      color: theme.colorScheme.onSurface,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 52,
      decoration: BoxDecoration(
        color: hasSel ? const Color(0xFFD9FBE4) : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
      ),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          SizedBox(
            width: widthName,
            child: Row(
              children: [
                Checkbox(
                  value: checkboxValue,
                  tristate: true,
                  onChanged: onCheckboxChanged,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const SizedBox(width: 6),
                Text('Name', style: head),
              ],
            ),
          ),
          SizedBox(width: widthSize, child: Text('Size', style: head)),
          SizedBox(width: widthType, child: Text('Type', style: head)),
          SizedBox(width: widthModified, child: Text('Modified', style: head)),
          SizedBox(width: widthShared, child: Text('Shared', style: head)),
          SizedBox(width: widthActions, child: const SizedBox()),
        ],
      ),
    );
  }
}
