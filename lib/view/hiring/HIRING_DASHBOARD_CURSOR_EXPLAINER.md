# Hiring Dashboard — Complete Implementation Explainer

**Module:** Hirings (Overview section in nav drawer)
**Purpose:** Replace all hardcoded data in the existing hiring dashboard UI with live Supabase data via a single RPC, managed through a Bloc.

---

## TABLE OF CONTENTS

1. [Architecture Overview](#1-architecture-overview)
2. [Supabase RPC Migration](#2-supabase-rpc-migration)
3. [Dart Data Models](#3-dart-data-models)
4. [Repository Layer](#4-repository-layer)
5. [Bloc Implementation](#5-bloc-implementation)
6. [Widget Wiring Changes](#6-widget-wiring-changes)
7. [Filter Dropdown Data](#7-filter-dropdown-data)
8. [File-by-File Change Summary](#8-file-by-file-change-summary)
9. [Testing Checklist](#9-testing-checklist)

---

## 1. ARCHITECTURE OVERVIEW

### Current State
- UI shell is fully built with hardcoded/dummy data
- No Bloc, no repository, no remote datasource, no RPC
- All state is local to widgets
- `HiringPipelineData` model exists but is incomplete (missing eligible counts)
- `HiringData` model uses a hardcoded `JobTitle` enum — needs to become dynamic

### Target State
```
Supabase (single RPC)
    ↓
HiringRemoteDatasource (calls RPC, returns raw Map)
    ↓
HiringRepository (parses into models)
    ↓
HiringBloc (holds state, handles filter changes + refresh)
    ↓
HiringView + all child widgets (read from BlocBuilder)
```

### Final Folder Structure
```
lib/view/hiring/
├── bloc/
│   ├── hiring_bloc.dart
│   ├── hiring_event.dart
│   └── hiring_state.dart
├── data/
│   ├── datasources/
│   │   └── hiring_remote_datasource.dart
│   ├── models/
│   │   └── hiring_dashboard_model.dart
│   └── repositories/
│       └── hiring_repository.dart
├── domain/
│   └── entities/
│       └── hiring_model.dart          ← MODIFY (remove JobTitle enum, update HiringData)
└── presentation/
    ├── pages/
    │   └── hiring_view.dart           ← MODIFY (add BlocProvider/BlocBuilder)
    └── widget/
        ├── hiring_filters.dart        ← MODIFY (wire filter callbacks)
        ├── hiring_job_chart.dart      ← MODIFY (accept dynamic data)
        ├── hiring_job_pipelines.dart  ← MODIFY (accept dynamic data, update model)
        ├── hiring_pipeline_container.dart  ← MODIFY (accept dynamic data)
        ├── hiring_pipeline_metric.dart     ← NO CHANGE (already accepts props)
        ├── hiring_stats_card.dart          ← NO CHANGE (already accepts data list)
        └── hiring_nav_button.dart          ← NO CHANGE
```

---

## 2. SUPABASE RPC MIGRATION

Create this as a new Supabase migration file.

**File:** `supabase/migrations/YYYYMMDDHHMMSS_hiring_dashboard_rpc.sql`

```sql
-- ============================================================
-- RPC: get_hiring_dashboard
-- Single function powering the entire Hirings dashboard.
-- Returns a JSONB object with four keys:
--   summary          → 6 stat cards
--   positions_by_job → donut chart data
--   pipeline_overview → global 6-gauge breakdown
--   per_job_pipelines → per-job accordion data
-- ============================================================

CREATE OR REPLACE FUNCTION get_hiring_dashboard(
  p_job_id          UUID        DEFAULT NULL,
  p_hr_manager_id   UUID        DEFAULT NULL,
  p_posting_from    TIMESTAMPTZ DEFAULT NULL,
  p_posting_to      TIMESTAMPTZ DEFAULT NULL,
  p_deadline_from   TEXT        DEFAULT NULL,
  p_deadline_to     TEXT        DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
SECURITY INVOKER
AS $$
DECLARE
  result JSONB;
BEGIN

  WITH
  -- ──────────────────────────────────────────────
  -- LAYER 1: Filtered jobs (single scan, reused everywhere)
  -- ──────────────────────────────────────────────
  filtered_jobs AS (
    SELECT
      j.id,
      j.title,
      j.is_active,
      COALESCE(NULLIF(TRIM(j.positions), '')::int, 0) AS pos
    FROM jobs j
    WHERE (p_job_id        IS NULL OR j.id         = p_job_id)
      AND (p_hr_manager_id IS NULL OR j.created_by = p_hr_manager_id)
      AND (p_posting_from  IS NULL OR j.created_at >= p_posting_from)
      AND (p_posting_to    IS NULL OR j.created_at <= p_posting_to)
      AND (p_deadline_from IS NULL OR (
            j.last_date IS NOT NULL
            AND TRIM(j.last_date) <> ''
            AND TO_DATE(j.last_date, 'DD/MM/YYYY') >= TO_DATE(p_deadline_from, 'DD/MM/YYYY')
          ))
      AND (p_deadline_to IS NULL OR (
            j.last_date IS NOT NULL
            AND TRIM(j.last_date) <> ''
            AND TO_DATE(j.last_date, 'DD/MM/YYYY') <= TO_DATE(p_deadline_to, 'DD/MM/YYYY')
          ))
  ),

  -- ──────────────────────────────────────────────
  -- LAYER 2: Applications scoped to filtered jobs
  -- ──────────────────────────────────────────────
  filtered_apps AS (
    SELECT a.id, a.status, a.job_id
    FROM applications a
    INNER JOIN filtered_jobs fj ON a.job_id = fj.id
  ),

  -- ──────────────────────────────────────────────
  -- LAYER 3: Interviews scoped to filtered applications
  -- ──────────────────────────────────────────────
  filtered_interviews AS (
    SELECT i.stage, i.status AS i_status, fa.job_id
    FROM interviews i
    INNER JOIN filtered_apps fa ON i.application_id = fa.id
    WHERE i.stage IN ('telephone', 'technical', 'onboarding')
  ),

  -- ──────────────────────────────────────────────
  -- LAYER 4a: Per-job application counts
  -- ──────────────────────────────────────────────
  job_app_counts AS (
    SELECT
      fj.id                                                          AS job_id,
      fj.title                                                       AS job_title,
      fj.pos,
      fj.is_active,
      COUNT(fa.id)                                                   AS total_apps,
      COUNT(*) FILTER (WHERE fa.status = 'shortlisted')              AS shortlisted,
      COUNT(*) FILTER (WHERE fa.status = 'rejected')                 AS rejected,
      COUNT(*) FILTER (WHERE fa.status IN ('pending', 'applied'))    AS pending
    FROM filtered_jobs fj
    LEFT JOIN filtered_apps fa ON fa.job_id = fj.id
    GROUP BY fj.id, fj.title, fj.pos, fj.is_active
  ),

  -- ──────────────────────────────────────────────
  -- LAYER 4b: Per-job interview counts, pivoted by stage
  -- ──────────────────────────────────────────────
  job_int_counts AS (
    SELECT
      fi.job_id,
      COALESCE(COUNT(*) FILTER (WHERE fi.stage = 'telephone'  AND fi.i_status IN ('scheduled','passed')), 0) AS tel_active,
      COALESCE(COUNT(*) FILTER (WHERE fi.stage = 'telephone'  AND fi.i_status = 'eligible'),              0) AS tel_eligible,
      COALESCE(COUNT(*) FILTER (WHERE fi.stage = 'technical'  AND fi.i_status IN ('scheduled','passed')), 0) AS tech_active,
      COALESCE(COUNT(*) FILTER (WHERE fi.stage = 'technical'  AND fi.i_status = 'eligible'),              0) AS tech_eligible,
      COALESCE(COUNT(*) FILTER (WHERE fi.stage = 'onboarding' AND fi.i_status IN ('scheduled','passed')), 0) AS onb_active,
      COALESCE(COUNT(*) FILTER (WHERE fi.stage = 'onboarding' AND fi.i_status = 'eligible'),              0) AS onb_eligible
    FROM filtered_interviews fi
    GROUP BY fi.job_id
  ),

  -- ──────────────────────────────────────────────
  -- LAYER 5: Combine per-job apps + interviews
  -- ──────────────────────────────────────────────
  per_job AS (
    SELECT
      jac.job_id,
      jac.job_title,
      jac.pos,
      jac.is_active,
      jac.total_apps,
      jac.shortlisted,
      jac.rejected,
      jac.pending,
      COALESCE(jic.tel_active,    0) AS tel_active,
      COALESCE(jic.tel_eligible,  0) AS tel_eligible,
      COALESCE(jic.tech_active,   0) AS tech_active,
      COALESCE(jic.tech_eligible, 0) AS tech_eligible,
      COALESCE(jic.onb_active,    0) AS onb_active,
      COALESCE(jic.onb_eligible,  0) AS onb_eligible
    FROM job_app_counts jac
    LEFT JOIN job_int_counts jic ON jic.job_id = jac.job_id
  ),

  -- ──────────────────────────────────────────────
  -- LAYER 6: Global aggregates (from per_job, no re-scan)
  -- ──────────────────────────────────────────────
  globals AS (
    SELECT
      COALESCE(SUM(total_apps), 0)::int     AS total_applications,
      COALESCE(SUM(shortlisted), 0)::int    AS total_shortlisted,
      COALESCE(SUM(rejected), 0)::int       AS total_rejected,
      COALESCE(SUM(pending), 0)::int        AS total_pending,
      COUNT(*)::int                          AS total_jobs,
      COALESCE(SUM(pos), 0)::int            AS total_positions,
      COALESCE(SUM(tel_active), 0)::int     AS g_tel_active,
      COALESCE(SUM(tel_eligible), 0)::int   AS g_tel_eligible,
      COALESCE(SUM(tech_active), 0)::int    AS g_tech_active,
      COALESCE(SUM(tech_eligible), 0)::int  AS g_tech_eligible,
      COALESCE(SUM(onb_active), 0)::int     AS g_onb_active,
      COALESCE(SUM(onb_eligible), 0)::int   AS g_onb_eligible
    FROM per_job
  )

  -- ──────────────────────────────────────────────
  -- FINAL: Assemble the single JSONB response
  -- ──────────────────────────────────────────────
  SELECT jsonb_build_object(

    'summary', jsonb_build_object(
      'total_applications', g.total_applications,
      'total_shortlisted',  g.total_shortlisted,
      'total_rejected',     g.total_rejected,
      'total_pending',      g.total_pending,
      'total_jobs',         g.total_jobs,
      'total_positions',    g.total_positions
    ),

    'positions_by_job', (
      SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
          'job_title',  pj.job_title,
          'positions',  pj.pos
        ) ORDER BY pj.pos DESC
      ), '[]'::jsonb)
      FROM per_job pj
      WHERE pj.is_active = true AND pj.pos > 0
    ),

    'pipeline_overview', jsonb_build_object(
      'application_progress', jsonb_build_object(
        'shortlisted', g.total_shortlisted,
        'pending',     g.total_pending,
        'rejected',    g.total_rejected,
        'total',       g.total_applications
      ),
      'interview_progress', jsonb_build_object(
        'telephonic', jsonb_build_object('active', g.g_tel_active,  'eligible', g.g_tel_eligible),
        'technical',  jsonb_build_object('active', g.g_tech_active, 'eligible', g.g_tech_eligible),
        'onboarding', jsonb_build_object('active', g.g_onb_active,  'eligible', g.g_onb_eligible)
      )
    ),

    'per_job_pipelines', (
      SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
          'job_title',           pj.job_title,
          'total_applications',  pj.total_apps,
          'shortlisted',         pj.shortlisted,
          'rejected',            pj.rejected,
          'pending',             pj.pending,
          'telephonic_active',   pj.tel_active,
          'telephonic_eligible', pj.tel_eligible,
          'technical_active',    pj.tech_active,
          'technical_eligible',  pj.tech_eligible,
          'onboarding_active',   pj.onb_active,
          'onboarding_eligible', pj.onb_eligible
        ) ORDER BY pj.total_apps DESC
      ), '[]'::jsonb)
      FROM per_job pj
    )

  ) INTO result
  FROM globals g;

  RETURN result;

END;
$$;
```

### How to deploy
Run this migration via Supabase CLI: `supabase db push` or apply manually in the Supabase SQL Editor.

---

## 3. DART DATA MODELS

### File: `lib/view/hiring/data/models/hiring_dashboard_model.dart`

**CREATE this new file.** This is the single model file that parses the entire RPC response.

```dart
import 'package:flutter/material.dart';

/// Root model for the entire hiring dashboard RPC response.
class HiringDashboardModel {
  final HiringSummary summary;
  final List<JobPositionData> positionsByJob;
  final PipelineOverview pipelineOverview;
  final List<JobPipelineData> perJobPipelines;

  const HiringDashboardModel({
    required this.summary,
    required this.positionsByJob,
    required this.pipelineOverview,
    required this.perJobPipelines,
  });

  factory HiringDashboardModel.fromJson(Map<String, dynamic> json) {
    return HiringDashboardModel(
      summary: HiringSummary.fromJson(json['summary'] as Map<String, dynamic>),
      positionsByJob: (json['positions_by_job'] as List<dynamic>)
          .map((e) => JobPositionData.fromJson(e as Map<String, dynamic>))
          .toList(),
      pipelineOverview:
          PipelineOverview.fromJson(json['pipeline_overview'] as Map<String, dynamic>),
      perJobPipelines: (json['per_job_pipelines'] as List<dynamic>)
          .map((e) => JobPipelineData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Returns an empty dashboard (used for initial/loading state).
  factory HiringDashboardModel.empty() {
    return HiringDashboardModel(
      summary: HiringSummary.empty(),
      positionsByJob: [],
      pipelineOverview: PipelineOverview.empty(),
      perJobPipelines: [],
    );
  }
}

/// Widget 1: HiringStatsCard — 6 summary cards.
class HiringSummary {
  final int totalApplications;
  final int totalShortlisted;
  final int totalRejected;
  final int totalPending;
  final int totalJobs;
  final int totalPositions;

  const HiringSummary({
    required this.totalApplications,
    required this.totalShortlisted,
    required this.totalRejected,
    required this.totalPending,
    required this.totalJobs,
    required this.totalPositions,
  });

  factory HiringSummary.fromJson(Map<String, dynamic> json) {
    return HiringSummary(
      totalApplications: json['total_applications'] as int? ?? 0,
      totalShortlisted: json['total_shortlisted'] as int? ?? 0,
      totalRejected: json['total_rejected'] as int? ?? 0,
      totalPending: json['total_pending'] as int? ?? 0,
      totalJobs: json['total_jobs'] as int? ?? 0,
      totalPositions: json['total_positions'] as int? ?? 0,
    );
  }

  factory HiringSummary.empty() => const HiringSummary(
        totalApplications: 0,
        totalShortlisted: 0,
        totalRejected: 0,
        totalPending: 0,
        totalJobs: 0,
        totalPositions: 0,
      );
}

/// Widget 2: HiringJobChart — one segment per job in the donut.
class JobPositionData {
  final String jobTitle;
  final int positions;

  const JobPositionData({
    required this.jobTitle,
    required this.positions,
  });

  factory JobPositionData.fromJson(Map<String, dynamic> json) {
    return JobPositionData(
      jobTitle: json['job_title'] as String? ?? '',
      positions: json['positions'] as int? ?? 0,
    );
  }
}

/// Widget 3: HiringPipelineContainer — global pipeline overview.
class PipelineOverview {
  final ApplicationProgress applicationProgress;
  final InterviewProgress interviewProgress;

  const PipelineOverview({
    required this.applicationProgress,
    required this.interviewProgress,
  });

  factory PipelineOverview.fromJson(Map<String, dynamic> json) {
    return PipelineOverview(
      applicationProgress: ApplicationProgress.fromJson(
          json['application_progress'] as Map<String, dynamic>),
      interviewProgress: InterviewProgress.fromJson(
          json['interview_progress'] as Map<String, dynamic>),
    );
  }

  factory PipelineOverview.empty() => PipelineOverview(
        applicationProgress: ApplicationProgress.empty(),
        interviewProgress: InterviewProgress.empty(),
      );
}

class ApplicationProgress {
  final int shortlisted;
  final int pending;
  final int rejected;
  final int total;

  const ApplicationProgress({
    required this.shortlisted,
    required this.pending,
    required this.rejected,
    required this.total,
  });

  factory ApplicationProgress.fromJson(Map<String, dynamic> json) {
    return ApplicationProgress(
      shortlisted: json['shortlisted'] as int? ?? 0,
      pending: json['pending'] as int? ?? 0,
      rejected: json['rejected'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
    );
  }

  factory ApplicationProgress.empty() =>
      const ApplicationProgress(shortlisted: 0, pending: 0, rejected: 0, total: 0);
}

class InterviewProgress {
  final StageProgress telephonic;
  final StageProgress technical;
  final StageProgress onboarding;

  const InterviewProgress({
    required this.telephonic,
    required this.technical,
    required this.onboarding,
  });

  factory InterviewProgress.fromJson(Map<String, dynamic> json) {
    return InterviewProgress(
      telephonic: StageProgress.fromJson(json['telephonic'] as Map<String, dynamic>),
      technical: StageProgress.fromJson(json['technical'] as Map<String, dynamic>),
      onboarding: StageProgress.fromJson(json['onboarding'] as Map<String, dynamic>),
    );
  }

  factory InterviewProgress.empty() => InterviewProgress(
        telephonic: StageProgress.empty(),
        technical: StageProgress.empty(),
        onboarding: StageProgress.empty(),
      );
}

class StageProgress {
  final int active;
  final int eligible;

  const StageProgress({required this.active, required this.eligible});

  factory StageProgress.fromJson(Map<String, dynamic> json) {
    return StageProgress(
      active: json['active'] as int? ?? 0,
      eligible: json['eligible'] as int? ?? 0,
    );
  }

  factory StageProgress.empty() => const StageProgress(active: 0, eligible: 0);
}

/// Widget 4: HiringJobPipelines — one entry per job in the accordion.
class JobPipelineData {
  final String jobTitle;
  final int totalApplications;
  final int shortlisted;
  final int rejected;
  final int pending;
  final int telephonicActive;
  final int telephonicEligible;
  final int technicalActive;
  final int technicalEligible;
  final int onboardingActive;
  final int onboardingEligible;

  const JobPipelineData({
    required this.jobTitle,
    required this.totalApplications,
    required this.shortlisted,
    required this.rejected,
    required this.pending,
    required this.telephonicActive,
    required this.telephonicEligible,
    required this.technicalActive,
    required this.technicalEligible,
    required this.onboardingActive,
    required this.onboardingEligible,
  });

  factory JobPipelineData.fromJson(Map<String, dynamic> json) {
    return JobPipelineData(
      jobTitle: json['job_title'] as String? ?? '',
      totalApplications: json['total_applications'] as int? ?? 0,
      shortlisted: json['shortlisted'] as int? ?? 0,
      rejected: json['rejected'] as int? ?? 0,
      pending: json['pending'] as int? ?? 0,
      telephonicActive: json['telephonic_active'] as int? ?? 0,
      telephonicEligible: json['telephonic_eligible'] as int? ?? 0,
      technicalActive: json['technical_active'] as int? ?? 0,
      technicalEligible: json['technical_eligible'] as int? ?? 0,
      onboardingActive: json['onboarding_active'] as int? ?? 0,
      onboardingEligible: json['onboarding_eligible'] as int? ?? 0,
    );
  }
}

/// Filter parameters passed to the RPC.
class HiringFilterParams {
  final String? jobId;
  final String? hrManagerId;
  final DateTime? postingFrom;
  final DateTime? postingTo;
  final String? deadlineFrom;
  final String? deadlineTo;

  const HiringFilterParams({
    this.jobId,
    this.hrManagerId,
    this.postingFrom,
    this.postingTo,
    this.deadlineFrom,
    this.deadlineTo,
  });

  /// Convert to the Map<String, dynamic> expected by supabase.rpc().
  Map<String, dynamic> toRpcParams() {
    return {
      if (jobId != null) 'p_job_id': jobId,
      if (hrManagerId != null) 'p_hr_manager_id': hrManagerId,
      if (postingFrom != null) 'p_posting_from': postingFrom!.toIso8601String(),
      if (postingTo != null) 'p_posting_to': postingTo!.toIso8601String(),
      if (deadlineFrom != null) 'p_deadline_from': deadlineFrom,
      if (deadlineTo != null) 'p_deadline_to': deadlineTo,
    };
  }

  HiringFilterParams copyWith({
    String? Function()? jobId,
    String? Function()? hrManagerId,
    DateTime? Function()? postingFrom,
    DateTime? Function()? postingTo,
    String? Function()? deadlineFrom,
    String? Function()? deadlineTo,
  }) {
    return HiringFilterParams(
      jobId: jobId != null ? jobId() : this.jobId,
      hrManagerId: hrManagerId != null ? hrManagerId() : this.hrManagerId,
      postingFrom: postingFrom != null ? postingFrom() : this.postingFrom,
      postingTo: postingTo != null ? postingTo() : this.postingTo,
      deadlineFrom: deadlineFrom != null ? deadlineFrom() : this.deadlineFrom,
      deadlineTo: deadlineTo != null ? deadlineTo() : this.deadlineTo,
    );
  }

  static const HiringFilterParams empty = HiringFilterParams();
}
```

---

## 4. REPOSITORY LAYER

### File: `lib/view/hiring/data/datasources/hiring_remote_datasource.dart`

**CREATE this new file.**

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:employeeos/view/hiring/data/models/hiring_dashboard_model.dart';

class HiringRemoteDatasource {
  final SupabaseClient _client;

  HiringRemoteDatasource(this._client);

  /// Calls the single RPC that powers the entire dashboard.
  Future<Map<String, dynamic>> fetchDashboard(HiringFilterParams filters) async {
    final response = await _client.rpc(
      'get_hiring_dashboard',
      params: filters.toRpcParams(),
    );
    return response as Map<String, dynamic>;
  }

  /// Fetches the list of jobs for the Job Position filter dropdown.
  /// Returns list of {id, title}.
  Future<List<Map<String, dynamic>>> fetchJobDropdownOptions() async {
    final response = await _client
        .from('jobs')
        .select('id, title')
        .order('title', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Fetches the list of HR users for the HR Manager filter dropdown.
  /// Returns list of {id, full_name, email}.
  /// NOTE: Adjust table/column names to match your actual user_info table.
  Future<List<Map<String, dynamic>>> fetchHrDropdownOptions() async {
    final response = await _client
        .from('user_info')
        .select('id, full_name, email')
        .eq('role', 'HR')
        .order('full_name', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }
}
```

### File: `lib/view/hiring/data/repositories/hiring_repository.dart`

**CREATE this new file.**

```dart
import 'package:employeeos/view/hiring/data/datasources/hiring_remote_datasource.dart';
import 'package:employeeos/view/hiring/data/models/hiring_dashboard_model.dart';

class HiringRepository {
  final HiringRemoteDatasource _datasource;

  HiringRepository(this._datasource);

  /// Fetches and parses the full dashboard data.
  Future<HiringDashboardModel> getDashboard(HiringFilterParams filters) async {
    final raw = await _datasource.fetchDashboard(filters);
    return HiringDashboardModel.fromJson(raw);
  }

  /// Fetches job dropdown options for the filter.
  Future<List<Map<String, dynamic>>> getJobDropdownOptions() async {
    return _datasource.fetchJobDropdownOptions();
  }

  /// Fetches HR dropdown options for the filter (Admin only).
  Future<List<Map<String, dynamic>>> getHrDropdownOptions() async {
    return _datasource.fetchHrDropdownOptions();
  }
}
```

---

## 5. BLOC IMPLEMENTATION

### File: `lib/view/hiring/bloc/hiring_event.dart`

**CREATE this new file.**

```dart
import 'package:equatable/equatable.dart';
import 'package:employeeos/view/hiring/data/models/hiring_dashboard_model.dart';

abstract class HiringEvent extends Equatable {
  const HiringEvent();

  @override
  List<Object?> get props => [];
}

/// Fired on initial load. Fetches dashboard data + dropdown options.
class HiringLoadRequested extends HiringEvent {
  const HiringLoadRequested();
}

/// Fired when any filter changes. Carries the updated filter params.
class HiringFiltersChanged extends HiringEvent {
  final HiringFilterParams filters;
  const HiringFiltersChanged(this.filters);

  @override
  List<Object?> get props => [filters];
}

/// Fired when user taps "Clear Filters".
class HiringFiltersClearRequested extends HiringEvent {
  const HiringFiltersClearRequested();
}

/// Fired on pull-to-refresh.
class HiringRefreshRequested extends HiringEvent {
  const HiringRefreshRequested();
}
```

### File: `lib/view/hiring/bloc/hiring_state.dart`

**CREATE this new file.**

```dart
import 'package:equatable/equatable.dart';
import 'package:employeeos/view/hiring/data/models/hiring_dashboard_model.dart';

enum HiringStatus { initial, loading, success, failure }

class HiringState extends Equatable {
  final HiringStatus status;
  final HiringDashboardModel dashboard;
  final HiringFilterParams filters;
  final String? errorMessage;

  /// Dropdown data for filters (fetched once on initial load).
  final List<Map<String, dynamic>> jobOptions;
  final List<Map<String, dynamic>> hrOptions;

  const HiringState({
    this.status = HiringStatus.initial,
    this.dashboard = const HiringDashboardModel._internal(),
    this.filters = HiringFilterParams.empty,
    this.errorMessage,
    this.jobOptions = const [],
    this.hrOptions = const [],
  });

  /// Convenience constructor for the default initial state.
  factory HiringState.initial() => HiringState(
        dashboard: HiringDashboardModel.empty(),
      );

  HiringState copyWith({
    HiringStatus? status,
    HiringDashboardModel? dashboard,
    HiringFilterParams? filters,
    String? Function()? errorMessage,
    List<Map<String, dynamic>>? jobOptions,
    List<Map<String, dynamic>>? hrOptions,
  }) {
    return HiringState(
      status: status ?? this.status,
      dashboard: dashboard ?? this.dashboard,
      filters: filters ?? this.filters,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      jobOptions: jobOptions ?? this.jobOptions,
      hrOptions: hrOptions ?? this.hrOptions,
    );
  }

  @override
  List<Object?> get props =>
      [status, dashboard, filters, errorMessage, jobOptions, hrOptions];
}
```

> **NOTE:** The `const HiringDashboardModel._internal()` above won't compile. Replace the default value in HiringState with a non-const or use a factory. The simplest fix: make the HiringState constructor a factory that calls `HiringDashboardModel.empty()`:
>
> ```dart
> // In HiringState, change the default to:
> factory HiringState.initial() => HiringState(
>   status: HiringStatus.initial,
>   dashboard: HiringDashboardModel.empty(),
>   filters: HiringFilterParams.empty,
>   jobOptions: const [],
>   hrOptions: const [],
> );
> ```
> Use `HiringState.initial()` as the Bloc's initial state.

### File: `lib/view/hiring/bloc/hiring_bloc.dart`

**CREATE this new file.**

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:employeeos/view/hiring/bloc/hiring_event.dart';
import 'package:employeeos/view/hiring/bloc/hiring_state.dart';
import 'package:employeeos/view/hiring/data/models/hiring_dashboard_model.dart';
import 'package:employeeos/view/hiring/data/repositories/hiring_repository.dart';

class HiringBloc extends Bloc<HiringEvent, HiringState> {
  final HiringRepository _repository;

  HiringBloc({required HiringRepository repository})
      : _repository = repository,
        super(HiringState.initial()) {
    on<HiringLoadRequested>(_onLoadRequested);
    on<HiringFiltersChanged>(_onFiltersChanged);
    on<HiringFiltersClearRequested>(_onFiltersClearRequested);
    on<HiringRefreshRequested>(_onRefreshRequested);
  }

  Future<void> _onLoadRequested(
    HiringLoadRequested event,
    Emitter<HiringState> emit,
  ) async {
    emit(state.copyWith(status: HiringStatus.loading));
    try {
      // Fetch dashboard data + dropdown options in parallel.
      final results = await Future.wait([
        _repository.getDashboard(state.filters),
        _repository.getJobDropdownOptions(),
        _repository.getHrDropdownOptions(),
      ]);

      emit(state.copyWith(
        status: HiringStatus.success,
        dashboard: results[0] as HiringDashboardModel,
        jobOptions: results[1] as List<Map<String, dynamic>>,
        hrOptions: results[2] as List<Map<String, dynamic>>,
        errorMessage: () => null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HiringStatus.failure,
        errorMessage: () => e.toString(),
      ));
    }
  }

  Future<void> _onFiltersChanged(
    HiringFiltersChanged event,
    Emitter<HiringState> emit,
  ) async {
    emit(state.copyWith(
      status: HiringStatus.loading,
      filters: event.filters,
    ));
    try {
      final dashboard = await _repository.getDashboard(event.filters);
      emit(state.copyWith(
        status: HiringStatus.success,
        dashboard: dashboard,
        errorMessage: () => null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HiringStatus.failure,
        errorMessage: () => e.toString(),
      ));
    }
  }

  Future<void> _onFiltersClearRequested(
    HiringFiltersClearRequested event,
    Emitter<HiringState> emit,
  ) async {
    emit(state.copyWith(
      status: HiringStatus.loading,
      filters: HiringFilterParams.empty,
    ));
    try {
      final dashboard =
          await _repository.getDashboard(HiringFilterParams.empty);
      emit(state.copyWith(
        status: HiringStatus.success,
        dashboard: dashboard,
        errorMessage: () => null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HiringStatus.failure,
        errorMessage: () => e.toString(),
      ));
    }
  }

  Future<void> _onRefreshRequested(
    HiringRefreshRequested event,
    Emitter<HiringState> emit,
  ) async {
    try {
      final dashboard = await _repository.getDashboard(state.filters);
      emit(state.copyWith(
        status: HiringStatus.success,
        dashboard: dashboard,
        errorMessage: () => null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HiringStatus.failure,
        errorMessage: () => e.toString(),
      ));
    }
  }
}
```

---

## 6. WIDGET WIRING CHANGES

### 6A. `hiring_view.dart` — MODIFY

**What changes:**
- Wrap with `BlocProvider<HiringBloc>` at the top
- Fire `HiringLoadRequested` on init
- Wrap the body with `BlocBuilder<HiringBloc, HiringState>`
- Add loading spinner for `HiringStatus.loading`
- Add error state for `HiringStatus.failure`
- Replace all hardcoded data with `state.dashboard.*`
- Remove local `hiringData` list and local state for stats

**Key wiring:**

```dart
// In the widget tree above HiringView (or inside if HiringView is the page):
BlocProvider(
  create: (context) => HiringBloc(
    repository: HiringRepository(
      HiringRemoteDatasource(Supabase.instance.client),
    ),
  )..add(const HiringLoadRequested()),
  child: const HiringView(),
)
```

**Inside build():**

```dart
BlocBuilder<HiringBloc, HiringState>(
  builder: (context, state) {
    if (state.status == HiringStatus.loading && state.dashboard.summary.totalApplications == 0) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.status == HiringStatus.failure) {
      return Center(child: Text('Error: ${state.errorMessage}'));
    }

    final dashboard = state.dashboard;

    return SingleChildScrollView(
      // ... existing layout, but replace hardcoded values:
      children: [
        HiringFilters(
          jobOptions: state.jobOptions,
          hrOptions: state.hrOptions,
          // ... pass filter callbacks
        ),
        _buildStatsSection(theme, screenHeight, dashboard.summary),
        _buildResponsiveChartsSection(theme, dashboard),
        // ... job pipelines section with dashboard.perJobPipelines
      ],
    );
  },
)
```

**Replace `_buildStatsSection` hardcoded data:**

```dart
Widget _buildStatsSection(ThemeData theme, double screenHeight, HiringSummary summary) {
  final data = [
    {
      'title': 'Total Applications',
      'value': '${summary.totalApplications}',
      'valueColor': AppPallete.grey600,
      'height': isPortrait ? 120 : 100,
      'iconPath': 'assets/icons/common/solid/ic-solar-clipboard.svg',
    },
    {
      'title': 'Total Shortlisted',
      'value': '${summary.totalShortlisted}',
      'valueColor': AppPallete.teal,        // match existing color
      'height': isPortrait ? 120 : 100,
      'iconPath': '...',                    // keep existing icon path
    },
    {
      'title': 'Total Rejected',
      'value': '${summary.totalRejected}',
      'valueColor': AppPallete.red,
      'height': isPortrait ? 120 : 100,
      'iconPath': '...',
    },
    {
      'title': 'Pending',
      'value': '${summary.totalPending}',
      'valueColor': AppPallete.orange,
      'height': isPortrait ? 120 : 100,
      'iconPath': '...',
    },
    {
      'title': 'Jobs',
      'value': '${summary.totalJobs}',
      'valueColor': AppPallete.blue,
      'height': isPortrait ? 120 : 100,
      'iconPath': '...',
    },
    {
      'title': 'Positions',
      'value': '${summary.totalPositions}',
      'valueColor': AppPallete.green,
      'height': isPortrait ? 120 : 100,
      'iconPath': '...',
    },
  ];
  return HiringStatsCard(data: data);
}
```

> **Note:** Keep the exact icon paths and colors from the current hardcoded implementation. Only replace the `'value'` strings with the model fields.

---

### 6B. `hiring_filters.dart` — MODIFY

**What changes:**
- Accept `jobOptions` and `hrOptions` as constructor params (List<Map<String, dynamic>>)
- Populate dropdowns dynamically from those lists instead of hardcoded values
- On any filter change, dispatch `HiringFiltersChanged` to the Bloc
- On "Clear Filters", dispatch `HiringFiltersClearRequested`

**Constructor change:**

```dart
class HiringFilters extends StatefulWidget {
  final List<Map<String, dynamic>> jobOptions;
  final List<Map<String, dynamic>> hrOptions;
  // ... keep existing controller params if still needed, OR remove them
  // since filter state now lives in the Bloc

  const HiringFilters({
    super.key,
    required this.jobOptions,
    required this.hrOptions,
  });
}
```

**On filter apply (whenever a dropdown or date changes):**

```dart
void _applyFilters() {
  final filters = HiringFilterParams(
    jobId: selectedJob,          // UUID string from dropdown
    hrManagerId: selectedHR,     // UUID string from dropdown
    postingFrom: _parseDate(_postingDateFromController.text),
    postingTo: _parseDate(_postingDateToController.text),
    deadlineFrom: _lastDateFromController.text.isNotEmpty
        ? _lastDateFromController.text   // Pass as DD/MM/YYYY string
        : null,
    deadlineTo: _lastDateToController.text.isNotEmpty
        ? _lastDateToController.text
        : null,
  );
  context.read<HiringBloc>().add(HiringFiltersChanged(filters));
}
```

**On clear:**

```dart
void _clearFilters() {
  setState(() {
    selectedJob = null;
    selectedHR = null;
    _postingDateFromController.clear();
    _postingDateToController.clear();
    _lastDateFromController.clear();
    _lastDateToController.clear();
  });
  context.read<HiringBloc>().add(const HiringFiltersClearRequested());
}
```

**Dropdown population example (Job Position):**

```dart
DropdownButton<String>(
  value: selectedJob,
  hint: const Text('Job Position'),
  items: [
    const DropdownMenuItem(value: null, child: Text('All Jobs')),
    ...widget.jobOptions.map((job) => DropdownMenuItem(
          value: job['id'] as String,
          child: Text(job['title'] as String),
        )),
  ],
  onChanged: (value) {
    setState(() => selectedJob = value);
    _applyFilters();
  },
)
```

---

### 6C. `hiring_job_chart.dart` — MODIFY

**What changes:**
- Accept `List<JobPositionData>` instead of `List<HiringData>?` or hardcoded data
- Remove the fallback hardcoded `_chartData` getter
- Assign colors client-side from a predefined palette based on index

**Constructor change:**

```dart
class HiringJobChart extends StatefulWidget {
  final ThemeData theme;
  final List<JobPositionData> data;  // ← NEW required param

  const HiringJobChart({
    super.key,
    required this.theme,
    required this.data,
  });
}
```

**Chart data mapping:**

```dart
// Predefined color palette for donut segments
static const List<Color> _chartColors = [
  AppPallete.primaryLighter,
  AppPallete.primaryLight,
  AppPallete.primary,
  AppPallete.primaryDark,
  // ... add more as needed
];

List<ChartData> get _chartData {
  return widget.data.asMap().entries.map((entry) {
    return ChartData(
      label: entry.value.jobTitle,
      value: entry.value.positions,
      color: _chartColors[entry.key % _chartColors.length],
    );
  }).toList();
}

int get _totalPositions {
  return widget.data.fold(0, (sum, item) => sum + item.positions);
}
```

---

### 6D. `hiring_pipeline_container.dart` — MODIFY

**What changes:**
- Accept `PipelineOverview` as a required param
- Pass real values to each `HiringPipelineMetric` widget

**Constructor change:**

```dart
class HiringPipelineContainer extends StatelessWidget {
  final ThemeData theme;
  final bool big;
  final PipelineOverview data;  // ← NEW required param

  const HiringPipelineContainer({
    super.key,
    required this.theme,
    required this.big,
    required this.data,
  });
}
```

**Wiring the 6 gauges (inside build):**

```dart
// Row 1: Shortlisted | Telephonic
Row(children: [
  Expanded(child: HiringPipelineMetric(
    theme: theme,
    big: big,
    title: 'Shortlisted',
    value: '${data.applicationProgress.shortlisted}',
    subtitle: 'of ${data.applicationProgress.total}',
    progress: data.applicationProgress.total > 0
        ? data.applicationProgress.shortlisted / data.applicationProgress.total
        : 0,
    circleColor: Colors.teal,
  )),
  Expanded(child: HiringPipelineMetric(
    theme: theme,
    big: big,
    title: 'Telephonic',
    value: '${data.interviewProgress.telephonic.active}',
    subtitle: 'scheduled/completed out of ${data.interviewProgress.telephonic.eligible} eligible',
    progress: _safeProgress(
      data.interviewProgress.telephonic.active,
      data.interviewProgress.telephonic.active + data.interviewProgress.telephonic.eligible,
    ),
    circleColor: Colors.blue,
  )),
]),

// Row 2: Pending | Technical
Row(children: [
  Expanded(child: HiringPipelineMetric(
    theme: theme,
    big: big,
    title: 'Pending',
    value: '${data.applicationProgress.pending}',
    subtitle: 'of ${data.applicationProgress.total}',
    progress: data.applicationProgress.total > 0
        ? data.applicationProgress.pending / data.applicationProgress.total
        : 0,
    circleColor: Colors.orange,
  )),
  Expanded(child: HiringPipelineMetric(
    theme: theme,
    big: big,
    title: 'Technical',
    value: '${data.interviewProgress.technical.active}',
    subtitle: 'scheduled/completed out of ${data.interviewProgress.technical.eligible} eligible',
    progress: _safeProgress(
      data.interviewProgress.technical.active,
      data.interviewProgress.technical.active + data.interviewProgress.technical.eligible,
    ),
    circleColor: Colors.purple,
  )),
]),

// Row 3: Rejected | Onboarding
Row(children: [
  Expanded(child: HiringPipelineMetric(
    theme: theme,
    big: big,
    title: 'Rejected',
    value: '${data.applicationProgress.rejected}',
    subtitle: 'of ${data.applicationProgress.total}',
    progress: data.applicationProgress.total > 0
        ? data.applicationProgress.rejected / data.applicationProgress.total
        : 0,
    circleColor: Colors.red,
  )),
  Expanded(child: HiringPipelineMetric(
    theme: theme,
    big: big,
    title: 'Onboarding',
    value: '${data.interviewProgress.onboarding.active}',
    subtitle: 'in progress out of ${data.interviewProgress.onboarding.eligible} eligible',
    progress: _safeProgress(
      data.interviewProgress.onboarding.active,
      data.interviewProgress.onboarding.active + data.interviewProgress.onboarding.eligible,
    ),
    circleColor: Colors.green,
  )),
]),
```

**Helper:**

```dart
double _safeProgress(int numerator, int denominator) {
  if (denominator <= 0) return 0;
  return numerator / denominator;
}
```

---

### 6E. `hiring_pipeline_metric.dart` — MODIFY (minor)

**What changes:**
- The `progress` value is currently hardcoded to `86.6`. Accept it as a parameter.
- The `value` (RangePointer) should use the progress param × 100.

**Add to constructor (if not already present):**

```dart
final double progress;  // 0.0 to 1.0
```

**In the gauge:**

```dart
RangePointer(
  value: (widget.progress * 100).clamp(0, 100),  // ← was hardcoded 86.6
  // ... rest unchanged
)
```

---

### 6F. `hiring_job_pipelines.dart` — MODIFY

**What changes:**
- Accept `List<JobPipelineData>` from the Bloc state instead of local `hiringData`
- Remove the locally defined `HiringPipelineData` class (replaced by `JobPipelineData` from models)
- Remove hardcoded sample data
- When a job expands, render `HiringPipelineContainer` with per-job data converted to a `PipelineOverview`

**Constructor change:**

```dart
class HiringJobPipelines extends StatefulWidget {
  final List<JobPipelineData> data;  // ← NEW, replaces local hiringData
  // ... keep scrollController, theme, etc.
}
```

**Building the expanded content for a job:**

```dart
PipelineOverview _buildPerJobOverview(JobPipelineData job) {
  return PipelineOverview(
    applicationProgress: ApplicationProgress(
      shortlisted: job.shortlisted,
      pending: job.pending,
      rejected: job.rejected,
      total: job.totalApplications,
    ),
    interviewProgress: InterviewProgress(
      telephonic: StageProgress(active: job.telephonicActive, eligible: job.telephonicEligible),
      technical: StageProgress(active: job.technicalActive, eligible: job.technicalEligible),
      onboarding: StageProgress(active: job.onboardingActive, eligible: job.onboardingEligible),
    ),
  );
}
```

Then pass it to `HiringPipelineContainer(data: _buildPerJobOverview(jobData), ...)`.

---

### 6G. `hiring_model.dart` — MODIFY

**What to remove:**
- The entire `JobTitle` enum
- The `JobTitleExtension`
- The `HiringData` class (replaced by `JobPositionData` in the new models file)

**What to keep:**
- Nothing. This file can be deleted entirely, OR kept empty as a barrel file re-exporting from the new models file.

**If keeping as a re-export:**

```dart
export 'package:employeeos/view/hiring/data/models/hiring_dashboard_model.dart';
```

---

## 7. FILTER DROPDOWN DATA

### Job Position dropdown
Populated from `state.jobOptions` (fetched via `HiringRemoteDatasource.fetchJobDropdownOptions()`).

Each item: `{ 'id': 'uuid-string', 'title': 'Senior Flutter Developer' }`

The selected value is the `id` (UUID), which maps to `HiringFilterParams.jobId` → `p_job_id` in the RPC.

### HR Manager dropdown (Admin only)
Populated from `state.hrOptions` (fetched via `HiringRemoteDatasource.fetchHrDropdownOptions()`).

Each item: `{ 'id': 'uuid-string', 'full_name': 'Yash Nautiyal', 'email': 'yash@f13.tech' }`

Display: `full_name` (or `email` as fallback). Selected value is `id` → `HiringFilterParams.hrManagerId` → `p_hr_manager_id`.

**Visibility:** Only show the HR Manager dropdown if the current user's role is `ADMIN`. Check this from whatever role resolution mechanism exists in the app (likely `user_info` or auth metadata).

---

## 8. FILE-BY-FILE CHANGE SUMMARY

| File | Action | Description |
|------|--------|-------------|
| `supabase/migrations/YYYYMMDDHHMMSS_hiring_dashboard_rpc.sql` | **CREATE** | The `get_hiring_dashboard` RPC function |
| `lib/view/hiring/data/models/hiring_dashboard_model.dart` | **CREATE** | All Dart models + `HiringFilterParams` |
| `lib/view/hiring/data/datasources/hiring_remote_datasource.dart` | **CREATE** | Supabase RPC call + dropdown fetchers |
| `lib/view/hiring/data/repositories/hiring_repository.dart` | **CREATE** | Repository wrapping the datasource |
| `lib/view/hiring/bloc/hiring_event.dart` | **CREATE** | Bloc events |
| `lib/view/hiring/bloc/hiring_state.dart` | **CREATE** | Bloc state |
| `lib/view/hiring/bloc/hiring_bloc.dart` | **CREATE** | Bloc implementation |
| `lib/view/hiring/domain/entities/hiring_model.dart` | **DELETE or REPLACE** | Remove `JobTitle` enum, `HiringData` class; re-export new models |
| `lib/view/hiring/presentation/pages/hiring_view.dart` | **MODIFY** | Add BlocProvider, BlocBuilder, wire state to widgets |
| `lib/view/hiring/presentation/widget/hiring_filters.dart` | **MODIFY** | Accept dropdown data, dispatch Bloc events on change |
| `lib/view/hiring/presentation/widget/hiring_job_chart.dart` | **MODIFY** | Accept `List<JobPositionData>`, remove hardcoded data |
| `lib/view/hiring/presentation/widget/hiring_job_pipelines.dart` | **MODIFY** | Accept `List<JobPipelineData>`, remove local `HiringPipelineData` class + sample data |
| `lib/view/hiring/presentation/widget/hiring_pipeline_container.dart` | **MODIFY** | Accept `PipelineOverview`, wire real values to gauges |
| `lib/view/hiring/presentation/widget/hiring_pipeline_metric.dart` | **MODIFY** | Accept `progress` param, replace hardcoded 86.6 |
| `lib/view/hiring/presentation/widget/hiring_stats_card.dart` | **NO CHANGE** | Already accepts data list via constructor |
| `lib/view/hiring/presentation/widget/hiring_nav_button.dart` | **NO CHANGE** | |

---

## 9. TESTING CHECKLIST

### RPC verification (run in Supabase SQL Editor)
```sql
-- No filters — should return all jobs, all apps, all interviews
SELECT get_hiring_dashboard();

-- Filter by specific job
SELECT get_hiring_dashboard(p_job_id := 'your-job-uuid-here');

-- Filter by HR manager
SELECT get_hiring_dashboard(p_hr_manager_id := 'your-hr-uuid-here');

-- Filter by posting date range
SELECT get_hiring_dashboard(
  p_posting_from := '2025-01-01T00:00:00Z',
  p_posting_to   := '2025-12-31T23:59:59Z'
);

-- Filter by application deadline
SELECT get_hiring_dashboard(
  p_deadline_from := '01/01/2025',
  p_deadline_to   := '31/12/2025'
);

-- Empty result (non-existent job) — should return all zeros, empty arrays
SELECT get_hiring_dashboard(p_job_id := '00000000-0000-0000-0000-000000000000');
```

### UI verification
- [ ] Dashboard loads with spinner, then shows data
- [ ] All 6 stat cards show correct numbers
- [ ] Donut chart shows only active jobs with positions > 0
- [ ] Donut total in center matches sum of segments
- [ ] Pipeline overview gauges show correct values and progress arcs
- [ ] Per-job accordion shows all jobs ordered by total applications DESC
- [ ] Expanding a job shows correct per-job breakdown
- [ ] Selecting a Job Position filter reloads data scoped to that job
- [ ] Selecting an HR Manager filter (as Admin) reloads data scoped to that HR
- [ ] Date range filters work correctly
- [ ] "Clear Filters" resets all dropdowns/dates and reloads unfiltered data
- [ ] HR Manager dropdown is hidden for non-Admin users
- [ ] Empty state (no jobs/apps) shows zeros everywhere, empty donut, empty accordion
- [ ] Error state shows error message if RPC fails
- [ ] Pull-to-refresh works (if implemented)

---

## KNOWN LIMITATIONS (V1)

1. **`last_date` is stored as text** — deadline filter uses `TO_DATE(j.last_date, 'DD/MM/YYYY')`. If any job has `last_date` in a different format or empty string, the RPC will handle it (empty strings are filtered out), but inconsistent date formats will produce wrong results. Future fix: migrate `last_date` to `DATE` type.

2. **`positions` is stored as text** — handled with `NULLIF(TRIM(positions), '')::int` + COALESCE. Non-numeric values will cause a runtime error. Future fix: migrate `positions` to `INTEGER` type.

3. **No role enforcement inside the RPC** — the client must pass `p_hr_manager_id = currentUser.id` for HR users. Admin passes null (or a specific HR's UUID when filtering). This is by design — SECURITY INVOKER respects RLS, and the client controls the filter.

4. **`selected` interview stage is excluded from dashboard gauges** — it exists in the interview scheduling flow but is not displayed in the pipeline overview. This is intentional for V1.

5. **No real-time updates** — dashboard data is fetched on load and on filter change. No Supabase Realtime subscription. Future consideration for V2.

---

_End of explainer. This document contains everything needed to implement the hiring dashboard end-to-end._
