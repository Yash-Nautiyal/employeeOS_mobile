import 'package:employeeos/view/filemanager/domain/entities/filter_models.dart';
import 'package:employeeos/view/filemanager/presentation/controllers/filter_controller.dart';
import 'package:employeeos/view/filemanager/presentation/widgets/filter/date_range_filter_widget.dart';
import 'package:employeeos/view/filemanager/presentation/widgets/filter/file_type_filter_widget.dart';
import 'package:employeeos/view/filemanager/presentation/widgets/filter/filter_status_widget.dart';
import 'package:employeeos/view/filemanager/presentation/widgets/filter/search_filter_widget.dart';
import 'package:employeeos/view/filemanager/presentation/widgets/filter/view_toggle_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_popup/flutter_popup.dart' show CustomPopupState;

/// Simple filter section widget that orchestrates all filter components
/// No state persistence - starts fresh every time
class FileManagerFilterSection extends StatefulWidget {
  /// Callback when filters are applied (for external components to react to filter changes)
  final VoidCallback? onFiltersChanged;

  /// Current view type (for backward compatibility)
  final ViewType currentViewType;

  /// Callback for view type changes (for backward compatibility)
  final Function(ViewType)? onViewTypeChanged;

  /// Total number of filtered results to display
  final int filteredResultsCount;

  const FileManagerFilterSection({
    super.key,
    this.onFiltersChanged,
    this.currentViewType = ViewType.list,
    this.onViewTypeChanged,
    this.filteredResultsCount = 0,
  });

  @override
  State<FileManagerFilterSection> createState() =>
      _FileManagerFilterSectionState();
}

class _FileManagerFilterSectionState extends State<FileManagerFilterSection> {
  final _fileTypeFilterAnchorKey = GlobalKey<CustomPopupState>();

  @override
  void initState() {
    super.initState();

    // Set initial view type if provided and add listener
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = FilterControllerProvider.of(context);
      controller.addListener(_onFilterChanged);

      if (widget.currentViewType != ViewType.list) {
        controller.updateViewType(widget.currentViewType);
      }
    });
  }

  @override
  void dispose() {
    // Remove listener when disposing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final controller = FilterControllerProvider.of(context);
        controller.removeListener(_onFilterChanged);
      } catch (e) {
        // Controller might already be disposed
      }
    });
    super.dispose();
  }

  void _onFilterChanged() {
    // Notify parent about filter changes
    widget.onFiltersChanged?.call();

    // Notify about view type changes for backward compatibility
    if (widget.onViewTypeChanged != null) {
      final controller = FilterControllerProvider.of(context);
      widget.onViewTypeChanged!(controller.filterState.viewType);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Search filter
        FilterSearchWidget(theme: theme),

        const SizedBox(height: 12),

        // Filter controls row
        Wrap(
          spacing: 12,
          alignment: WrapAlignment.end,
          runAlignment: WrapAlignment.end,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            FilterDateRangeWidget(theme: theme),
            FilterFileTypeWidget(
              anchorKey: _fileTypeFilterAnchorKey,
              theme: theme,
            ),
          ],
        ),
        // View toggle and filter status
        FilterViewToggleWidget(theme: theme),
        const SizedBox(height: 12),
        if (FilterControllerProvider.of(context).hasActiveFilters)
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: widget.filteredResultsCount.toString(),
                        style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.tertiary),
                      ),
                      TextSpan(
                        text: widget.filteredResultsCount == 1
                            ? ' result found'
                            : ' results found',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.disabledColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                FilterStatusWidget(theme: theme),
              ],
            ),
          ),
      ],
    );
  }
}

/// Extension to provide easy access to filter controller
extension FilterControllerExtension on BuildContext {
  FileManagerFilterController get filterController =>
      FilterControllerProvider.of(this);
}

/// Helper class for external components to interact with filters
class FileManagerFilterHelper {
  /// Get the current filter state from a context
  static FileManagerFilterState getCurrentFilterState(BuildContext context) {
    return FilterControllerProvider.of(context).filterState;
  }

  /// Check if any filters are active
  static bool hasActiveFilters(BuildContext context) {
    return FilterControllerProvider.of(context).hasActiveFilters;
  }

  /// Get count of active filters
  static int getActiveFilterCount(BuildContext context) {
    return FilterControllerProvider.of(context).activeFilterCount;
  }

  /// Clear all filters
  static void clearAllFilters(BuildContext context) {
    FilterControllerProvider.of(context).clearAllFilters();
  }

  /// Update search filter
  static void updateSearchFilter(BuildContext context, String query) {
    FilterControllerProvider.of(context).updateSearchFilter(query);
  }

  /// Update date range filter
  static void updateDateRangeFilter(
      BuildContext context, DateTimeRange? dateRange) {
    FilterControllerProvider.of(context).updateDateRangeFilter(dateRange);
  }

  /// Update file type filter
  static void updateFileTypeFilter(
      BuildContext context, Set<FileTypeFilter> types) {
    FilterControllerProvider.of(context).updateFileTypeFilter(types);
  }

  /// Update view type
  static void updateViewType(BuildContext context, ViewType viewType) {
    FilterControllerProvider.of(context).updateViewType(viewType);
  }
}
