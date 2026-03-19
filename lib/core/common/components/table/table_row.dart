import 'package:flutter/material.dart';

class TableDataRow extends StatefulWidget {
  const TableDataRow({
    super.key,
    required this.item,
    required this.selected,
    required this.widthName,
    required this.widthSize,
    required this.widthType,
    required this.widthModified,
    required this.widthShared,
    required this.widthActions,
    required this.onChanged,
  });

  final dynamic item;
  final bool selected;
  final double widthName,
      widthSize,
      widthType,
      widthModified,
      widthShared,
      widthActions;
  final ValueChanged<bool?> onChanged;

  @override
  State<TableDataRow> createState() => _TableDataRowState();
}

class _TableDataRowState extends State<TableDataRow> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.3),
        ),
        color:
            widget.selected ? theme.colorScheme.primary.withOpacity(.05) : null,
      ),
      child: Row(
        children: [
          // Name cell with checkbox + type badge + file name
          SizedBox(
            width: widget.widthName,
            child: Row(
              children: [
                Checkbox(
                  value: widget.selected,
                  onChanged: widget.onChanged,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.item.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),

          // Size
          SizedBox(
            width: widget.widthSize,
          ),

          // Type
          SizedBox(
            width: widget.widthType,
          ),

          // Modified
          SizedBox(
            width: widget.widthModified,
          ),

          // Shared

          // Actions
        ],
      ),
    );
  }
}
