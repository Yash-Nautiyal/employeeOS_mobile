// Domain entities for file manager filters
// This file contains all the data models and enums used for filtering

import 'package:flutter/material.dart';

enum ViewType { grid, list }

enum FileTypeFilter {
  all,
  folder,
  txt,
  zip,
  audio,
  image,
  video,
  word,
  excel,
  powerpoint,
  pdf,
  photoshop,
  illustrator
}

/// Represents a date range filter
class DateRangeFilter {
  final DateTimeRange? dateRange;
  final bool isActive;

  const DateRangeFilter({
    this.dateRange,
    this.isActive = false,
  });

  DateRangeFilter copyWith({
    DateTimeRange? dateRange,
    bool? isActive,
  }) {
    return DateRangeFilter(
      dateRange: dateRange ?? this.dateRange,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DateRangeFilter &&
        other.dateRange == dateRange &&
        other.isActive == isActive;
  }

  @override
  int get hashCode => Object.hash(dateRange, isActive);
}

/// Represents a file type filter with multiple selections
class FileTypeFilterState {
  final Set<FileTypeFilter> selectedTypes;
  final bool isActive;

  const FileTypeFilterState({
    this.selectedTypes = const {},
    this.isActive = false,
  });

  FileTypeFilterState copyWith({
    Set<FileTypeFilter>? selectedTypes,
    bool? isActive,
  }) {
    return FileTypeFilterState(
      selectedTypes: selectedTypes ?? this.selectedTypes,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FileTypeFilterState &&
        other.selectedTypes == selectedTypes &&
        other.isActive == isActive;
  }

  @override
  int get hashCode => Object.hash(selectedTypes, isActive);
}

/// Represents a search filter
class SearchFilter {
  final String query;
  final bool isActive;

  const SearchFilter({
    this.query = '',
    this.isActive = false,
  });

  SearchFilter copyWith({
    String? query,
    bool? isActive,
  }) {
    return SearchFilter(
      query: query ?? this.query,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SearchFilter &&
        other.query == query &&
        other.isActive == isActive;
  }

  @override
  int get hashCode => Object.hash(query, isActive);
}

/// Main filter state that combines all filter types
class FileManagerFilterState {
  final SearchFilter searchFilter;
  final DateRangeFilter dateRangeFilter;
  final FileTypeFilterState fileTypeFilter;
  final ViewType viewType;

  const FileManagerFilterState({
    this.searchFilter = const SearchFilter(),
    this.dateRangeFilter = const DateRangeFilter(),
    this.fileTypeFilter = const FileTypeFilterState(),
    this.viewType = ViewType.list,
  });

  FileManagerFilterState copyWith({
    SearchFilter? searchFilter,
    DateRangeFilter? dateRangeFilter,
    FileTypeFilterState? fileTypeFilter,
    ViewType? viewType,
  }) {
    return FileManagerFilterState(
      searchFilter: searchFilter ?? this.searchFilter,
      dateRangeFilter: dateRangeFilter ?? this.dateRangeFilter,
      fileTypeFilter: fileTypeFilter ?? this.fileTypeFilter,
      viewType: viewType ?? this.viewType,
    );
  }

  /// Check if any filter is currently active
  bool get hasActiveFilters =>
      searchFilter.isActive ||
      dateRangeFilter.isActive ||
      fileTypeFilter.isActive;

  /// Get count of active filters
  int get activeFilterCount {
    int count = 0;
    if (searchFilter.isActive) count++;
    if (dateRangeFilter.isActive) count++;
    if (fileTypeFilter.isActive) count++;
    return count;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FileManagerFilterState &&
        other.searchFilter == searchFilter &&
        other.dateRangeFilter == dateRangeFilter &&
        other.fileTypeFilter == fileTypeFilter &&
        other.viewType == viewType;
  }

  @override
  int get hashCode => Object.hash(
        searchFilter,
        dateRangeFilter,
        fileTypeFilter,
        viewType,
      );
}
