import 'package:flutter/material.dart';
import 'package:employeeos/view/filemanager/domain/entities/files_models.dart';
import 'package:employeeos/view/filemanager/domain/entities/filter_models.dart';

/// Service class for handling file filtering logic
/// This separates the business logic from UI components
class FileFilterService {
  /// Check if a file matches the search query
  static bool matchesSearchQuery(FolderFile file, String query) {
    if (query.isEmpty) return true;
    return file.name.toLowerCase().contains(query.toLowerCase());
  }

  /// Check if a file matches the date range filter
  static bool matchesDateRange(FolderFile file, DateTimeRange? dateRange) {
    if (dateRange == null) return true;

    final fileDay = DateTime(
      file.createdAt.year,
      file.createdAt.month,
      file.createdAt.day,
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

  /// Check if a file matches any of the selected file type filters
  static bool matchesFileTypeFilters(
      FolderFile file, Set<FileTypeFilter> filters) {
    if (filters.isEmpty) return true; // No restriction = all files

    for (final filter in filters) {
      if (matchesFileTypeFilter(file, filter)) return true;
    }
    return false;
  }

  /// Check if a file matches a specific file type filter
  static bool matchesFileTypeFilter(FolderFile file, FileTypeFilter filter) {
    if (filter == FileTypeFilter.all) return true;

    // Handle folder filter
    if (filter == FileTypeFilter.folder) {
      return file.isFolder;
    }

    // For files, check the file type
    if (file.isFolder) return false;
    if (file.fileType == null) return false;

    final lowerFileType = file.fileType!.toLowerCase();

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

  /// Apply all filters to a list of files
  static List<FolderFile> applyFilters(
    List<FolderFile> files,
    FileManagerFilterState filterState,
  ) {
    return files.where((file) {
      // Apply search filter
      if (filterState.searchFilter.isActive &&
          !matchesSearchQuery(file, filterState.searchFilter.query)) {
        return false;
      }

      // Apply date range filter
      if (filterState.dateRangeFilter.isActive &&
          !matchesDateRange(file, filterState.dateRangeFilter.dateRange)) {
        return false;
      }

      // Apply file type filter
      if (filterState.fileTypeFilter.isActive &&
          !matchesFileTypeFilters(
              file, filterState.fileTypeFilter.selectedTypes)) {
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
