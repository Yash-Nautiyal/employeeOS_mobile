import 'package:employeeos/view/recruitment/domain/interview_scheduling/entities/interview_candidate.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

import 'table/interview_table_data_row.dart';
import 'table/interview_table_header_row.dart';
import 'table/interview_table_paginator.dart';

class CandidatesTable extends StatefulWidget {
  final double screenWidth;
  final List<InterviewCandidate> candidates;
  final Set<String> selectedIds;
  final ValueChanged<Set<String>> onSelectedIdsChanged;
  final ValueChanged<int>? onSelectionChanged;
  final Widget actionToolbar;
  final bool showRejectedRoundColumn;
  final bool showResumeColumn;
  final ScrollController? verticalController;

  const CandidatesTable({
    super.key,
    required this.screenWidth,
    required this.candidates,
    required this.selectedIds,
    required this.onSelectedIdsChanged,
    required this.actionToolbar,
    this.showRejectedRoundColumn = false,
    this.showResumeColumn = true,
    this.onSelectionChanged,
    this.verticalController,
  });

  @override
  State<CandidatesTable> createState() => _CandidatesTableState();
}

class _CandidatesTableState extends State<CandidatesTable> {
  late Set<String> _selected;

  // Paging
  int _pageIndex = 0;
  int _rowsPerPage = 10;
  final List<int> _rppOptions = const [5, 10, 25, 50];

  // Horizontal sync (header <-> body)
  late final LinkedScrollControllerGroup _hGroup;
  late final ScrollController _hHeaderCtrl;
  late final ScrollController _hBodyCtrl;

  // Column widths (adjust as needed)
  late double _wName;
  static const double _wJobTitle = 200;
  static const double _wApplicationDate = 150;
  static const double _wResume = 120;
  static const double _wRejectedRound = 160;
  double get _wResumeEffective => widget.showResumeColumn ? _wResume : 0;
  double get _wRejected => widget.showRejectedRoundColumn ? _wRejectedRound : 0;
  double get _tableWidth =>
      _wName +
      _wJobTitle +
      _wApplicationDate +
      _wResumeEffective +
      _wRejected +
      34; // + padding

  @override
  void initState() {
    super.initState();
    _selected = {...widget.selectedIds};

    _hGroup = LinkedScrollControllerGroup();
    _hHeaderCtrl = _hGroup.addAndGet();
    _hBodyCtrl = _hGroup.addAndGet();

    // Adjust name column width based on screen width
    if (widget.screenWidth < 600) {
      _wName = 200;
    } else {
      _wName = 300;
    }
  }

  @override
  void dispose() {
    _hHeaderCtrl.dispose();
    _hBodyCtrl.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CandidatesTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!setEquals(oldWidget.selectedIds, widget.selectedIds)) {
      setState(() {
        _selected = {...widget.selectedIds};
      });
    }
  }

  // Paging helpers
  int get _total => widget.candidates.length;
  int get _pageCount => (_total / _rowsPerPage).ceil().clamp(1, 1 << 30);
  int get _startIndex => _pageIndex * _rowsPerPage;
  int get _endIndex => (_startIndex + _rowsPerPage).clamp(0, _total);
  List<InterviewCandidate> get _pageItems =>
      widget.candidates.sublist(_startIndex, _endIndex);

  void _goFirst() => setState(() => _pageIndex = 0);
  void _goPrev() =>
      setState(() => _pageIndex = (_pageIndex - 1).clamp(0, _pageCount - 1));
  void _goNext() =>
      setState(() => _pageIndex = (_pageIndex + 1).clamp(0, _pageCount - 1));
  void _goLast() => setState(() => _pageIndex = _pageCount - 1);

  void _changeRpp(int v) {
    final oldStart = _startIndex;
    setState(() {
      _rowsPerPage = v;
      _pageIndex = (oldStart / _rowsPerPage).floor().clamp(0, _pageCount - 1);
    });
  }

  // Selection helpers
  bool get _isAllSelectedOnPage =>
      _pageItems.isNotEmpty &&
      _pageItems.every((f) => _selected.contains(f.id));

  bool get _isAnySelectedOnPage =>
      _pageItems.any((f) => _selected.contains(f.id));

  void _notifySelection() {
    widget.onSelectionChanged?.call(_selected.length);
    widget.onSelectedIdsChanged.call({..._selected});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final effectiveTableWidth = _tableWidth < constraints.maxWidth
            ? constraints.maxWidth
            : _tableWidth;
        return Column(
          children: [
            Container(
              color: theme.colorScheme.surfaceContainer,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: widget.actionToolbar,
                  ),
                  // Horizontal scrollable header (stays fixed vertically)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: _hHeaderCtrl,
                    child: SizedBox(
                        height: 80,
                        width: effectiveTableWidth,
                        child: InterviewTableHeaderRow(
                          selectedCount: _selected.length,
                          onClear: _selected.isEmpty
                              ? null
                              : () => setState(() {
                                    _selected.clear();
                                    _notifySelection();
                                  }),
                          widthName: _wName,
                          widthJobTitle: _wJobTitle,
                          widthApplicationDate: _wApplicationDate,
                          widthResume: _wResumeEffective,
                          showResume: widget.showResumeColumn,
                          widthRejectedRound: _wRejectedRound,
                          showRejectedRound: widget.showRejectedRoundColumn,
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
                              _notifySelection();
                            });
                          },
                        )),
                  ),
                ],
              ),
            ),

            // spacing between header and rows
            const SizedBox(height: 8),

            // ---------- Rows: horizontally linked to header ----------
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: _hBodyCtrl,
              child: SizedBox(
                width: effectiveTableWidth,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < _pageItems.length; i++)
                      Builder(
                        builder: (context) {
                          final candidate = _pageItems[i];
                          final id = candidate.id;
                          final selected = _selected.contains(id);
                          return InterviewTableDataRow(
                            candidate: candidate,
                            selected: selected,
                            widthName: _wName,
                            widthJobTitle: _wJobTitle,
                            widthApplicationDate: _wApplicationDate,
                            widthResume: _wResumeEffective,
                            showResume: widget.showResumeColumn,
                            widthRejectedRound: _wRejectedRound,
                            showRejectedRound: widget.showRejectedRoundColumn,
                            onChanged: (v) => setState(() {
                              if (v == true) {
                                _selected.add(id);
                              } else {
                                _selected.remove(id);
                              }
                              _notifySelection();
                            }),
                            onMenu: (action) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('$action → ${candidate.name}')),
                              );
                            },
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),

            // ---------- External Paginator (fixed, does not scroll with rows) ----------
            InterviewTablePaginator(
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
        );
      },
    );
  }
}
