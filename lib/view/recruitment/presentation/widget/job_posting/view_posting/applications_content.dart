import 'package:employeeos/core/index.dart' show CustomDivider;
import 'package:employeeos/view/recruitment/domain/index.dart'
    show JobApplicationSummary;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

import 'application_widgets/buttons.dart';
import 'application_widgets/data_row.dart';
import 'application_widgets/header_row.dart';

//---------------------------------------------------------
// Constants
//---------------------------------------------------------

const double _applicantWidth = 120;
const double _emailWidth = 150;
const double _phoneWidth = 130;
const double _statusWidth = 100;
const double _appliedOnWidth = 150;
const double _resumeWidth = 70;

const double _totalWidth = _applicantWidth +
    _emailWidth +
    _phoneWidth +
    _statusWidth +
    _appliedOnWidth +
    _resumeWidth +
    30;

// ─────────────────────────────────────────────────────────────────────────────
// Widget
// ─────────────────────────────────────────────────────────────────────────────

class ApplicationsContent extends StatefulWidget {
  const ApplicationsContent({
    super.key,
    required this.theme,
    required this.rows,
    required this.selectedIds,
    required this.isLoading,
    required this.error,
    required this.currentPage,
    required this.totalPages,
    required this.sortAsc,
    required this.onToggleSelect,
    required this.onToggleSelectAll,
    required this.onSortDate,
    required this.onPrevPage,
    required this.onNextPage,
    required this.onRetry,
    required this.onResume,
    required this.onDownload,
    this.onShortlist,
    this.onReject,
  });

  final ThemeData theme;
  final List<JobApplicationSummary> rows;
  final Set<String> selectedIds;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final int totalPages;
  final bool sortAsc;
  final ValueChanged<String> onToggleSelect;
  final VoidCallback onToggleSelectAll;
  final VoidCallback onSortDate;
  final VoidCallback onPrevPage;
  final VoidCallback onNextPage;
  final VoidCallback onRetry;
  final ValueChanged<String> onResume;
  final VoidCallback onDownload;
  final VoidCallback? onShortlist;
  final VoidCallback? onReject;

  @override
  State<ApplicationsContent> createState() => _State();
}

class _State extends State<ApplicationsContent> {
  ThemeData get _t => widget.theme;
  ColorScheme get _cs => _t.colorScheme;
  TextTheme get _tt => _t.textTheme;

  ScrollController? _headerHCtrl;
  final List<ScrollController> _rowHCtrls = [];

  static const Map<String, double> _widths = {
    'applicant': _applicantWidth,
    'email': _emailWidth,
    'phone': _phoneWidth,
    'status': _statusWidth,
    'appliedOn': _appliedOnWidth,
    'resume': _resumeWidth,
  };

  @override
  void initState() {
    super.initState();
    _syncHorizontalControllersIfNeeded();
  }

  @override
  void didUpdateWidget(covariant ApplicationsContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rows.length != widget.rows.length ||
        oldWidget.currentPage != widget.currentPage) {
      _syncHorizontalControllersIfNeeded();
    }
  }

  void _syncHorizontalControllersIfNeeded() {
    final n = widget.rows.length;
    if (n == 0) {
      _disposeHorizontalControllers();
      return;
    }
    if (_headerHCtrl != null && _rowHCtrls.length == n) {
      return;
    }
    _disposeHorizontalControllers();
    final g = LinkedScrollControllerGroup();
    _headerHCtrl = g.addAndGet();
    for (var i = 0; i < n; i++) {
      _rowHCtrls.add(g.addAndGet());
    }
  }

  void _disposeHorizontalControllers() {
    _headerHCtrl?.dispose();
    for (final c in _rowHCtrls) {
      c.dispose();
    }
    _rowHCtrls.clear();
    _headerHCtrl = null;
  }

  @override
  void dispose() {
    _disposeHorizontalControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading && widget.rows.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.error != null && widget.rows.isEmpty) {
      return _empty('Failed to load applications', widget.error!);
    }

    final rows = widget.rows;

    if (rows.isEmpty) {
      return _empty('No applications yet',
          'Applications will appear here once candidates apply.');
    }

    final allChecked =
        rows.isNotEmpty && rows.every((r) => widget.selectedIds.contains(r.id));
    final divColor = _cs.outlineVariant.withValues(alpha: 0.18);

    final tableW = MediaQuery.sizeOf(context).width.clamp(
          _totalWidth + 100,
          double.infinity,
        );

    final headerCtrl = _headerHCtrl!;

    final cardColor = _t.brightness == Brightness.dark
        ? const Color.fromARGB(255, 23, 30, 37)
        : _t.cardColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: cardColor,
          boxShadow: [
            BoxShadow(
              color: _t.shadowColor,
              blurRadius: 5,
              spreadRadius: 2,
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _TopBar(
                theme: _t,
                selectedCount: widget.selectedIds.length,
                onDownload: widget.onDownload,
                onShortlist: widget.onShortlist,
                onReject: widget.onReject,
              ),
            ),
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: headerCtrl,
                child: SizedBox(
                  width: tableW,
                  child: Container(
                    decoration: BoxDecoration(color: _cs.surface),
                    child: HeaderRow(
                      widths: _widths,
                      theme: _t,
                      allChecked: allChecked,
                      sortAsc: widget.sortAsc,
                      onCheckAll: widget.onToggleSelectAll,
                      onSortDate: widget.onSortDate,
                    ),
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final row = rows[index];
                  final rowMap = {
                    'id': row.id,
                    'full_name': row.fullName,
                    'email': row.email,
                    'phone': row.phone,
                    'status': row.status,
                    'applied_on': row.appliedOn.toIso8601String(),
                    'resume_url': row.resumeUrl,
                  };
                  final sel = widget.selectedIds.contains(row.id);
                  return Column(
                    key: ValueKey(row.id),
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (index > 0) CustomDivider(height: 1, color: divColor),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        controller: _rowHCtrls[index],
                        child: SizedBox(
                          width: tableW,
                          child: CustomDataRow(
                            theme: _t,
                            row: rowMap,
                            selected: sel,
                            backgroundColor: Colors.transparent,
                            onToggle: () => widget.onToggleSelect(row.id),
                            onResume: () => widget.onResume(row.resumeUrl),
                            widths: _widths,
                          ),
                        ),
                      ),
                    ],
                  );
                },
                childCount: rows.length,
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                width: tableW,
                child: _PaginatorRow(
                  theme: _t,
                  currentPage: widget.currentPage,
                  totalPages: widget.totalPages,
                  onPrev: widget.onPrevPage,
                  onNext: widget.onNextPage,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _empty(String title, String msg) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/icons/common/solid/ic-solar_users-group-rounded-bold.svg',
                width: 44,
                colorFilter: ColorFilter.mode(
                  widget.theme.disabledColor,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(height: 14),
              Text(title,
                  style: _tt.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 5),
              Text(msg,
                  textAlign: TextAlign.center,
                  style: _tt.bodySmall?.copyWith(
                      color: _cs.onSurfaceVariant.withValues(alpha: 0.5),
                      height: 1.5)),
              const SizedBox(height: 12),
              if (widget.error != null)
                OutlinedButton(
                  onPressed: widget.onRetry,
                  child: const Text('Retry'),
                ),
            ],
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Top action bar
// ─────────────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.theme,
    required this.selectedCount,
    required this.onDownload,
    this.onShortlist,
    this.onReject,
  });

  final ThemeData theme;
  final int selectedCount;
  final VoidCallback onDownload;
  final VoidCallback? onShortlist;
  final VoidCallback? onReject;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (onShortlist != null)
                ActionBtn(
                  label: 'Shortlist',
                  color: Colors.green,
                  onTap: onShortlist!,
                  theme: theme,
                ),
              if (onShortlist != null) const SizedBox(width: 8),
              if (onReject != null)
                ActionBtn(
                  label: 'Reject',
                  color: Colors.redAccent,
                  onTap: onReject!,
                  theme: theme,
                ),
            ],
          ),
          const SizedBox(height: 12),
          DownloadBtn(
              theme: theme, onTap: onDownload, selectedCount: selectedCount),
        ],
      ),
    );
  }
}

class _PaginatorRow extends StatelessWidget {
  const _PaginatorRow({
    required this.theme,
    required this.currentPage,
    required this.totalPages,
    required this.onPrev,
    required this.onNext,
  });

  final ThemeData theme;
  final int currentPage;
  final int totalPages;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final canPrev = currentPage > 1;
    final canNext = currentPage < totalPages;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Text(
            'Page $currentPage of $totalPages',
            style: theme.textTheme.bodySmall,
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Previous page',
            onPressed: canPrev ? onPrev : null,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          IconButton(
            tooltip: 'Next page',
            onPressed: canNext ? onNext : null,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }
}
