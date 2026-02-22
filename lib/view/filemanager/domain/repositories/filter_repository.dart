import 'package:flutter/material.dart';
import '../index.dart'
    show FileItem, FileManagerFilterState, FileTypeFilter, FilemanagerItem;

/// Service class for handling file/folder filtering logic.
class FileFilterService {
  static bool matchesSearchQuery(FilemanagerItem item, String query) {
    if (query.isEmpty) return true;
    return item.name.toLowerCase().contains(query.toLowerCase());
  }

  static bool matchesDateRange(FilemanagerItem item, DateTimeRange? dateRange) {
    if (dateRange == null) return true;
    final fileDay = DateTime(
      item.createdAt.year,
      item.createdAt.month,
      item.createdAt.day,
    );
    final startDay = DateTime(
      dateRange.start.year,
      dateRange.start.month,
      dateRange.start.day,
    );
    final endDay = DateTime(
      dateRange.end.year,
      dateRange.end.month,
      dateRange.end.day,
    );
    return (fileDay.isAtSameMomentAs(startDay) || fileDay.isAfter(startDay)) &&
        (fileDay.isAtSameMomentAs(endDay) || fileDay.isBefore(endDay));
  }

  static bool matchesFileTypeFilters(
      FilemanagerItem item, Set<FileTypeFilter> filters) {
    if (filters.isEmpty) return true;
    for (final filter in filters) {
      if (matchesFileTypeFilter(item, filter)) return true;
    }
    return false;
  }

  static bool matchesFileTypeFilter(
      FilemanagerItem item, FileTypeFilter filter) {
    if (filter == FileTypeFilter.all) return true;
    if (filter == FileTypeFilter.folder) return item.isFolder;
    if (item.isFolder) return false;
    final fileType = item is FileItem ? item.file.fileType : null;
    if (fileType == null) return false;
    final lowerFileType = fileType.toLowerCase();
    switch (filter) {
      case FileTypeFilter.all:
        return true;
      case FileTypeFilter.folder:
        return lowerFileType.contains('folder');
      case FileTypeFilter.txt:
        return lowerFileType.contains('doc') || lowerFileType.contains('txt');
      case FileTypeFilter.zip:
        return lowerFileType.contains('zip');
      case FileTypeFilter.audio:
        return lowerFileType.contains('audio');
      case FileTypeFilter.image:
        return lowerFileType.contains('image');
      case FileTypeFilter.video:
        return lowerFileType.contains('video');
      case FileTypeFilter.word:
        return lowerFileType.contains('word');
      case FileTypeFilter.excel:
        return lowerFileType.contains('excel');
      case FileTypeFilter.powerpoint:
        return lowerFileType.contains('powerpoint');
      case FileTypeFilter.pdf:
        return lowerFileType.contains('pdf');
      case FileTypeFilter.photoshop:
        return lowerFileType.contains('photoshop');
      case FileTypeFilter.illustrator:
        return lowerFileType.contains('illustrator');
    }
  }

  static List<FilemanagerItem> applyFilters(
    List<FilemanagerItem> items,
    FileManagerFilterState filterState,
  ) {
    return items.where((item) {
      if (filterState.searchFilter.isActive &&
          !matchesSearchQuery(item, filterState.searchFilter.query)) {
        return false;
      }
      if (filterState.dateRangeFilter.isActive &&
          !matchesDateRange(item, filterState.dateRangeFilter.dateRange)) {
        return false;
      }
      if (filterState.fileTypeFilter.isActive &&
          !matchesFileTypeFilters(
              item, filterState.fileTypeFilter.selectedTypes)) {
        return false;
      }
      return true;
    }).toList();
  }

  /// Get display text for file type filter
  static String getFileTypeFilterDisplayText(
      Set<FileTypeFilter> selectedTypes) {
    if (selectedTypes.isEmpty) return 'All types';
    if (selectedTypes.length == 1) return selectedTypes.first.name;
    return '${selectedTypes.length} types selected';
  }

  /// Get available file type filters (excluding 'all')
  static List<FileTypeFilter> getAvailableFileTypeFilters() {
    return FileTypeFilter.values.where((v) => v != FileTypeFilter.all).toList();
  }
}
