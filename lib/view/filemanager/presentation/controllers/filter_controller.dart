import 'package:flutter/material.dart';
import 'package:employeeos/view/filemanager/domain/entities/filter_models.dart';

/// Simple state management class for file manager filters
/// This handles filter state changes without persistence
class FileManagerFilterController extends ChangeNotifier {
  FileManagerFilterState _filterState = const FileManagerFilterState();

  FileManagerFilterController();

  /// Current filter state
  FileManagerFilterState get filterState => _filterState;

  /// Check if any filter is active
  bool get hasActiveFilters => _filterState.hasActiveFilters;

  /// Get count of active filters
  int get activeFilterCount => _filterState.activeFilterCount;

  /// Update search filter
  void updateSearchFilter(String query) {
    final isActive = query.isNotEmpty;
    _filterState = _filterState.copyWith(
      searchFilter: _filterState.searchFilter.copyWith(
        query: query,
        isActive: isActive,
      ),
    );
    notifyListeners();
  }

  /// Update date range filter
  void updateDateRangeFilter(DateTimeRange? dateRange) {
    final isActive = dateRange != null;
    _filterState = _filterState.copyWith(
      dateRangeFilter: _filterState.dateRangeFilter.copyWith(
        dateRange: dateRange,
        isActive: isActive,
      ),
    );
    notifyListeners();
  }

  /// Update file type filter
  void updateFileTypeFilter(Set<FileTypeFilter> selectedTypes) {
    final isActive = selectedTypes.isNotEmpty;
    _filterState = _filterState.copyWith(
      fileTypeFilter: _filterState.fileTypeFilter.copyWith(
        selectedTypes: selectedTypes,
        isActive: isActive,
      ),
    );
    notifyListeners();
  }

  /// Add a file type to the filter
  void addFileType(FileTypeFilter fileType) {
    final newTypes =
        Set<FileTypeFilter>.from(_filterState.fileTypeFilter.selectedTypes);
    newTypes.add(fileType);
    updateFileTypeFilter(newTypes);
  }

  /// Remove a file type from the filter
  void removeFileType(FileTypeFilter fileType) {
    final newTypes =
        Set<FileTypeFilter>.from(_filterState.fileTypeFilter.selectedTypes);
    newTypes.remove(fileType);
    updateFileTypeFilter(newTypes);
  }

  /// Toggle a file type in the filter
  void toggleFileType(FileTypeFilter fileType) {
    if (_filterState.fileTypeFilter.selectedTypes.contains(fileType)) {
      removeFileType(fileType);
    } else {
      addFileType(fileType);
    }
  }

  /// Update view type
  void updateViewType(ViewType viewType) {
    _filterState = _filterState.copyWith(viewType: viewType);
    notifyListeners();
  }

  /// Clear all filters
  void clearAllFilters() {
    _filterState = const FileManagerFilterState();
    notifyListeners();
  }

  /// Clear search filter
  void clearSearchFilter() {
    _filterState = _filterState.copyWith(
      searchFilter: const SearchFilter(),
    );
    notifyListeners();
  }

  /// Clear date range filter
  void clearDateRangeFilter() {
    _filterState = _filterState.copyWith(
      dateRangeFilter: const DateRangeFilter(),
    );
    notifyListeners();
  }

  /// Clear file type filter
  void clearFileTypeFilter() {
    _filterState = _filterState.copyWith(
      fileTypeFilter: const FileTypeFilterState(),
    );
    notifyListeners();
  }
}

/// Provider for filter controller
class FilterControllerProvider extends InheritedWidget {
  final FileManagerFilterController controller;

  const FilterControllerProvider({
    super.key,
    required this.controller,
    required super.child,
  });

  static FileManagerFilterController of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<FilterControllerProvider>();
    assert(
        provider != null, 'FilterControllerProvider not found in widget tree');
    return provider!.controller;
  }

  @override
  bool updateShouldNotify(FilterControllerProvider oldWidget) {
    return controller != oldWidget.controller;
  }
}
