import 'package:employeeos/core/common/components/custom_textfield.dart';
import 'package:employeeos/view/filemanager/presentation/controllers/filter_controller.dart';
import 'package:flutter/material.dart';

/// UI component for search filtering
/// This component is now purely UI-focused and uses the controller for state management
class FilterSearchWidget extends StatefulWidget {
  final ThemeData theme;

  const FilterSearchWidget({
    super.key,
    required this.theme,
  });

  @override
  State<FilterSearchWidget> createState() => _FilterSearchWidgetState();
}

class _FilterSearchWidgetState extends State<FilterSearchWidget> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filterController = FilterControllerProvider.of(context);
    final isActive = filterController.filterState.searchFilter.isActive;

    return CustomTextfield(
      controller: _searchController,
      hintText: 'Search files...',
      theme: widget.theme,
      keyboardType: TextInputType.text,
      onchange: (value) {
        filterController.updateSearchFilter(value);
      },
      isSearchField: true,
      close: isActive,
      onClose: () {
        _searchController.clear();
        filterController.clearSearchFilter();
      },
    );
  }
}
