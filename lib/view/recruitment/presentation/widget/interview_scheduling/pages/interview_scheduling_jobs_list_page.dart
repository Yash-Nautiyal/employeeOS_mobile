import 'package:employeeos/core/index.dart' show CustomBreadCrumbs;
import 'package:employeeos/core/theme/app_pallete.dart' show AppShadows;
import 'package:employeeos/view/recruitment/data/index.dart'
    show JobPostingModel;
import 'package:employeeos/view/recruitment/data/job_posting/datasources/job_posting_mock_datasource.dart';
import 'package:employeeos/view/recruitment/presentation/widget/interview_scheduling/routes/interview_scheduling_routes.dart';
import 'package:flutter/material.dart';

/// Lists active job postings as tappable cards; navigates to
/// [InterviewSchedulingDetailView] on tap.
class InterviewSchedulingJobsListPage extends StatelessWidget {
  const InterviewSchedulingJobsListPage({super.key});

  bool _isJobActive(JobPostingModel j) {
    if (!j.isActive) return false;
    final d = j.lastDateToApply;
    if (d == null) return true;
    final today = DateTime.now();
    final end = DateTime(d.year, d.month, d.day);
    final t = DateTime(today.year, today.month, today.day);
    return !end.isBefore(t);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<List<JobPostingModel>>(
      future: JobPostingMockDatasource.instance.getAll(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
              bottom: 20,
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        final all = snapshot.data ?? [];
        final active = all.where(_isJobActive).toList();

        return SingleChildScrollView(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
            bottom: 32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomBreadCrumbs(
                theme: theme,
                heading: 'Interview Scheduling',
                routes: const [
                  'Dashboard',
                  'Recruitment',
                  'Interview Scheduling',
                ],
              ),
              const SizedBox(height: 24),
              if (active.isEmpty)
                _EmptyState(theme: theme)
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      for (final job in active)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _JobScheduleCard(
                            job: job,
                            onTap: () => Navigator.of(context).pushNamed(
                              InterviewSchedulingRoutes.detail,
                              arguments: {'job': job},
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Job card
// ─────────────────────────────────────────────────────────────────────────────

class _JobScheduleCard extends StatelessWidget {
  const _JobScheduleCard({
    required this.job,
    required this.onTap,
  });

  final JobPostingModel job;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final deadline = job.lastDateToApply;

    // Wrapping pattern that makes InkWell ripple visible:
    //   Container (shadow only, transparent bg)
    //     └─ Material (clip + surface color)
    //           └─ InkWell (ripple)
    //                 └─ content
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        // ── Top + bottom shadows ──────────────────────────────────────────
        // AppShadows.card() returns a 3-layer shadow:
        //   • top micro-shadow  (ambient light from above)
        //   • main key shadow   (downward depth)
        //   • soft glow layer   (smooths bottom edge)
        // Dark mode replaces the top micro-shadow with a white highlight
        // that visually lifts the card off the dark scaffold.
        boxShadow: AppShadows.card(theme.brightness),
      ),
      child: Material(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: cs.primary.withValues(alpha: 0.08),
          highlightColor: cs.primary.withValues(alpha: 0.04),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Title row ────────────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        job.title,
                        style: tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: cs.onSurfaceVariant,
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // ── Department ───────────────────────────────────────────
                Text(
                  job.department,
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 14),

                // ── Divider ──────────────────────────────────────────────
                Divider(
                  height: 1,
                  thickness: 0.8,
                  color: cs.outlineVariant.withValues(alpha: 0.5),
                ),

                const SizedBox(height: 12),

                // ── Chips row ────────────────────────────────────────────
                Row(
                  children: [
                    _Chip(
                      icon: Icons.work_outline_rounded,
                      label: '${job.positions} open',
                      isDark: isDark,
                      colorScheme: cs,
                      textTheme: tt,
                    ),
                    if (deadline != null) ...[
                      const SizedBox(width: 8),
                      _Chip(
                        icon: Icons.calendar_today_outlined,
                        label:
                            'Apply by ${deadline.day}/${deadline.month}/${deadline.year}',
                        isDark: isDark,
                        colorScheme: cs,
                        textTheme: tt,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Chip  — clean surface tile, no nested shadows
// ─────────────────────────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  const _Chip({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.colorScheme,
    required this.textTheme,
  });

  final IconData icon;
  final String label;
  final bool isDark;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final cs = colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        // Use surfaceContainerLow for chips — one step above the card surface
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.6),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: cs.onSurfaceVariant,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 60),
      child: Column(
        children: [
          Icon(
            Icons.event_busy_outlined,
            size: 48,
            color: cs.onSurfaceVariant.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No active job postings',
            style: tt.titleSmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Create or extend a job posting to start scheduling interviews.',
            style: tt.bodySmall?.copyWith(
              color: cs.onSurfaceVariant.withValues(alpha: 0.6),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
