import 'package:employeeos/core/index.dart';
import 'package:flutter/material.dart';

class ActionHeader extends StatelessWidget {
  final ThemeData theme;
  final bool isWideScreen;
  final TextEditingController searchController;
  final VoidCallback onFilterTap;
  final ValueChanged<String> onSearchChanged;

  const ActionHeader({
    super.key,
    required this.theme,
    required this.isWideScreen,
    required this.searchController,
    required this.onFilterTap,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: isWideScreen ? 2 : 3,
          child: CustomTextfield(
            controller: searchController,
            keyboardType: TextInputType.text,
            theme: theme,
            onchange: onSearchChanged,
            hintText: 'Search applicant name...',
            isSearchField: true,
          ),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: onFilterTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 45,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? AppPallete.grey800
                  : AppPallete.grey200,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.brightness == Brightness.dark
                    ? AppPallete.grey700
                    : AppPallete.grey300,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Filters',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.filter_list,
                  size: 18,
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ],
            ),
          ),
        ),
        if (isWideScreen) const Spacer(),
      ],
    );
  }
}
