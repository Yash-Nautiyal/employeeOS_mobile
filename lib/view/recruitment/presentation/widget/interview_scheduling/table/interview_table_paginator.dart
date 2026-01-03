import 'package:flutter/material.dart';

class InterviewTablePaginator extends StatelessWidget {
  const InterviewTablePaginator({
    super.key,
    required this.total,
    required this.pageIndex,
    required this.rowsPerPage,
    required this.pageCount,
    required this.startIndex,
    required this.endIndex,
    required this.rppOptions,
    required this.onFirst,
    required this.onPrev,
    required this.onNext,
    required this.onLast,
    required this.onRowsPerPageChanged,
  });

  final int total, pageIndex, rowsPerPage, pageCount, startIndex, endIndex;
  final List<int> rppOptions;
  final VoidCallback? onFirst, onPrev, onNext, onLast;
  final ValueChanged<int?> onRowsPerPageChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rangeText =
        total == 0 ? '0 of 0' : '${startIndex + 1}–$endIndex of $total';

    return SizedBox(
      height: 56,
      child: Row(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  'Rows:',
                  style: theme.textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 10),
              DropdownButton<int>(
                isExpanded: false,
                isDense: true,
                value: rowsPerPage,
                items: rppOptions
                    .map((e) => DropdownMenuItem<int>(
                        value: e,
                        child: Text(
                          '$e',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.tertiary,
                            fontWeight: FontWeight.w900,
                          ),
                        )))
                    .toList(),
                onChanged: onRowsPerPageChanged,
              ),
            ],
          ),
          const Spacer(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(rangeText, style: theme.textTheme.bodySmall),
              const SizedBox(width: 5),
              InkWell(
                onTap: onFirst,
                child: Icon(
                  Icons.first_page,
                  color: pageIndex > 0
                      ? theme.colorScheme.tertiary
                      : theme.dividerColor,
                ),
              ),
              InkWell(
                onTap: onPrev,
                child: Icon(
                  Icons.chevron_left,
                  color: pageIndex > 0
                      ? theme.colorScheme.tertiary
                      : theme.dividerColor,
                ),
              ),
              Text('${pageIndex + 1} / $pageCount',
                  style: theme.textTheme.bodySmall),
              InkWell(
                onTap: onNext,
                child: Icon(
                  Icons.chevron_right,
                  color: pageIndex < pageCount - 1
                      ? theme.colorScheme.tertiary
                      : theme.dividerColor,
                ),
              ),
              InkWell(
                onTap: onLast,
                child: Icon(
                  Icons.last_page,
                  color: pageIndex < pageCount - 1
                      ? theme.colorScheme.tertiary
                      : theme.dividerColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
