import 'package:employeeos/core/index.dart' show CustomTextfield;
import 'package:flutter/material.dart';

/// Shared search + Filters + Sort row for recruitment list pages
/// (job postings, applications, etc.).
class RecruitmentListFilterBar extends StatelessWidget {
  const RecruitmentListFilterBar({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.onFiltersTap,
    required this.sortBy,
    required this.onSortChanged,
    this.horizontalPadding = 16.0,
    this.searchHint = 'Search...',
    this.searchMaxWidth = 200,
    this.searchMinWidth = 100,
    this.searchFieldHeight = 46,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onFiltersTap;
  final String sortBy;
  final ValueChanged<String> onSortChanged;

  final double horizontalPadding;
  final String searchHint;
  final double searchMaxWidth;
  final double searchMinWidth;
  final double searchFieldHeight;

  static const List<DropdownMenuItem<String>> defaultSortItems = [
    DropdownMenuItem(value: 'Latest', child: Text('Latest')),
    DropdownMenuItem(value: 'Oldest', child: Text('Oldest')),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Row(
        children: [
          Flexible(
            child: Wrap(
              spacing: 14,
              runSpacing: 5,
              alignment: WrapAlignment.start,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: searchMaxWidth,
                    minWidth: searchMinWidth,
                  ),
                  height: searchFieldHeight,
                  child: CustomTextfield(
                    controller: searchController,
                    onchange: onSearchChanged,
                    keyboardType: TextInputType.text,
                    theme: theme,
                    hintText: searchHint,
                    isSearchField: true,
                    close: true,
                    onClose: () {
                      searchController.clear();
                      onSearchChanged('');
                    },
                  ),
                ),
                InkWell(
                  onTap: onFiltersTap,
                  borderRadius: BorderRadius.circular(8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Filters',
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.filter_list_rounded,
                        size: 18,
                        color: theme.iconTheme.color,
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Sort by: ',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: sortBy,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                        items: defaultSortItems,
                        onChanged: (v) {
                          if (v == null) return;
                          onSortChanged(v);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
