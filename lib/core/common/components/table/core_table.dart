import 'package:employeeos/core/index.dart' show EmptyContent;
import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

import 'table_header.dart';
import 'table_header_selector.dart';
import 'table_paginator.dart';
import 'table_row.dart';

class CoreTable extends StatefulWidget {
  final double screenWidth;
  final List<dynamic> items;
  final ScrollController verticalScrollController;
  const CoreTable({
    super.key,
    required this.screenWidth,
    required this.verticalScrollController,
    required this.items,
  });

  @override
  State<CoreTable> createState() => _CoreTableState();
}

class _CoreTableState extends State<CoreTable>
    with SingleTickerProviderStateMixin {
  List<dynamic> get _rootLevelItems => widget.items.toList();

  List<dynamic> get _displayItems => _rootLevelItems;

  @override
  void didUpdateWidget(covariant CoreTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _filtered = List.from(_displayItems);
      setState(
          () {}); // Force immediate rebuild so remove-from-folder etc. reflect right away.
    }
  }

  late List<dynamic> _filtered;
  final Set<String> _selected = {};

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
  static const double _wModified = 130;
  static const double _wShared = 110;
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
    _filtered = List.from(_displayItems);

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
    _hHeaderCtrl.dispose();
    _hBodyCtrl.dispose();
    super.dispose();
  }

  // Paging helpers (now use filtered data)
  int get _total => _filtered.length;
  int get _pageCount => (_total / _rowsPerPage).ceil().clamp(1, 1 << 30);
  int get _startIndex => _pageIndex * _rowsPerPage;
  int get _endIndex => (_startIndex + _rowsPerPage).clamp(0, _total);
  List<dynamic> get _pageItems => _filtered.sublist(_startIndex, _endIndex);

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

  /// Selected items (from current _filtered). Used for add-to-folder.
  List<dynamic> get _selectedItems =>
      _filtered.where((i) => _selected.contains(i.id)).toList();

  List<String> get _selectedFileIds =>
      _selectedItems.whereType<dynamic>().map((f) => f.id as String).toList();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
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
                    ? TableHeader(
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
                        selectedFileIds: _selectedFileIds,
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
                          final item = _pageItems[i];
                          final selected = _selected.contains(item.id);
                          return GestureDetector(
                            key: ValueKey('${item.id}_$i'),
                            onTap: () {},
                            child: TableDataRow(
                              item: item,
                              selected: selected,
                              widthName: _wName,
                              widthSize: _wSize,
                              widthType: _wType,
                              widthModified: _wModified,
                              widthShared: _wShared,
                              widthActions: _wActions,
                              onChanged: (v) => setState(() {
                                if (v == true) {
                                  _selected.add(item.id);
                                } else {
                                  _selected.remove(item.id);
                                }
                              }),
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
    );
  }
}
