import 'package:employeeos/core/index.dart'
    show EmptyContent, showRightSideTaskDetails;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

import '../../index.dart'
    show
        FilemanagerBloc,
        FileFilterService,
        FileManagerFilterController,
        FileManagerFilterSection,
        FileManagerSideMenu,
        FilterControllerProvider,
        FolderFile,
        TableDataRow,
        TableHeaderRow,
        TableHeaderSelector,
        TablePaginator,
        ViewType;

class FileTableScreen extends StatefulWidget {
  final double screenWidth;
  final List<FolderFile> files;
  final ScrollController verticalScrollController;
  final Function(String) onFavoriteToggle;
  const FileTableScreen(
      {super.key,
      required this.screenWidth,
      required this.verticalScrollController,
      required this.files,
      required this.onFavoriteToggle});

  @override
  State<FileTableScreen> createState() => _FileTableScreenState();
}

class _FileTableScreenState extends State<FileTableScreen> {
  @override
  void didUpdateWidget(covariant FileTableScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.files != widget.files) {
      _filtered = List.from(widget.files);
      // Optionally re-apply filters if needed
      _applyFilters();
    }
  }

  late List<FolderFile> _filtered;
  final Set<String> _selected = {};

  // Filter state - now using the new controller system
  ViewType _viewType = ViewType.list;
  late FileManagerFilterController _filterController;
  // Paging
  int _pageIndex = 0;
  int _rowsPerPage = 10;
  final List<int> _rppOptions = const [5, 10, 25, 50];

  // Horizontal sync (header <-> body)
  late final LinkedScrollControllerGroup _hGroup;
  late final ScrollController _hHeaderCtrl;
  late final ScrollController _hBodyCtrl;

  // Column widths (tweak as you like)
  late double _wName;
  static const double _wSize = 120;
  static const double _wType = 90;
  static const double _wModified = 150;
  static const double _wShared = 100;
  static const double _wActions = 80;
  double get _tableWidth =>
      _wName +
      _wSize +
      _wType +
      _wModified +
      _wShared +
      _wActions +
      34; // + padding

  @override
  void initState() {
    super.initState();
    _filtered = List.from(widget.files);

    // Initialize filter controller
    _filterController = FileManagerFilterController();
    _filterController.addListener(_applyFilters);

    _hGroup = LinkedScrollControllerGroup();
    _hHeaderCtrl = _hGroup.addAndGet();
    _hBodyCtrl = _hGroup.addAndGet();

    // Adjust name column width based on screen width
    if (widget.screenWidth < 600) {
      _wName = 300;
    } else {
      _wName = 400;
    }
  }

  @override
  void dispose() {
    _filterController.removeListener(_applyFilters);
    _filterController.dispose();
    _hHeaderCtrl.dispose();
    _hBodyCtrl.dispose();
    super.dispose();
  }

  // Filter methods
  void _applyFilters() {
    // Use the local filter controller
    final filterState = _filterController.filterState;

    setState(() {
      // Use the new FileFilterService to apply all filters
      _filtered = FileFilterService.applyFilters(widget.files, filterState);

      // Reset to first page when filters change
      _pageIndex = 0;

      // Clear selections if they're not in filtered results
      _selected.removeWhere((id) => !_filtered.any((file) => file.id == id));
    });
  }

  // Paging helpers (now use filtered data)
  int get _total => _filtered.length;
  int get _pageCount => (_total / _rowsPerPage).ceil().clamp(1, 1 << 30);
  int get _startIndex => _pageIndex * _rowsPerPage;
  int get _endIndex => (_startIndex + _rowsPerPage).clamp(0, _total);
  List<FolderFile> get _pageItems => _filtered.sublist(_startIndex, _endIndex);

  void _goFirst() => setState(() => _pageIndex = 0);
  void _goPrev() =>
      setState(() => _pageIndex = (_pageIndex - 1).clamp(0, _pageCount - 1));
  void _goNext() =>
      setState(() => _pageIndex = (_pageIndex + 1).clamp(0, _pageCount - 1));
  void _goLast() => setState(() => _pageIndex = _pageCount - 1);

  void _changeRpp(int v) {
    // keep top-left item visible: recompute page so the old start stays in view
    final oldStart = _startIndex;
    setState(() {
      _rowsPerPage = v;
      _pageIndex = (oldStart / _rowsPerPage).floor().clamp(0, _pageCount - 1);
    });
  }

  // Selection helpers (current page only; change to _all to select across dataset)
  bool get _isAllSelectedOnPage =>
      _pageItems.isNotEmpty &&
      _pageItems.every((f) => _selected.contains(f.id));

  bool get _isAnySelectedOnPage =>
      _pageItems.any((f) => _selected.contains(f.id));

  @override
  Widget build(BuildContext context) {
    return FilterControllerProvider(
      controller: _filterController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ---------- Filter Section ----------
          FileManagerFilterSection(
            currentViewType: _viewType,
            filteredResultsCount: _total,
            onFiltersChanged: _applyFilters,
            onViewTypeChanged: (viewType) {
              setState(() {
                _viewType = viewType;
              });
            },
          ),

          const SizedBox(height: 24),

          // ---------- Table card ----------
          Column(
            children: [
              // Horizontal scrollable header (stays fixed vertically)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _hHeaderCtrl,
                child: SizedBox(
                  height: 80,
                  width: _tableWidth,
                  child: _selected.isEmpty
                      ? TableHeaderRow(
                          selectedCount: _selected.length,
                          onClear: _selected.isEmpty
                              ? null
                              : () => setState(() => _selected.clear()),
                          widthName: _wName,
                          widthSize: _wSize,
                          widthType: _wType,
                          widthModified: _wModified,
                          widthShared: _wShared,
                          widthActions: _wActions,
                          checkboxValue: _isAllSelectedOnPage
                              ? true
                              : (_isAnySelectedOnPage ? null : false),
                          onCheckboxChanged: (val) {
                            setState(() {
                              if (val == true) {
                                for (final f in _pageItems) {
                                  _selected.add(f.id);
                                }
                              } else {
                                for (final f in _pageItems) {
                                  _selected.remove(f.id);
                                }
                              }
                            });
                          },
                        )
                      : TableHeaderSelector(
                          selectedCount: _selected.length,
                          onSelectAll: () => setState(() {
                            for (final f in _pageItems) {
                              _selected.add(f.id);
                            }
                          }),
                          onClear: _selected.isEmpty
                              ? null
                              : () => setState(() => _selected.clear()),
                        ),
                ),
              ),

              // spacing between header and rows (requested)
              const SizedBox(height: 8),

              // ---------- Rows: vertically scrollable, horizontally linked to header ----------
              _pageItems.isEmpty
                  ? const EmptyContent(
                      icon: 'assets/icons/empty/ic-content.svg',
                      title: "No Files Found",
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      controller: _hBodyCtrl,
                      child: SizedBox(
                        width: _tableWidth,
                        child: ListView.builder(
                          controller: widget.verticalScrollController,
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          itemCount: _pageItems.length,
                          itemBuilder: (context, i) {
                            final f = _pageItems[i];
                            final selected = _selected.contains(f.id);
                            return GestureDetector(
                              key: ValueKey('${f.id}_$i'),
                              onTap: () => showRightSideTaskDetails(
                                  context,
                                  BlocProvider.value(
                                    value: context.read<FilemanagerBloc>(),
                                    child: FileManagerSideMenu(file: f),
                                  )),
                              child: TableDataRow(
                                file: f,
                                selected: selected,
                                widthName: _wName,
                                widthSize: _wSize,
                                widthType: _wType,
                                widthModified: _wModified,
                                widthShared: _wShared,
                                widthActions: _wActions,
                                onChanged: (v) => setState(() {
                                  if (v == true) {
                                    _selected.add(f.id);
                                  } else {
                                    _selected.remove(f.id);
                                  }
                                }),
                                onStar: () => widget.onFavoriteToggle(f.id),
                                onMenu: (action) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('$action → ${f.name}')),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),

              // ---------- External Paginator (fixed, does not scroll with rows) ----------
              TablePaginator(
                total: _total,
                pageIndex: _pageIndex,
                rowsPerPage: _rowsPerPage,
                pageCount: _pageCount,
                startIndex: _startIndex,
                endIndex: _endIndex,
                rppOptions: _rppOptions,
                onFirst: _pageIndex > 0 ? _goFirst : null,
                onPrev: _pageIndex > 0 ? _goPrev : null,
                onNext: _pageIndex < _pageCount - 1 ? _goNext : null,
                onLast: _pageIndex < _pageCount - 1 ? _goLast : null,
                onRowsPerPageChanged: (v) {
                  if (v != null) _changeRpp(v);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
