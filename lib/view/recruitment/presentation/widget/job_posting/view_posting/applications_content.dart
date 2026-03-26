import 'package:employeeos/core/index.dart' show CustomDivider;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../data/mock/job_application_mock_data.dart';
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
    this.jobId,
  });

  final ThemeData theme;
  final String? jobId;

  @override
  State<ApplicationsContent> createState() => _State();
}

class _State extends State<ApplicationsContent> {
  final Set<int> _selected = {};
  bool _sortAsc = false;

  ThemeData get _t => widget.theme;
  ColorScheme get _cs => _t.colorScheme;
  TextTheme get _tt => _t.textTheme;

  List<Map<String, dynamic>> get _rows {
    if (widget.jobId == null || widget.jobId!.isEmpty) return [];
    final list = jobApplicationMockList
        .where((a) => a['job_id'] == widget.jobId)
        .toList()
      ..sort((a, b) {
        final cmp = ((a['applied_on'] as String?) ?? '')
            .compareTo((b['applied_on'] as String?) ?? '');
        return _sortAsc ? cmp : -cmp;
      });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.jobId == null || widget.jobId!.isEmpty) {
      return _empty(
          'No job selected', 'Open a job posting to view its applications.');
    }

    final rows = _rows;

    if (rows.isEmpty) {
      return _empty('No applications yet',
          'Applications will appear here once candidates apply.');
    }

    final allChecked = rows.isNotEmpty && _selected.length == rows.length;
    // Divider color
    final divColor = _cs.outlineVariant.withValues(alpha: 0.18);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: _t.brightness == Brightness.dark
                ? const Color.fromARGB(255, 23, 30, 37)
                : _t.cardColor,
            boxShadow: [
              BoxShadow(
                color: _t.shadowColor,
                blurRadius: 5,
                spreadRadius: 2,
              ),
            ]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Top action bar ───────────────────────────────────────────────
            _TopBar(
              theme: _t,
              selectedCount: _selected.length,
              onDownload: () => _snack('Downloading all resumes…'),
              onShortlist:
                  _selected.isEmpty ? null : () => _bulkAction('Shortlisted'),
              onReject:
                  _selected.isEmpty ? null : () => _bulkAction('Rejected'),
            ),

            // ── Table ────────────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                // Horizontal scroll for narrow screens
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: MediaQuery.of(context)
                      .size
                      .width
                      .clamp(_totalWidth + 100, double.infinity),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Header row ─────────────────────────────────────────
                      Container(
                        decoration: BoxDecoration(
                          color: _cs.surface,
                        ),
                        child: HeaderRow(
                          widths: const {
                            'applicant': _applicantWidth,
                            'email': _emailWidth,
                            'phone': _phoneWidth,
                            'status': _statusWidth,
                            'appliedOn': _appliedOnWidth,
                            'resume': _resumeWidth,
                          },
                          theme: _t,
                          allChecked: allChecked,
                          sortAsc: _sortAsc,
                          onCheckAll: () => setState(() {
                            if (allChecked) {
                              _selected.clear();
                            } else {
                              _selected
                                  .addAll(List.generate(rows.length, (i) => i));
                            }
                          }),
                          onSortDate: () =>
                              setState(() => _sortAsc = !_sortAsc),
                        ),
                      ),

                      // ── Data rows ──────────────────────────────────────────
                      Expanded(
                        child: ListView.separated(
                          separatorBuilder: (_, __) =>
                              CustomDivider(height: 1, color: divColor),
                          itemCount: rows.length,
                          itemBuilder: (ctx, i) {
                            final row = rows[i];
                            final sel = _selected.contains(i);
                            return CustomDataRow(
                              key: ValueKey(row['id'] ?? i),
                              theme: _t,
                              row: row,
                              selected: sel,
                              backgroundColor: Colors.transparent,
                              onToggle: () => setState(() =>
                                  sel ? _selected.remove(i) : _selected.add(i)),
                              onResume: () => _snack(
                                  'Open resume:\n${row['resume_url'] ?? ''}'),
                              widths: const {
                                'applicant': _applicantWidth,
                                'email': _emailWidth,
                                'phone': _phoneWidth,
                                'status': _statusWidth,
                                'appliedOn': _appliedOnWidth,
                                'resume': _resumeWidth,
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _bulkAction(String status) {
    _snack('${_selected.length} applicant(s) → $status');
    setState(() => _selected.clear());
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

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
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          DownloadBtn(
              theme: theme, onTap: onDownload, selectedCount: selectedCount),
        ],
      ),
    );
  }
}
