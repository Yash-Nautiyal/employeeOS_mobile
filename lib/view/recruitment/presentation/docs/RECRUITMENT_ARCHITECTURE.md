# Recruitment Architecture Reference

Working reference for the Recruitment module so paths and workflows stay aligned with the code.

**Related:** [Interview round UX & pipeline (design)](RECRUITMENT_INTERVIEW_FLOW.md) — tab rules, eligible/scheduled, rejected column.

---

## Database Structure

### `jobs`

- Primary key: `id` (uuid)
- Business id: `job_id` (text, unique)
- Main fields used by mobile:
  - `title`, `department`, `description`, `location`
  - `is_internship`, `expected_ctc_range` (or `ctc_range` depending on migration), `is_active`
  - `joining_type`, `positions`, `last_date` / `last_date_to_apply` (see `JobPostingModel` for read/write mapping)
  - `posted_by_name`, `posted_by_email`
  - `created_at`, `updated_at`, `created_by`
- Triggers (if present in your Supabase project):
  - `set_job_application_link` (before insert)
  - `set_updated_at` (before update)

### `applications`

- Primary key: `id` (text, generated)
- Foreign key: `job_id` → `jobs.id` (uuid)
- Main fields:
  - `applicant_name`, `email`, `phone_number`, `resume_url`
  - `status`, `current_stage`
  - `created_at`, `updated_at`, `created_by`
- Indexes: `job_id`, `created_at`, `status`
- Trigger: `update_applications_updated_at` (before update)

#### `applications.status`

The app treats three values as the main lifecycle (lowercase in DB):

| Value         | Meaning                         |
| ------------- | ------------------------------- |
| `pending`     | Not yet shortlisted or rejected |
| `shortlisted` | Moving into the interview flow  |
| `rejected`    | Not proceeding                  |

Legacy rows may still use other strings (e.g. `Applied`); shortlist/reject guards accept `pending`, `applied`, or empty as “still actionable” for shortlist (`ApplicationStatusActions`).

#### `applications.current_stage`

- **Shortlist:** set `current_stage` to the first interview round (`ApplicationPipelineStage.firstInterviewRound` → `telephone` in code).
- **Reject:** set `current_stage` to `rejected` (same literal as `status`).
- Later rounds can be driven by backend or future mobile work; this module only defines those two writes from the job-application actions.

Constants: `domain/job_application/application_db_values.dart`.

### `interviews`

Schema is documented for when scheduling is backed by Supabase. **The mobile interview scheduling UI does not read/write this table yet** — it uses an in-memory local datasource (see below).

- Primary key: `id` (uuid)
- Foreign key: `application_id` → `applications.id` (text)
- Main fields:
  - `stage`, `status`, `schedule_date`
  - `interviewer`, `assigned_by`, `feedback`, `duration_minutes`
  - `google_event_id`, `google_meet_link`, `calendar_event_details`, `meet_link`
  - `created_at`, `updated_at`, `created_by`
- Indexes: `application_id`, `stage`, `status`, `schedule_date`
- Trigger: `update_interviews_updated_at` (before update)

---

## Core app: remote calls

- **`lib/core/network/run_supabase_remote.dart`** — wraps Supabase/PostgREST futures with a timeout and maps errors to **`RemoteDataException`** (`lib/core/network/remote_data_exception.dart`).
- Recruitment **job posting** and **job application** remote datasources use this helper.
- **`main.dart`** treats `RemoteDataException` as a non-fatal global async error (no Flutter error screen) when something still slips through unhandled.

---

## UI / feature layout

Under `lib/view/recruitment/`:

1. **job_posting**
2. **job_application**
3. **interview_scheduling**

---

### Job posting (Supabase)

- **Data:** `data/job_posting/datasources/job_posting_remote_datasource.dart` → `repositories/job_posting_repository_impl.dart`
- **Domain:** `entities/job_posting.dart`, `repositories/job_posting_repository.dart`, use cases (`get_all_jobs`, `get_job_by_id`, `add_job`, `update_job`, `delete_job`, `toggle_job_status`, job departments, job applications page, bulk status updates, etc.)
- **Presentation:** `bloc/job_posting/job_posting_bloc.dart`, `job_posting_detail_cubit.dart`, `pages/job_posting_section.dart`, `widget/job_posting/...`
- **Filters:** `presentation/utils/job_posting_filter_logic.dart` + shared `widget/job_posting/components/filter/job_filter_panel.dart`

### Job applications (Supabase)

- **Data:** `data/job_application/datasources/job_application_remote_datasource.dart` → `repositories/job_application_repository_impl.dart`
- **Domain:** `entities/job_application.dart`, `repositories/job_application_repository.dart`, use cases: `get_job_applications`, `shortlist_job_application`, `reject_job_application`
- **Presentation:** `bloc/job_application/job_application_bloc.dart`, `pages/job_application_view.dart`, `widget/job_application/...`
- **Filters:** `presentation/utils/job_application_filter_logic.dart` + same **`JobPostingFilterPanel`** with `showApplicationStatusFilter: true` for application status
- **Bridge to interview pipeline (today):** On successful **shortlist**, `JobApplicationRepositoryImpl` calls **`InterviewSchedulingLocalDataSource.syncEligibleFromShortlistedApplication`** so the interview screen’s in-memory list gets a **Telephone / Eligible** row keyed by the same `applicationId`.

### Interview scheduling (in-memory + Calendar)

- **Data:** `data/interview_scheduling/datasources/interview_scheduling_local_data_source.dart` (seed rows + mutations). **No remote datasource yet.**
- **Repository:** `data/interview_scheduling/repositories/interview_scheduling_repository_impl.dart`
  - On the **first** `fetchCandidates()` only, it optionally merges candidates from **`JobApplicationMockDatasource`** (mock “Shortlisted” rows) into the local list — **legacy/demo path**. Real shortlists from Supabase are mirrored via **`syncEligibleFromShortlistedApplication`** (see job applications above), not via that merge.
- **Domain:** `entities/interview_candidate.dart`, `interview_enums.dart`, `repositories/interview_scheduling_repository.dart`, `usecases/get_interview_candidates_usecase.dart`
- **Presentation:** `bloc/interview_scheduling/interview_scheduling_bloc.dart`, `pages/interview_scheduling_view.dart`, `widget/interview_scheduling/...`
- **Round / tab rules:** `InterviewRound.usesEligibleScheduledTabs` is `true` only for **telephone** and **technical** — Eligible | Scheduled sub-tabs match [RECRUITMENT_INTERVIEW_FLOW.md](RECRUITMENT_INTERVIEW_FLOW.md).

#### Interview scheduling pipeline (actual code path)

1. **Load:** `InterviewSchedulingStarted` → use case → repository → local datasource list (after one-time mock merge + any synced shortlists).
2. **Schedule (Eligible tab):** User fills **`schedule_interview_form_dialog`** → **`openGoogleCalendarTemplateEvent`** (browser / intent) with title/details from **`interview_calendar_event_copy.dart`** → optional **`showMeetingScheduledConfirmationDialog`** → if confirmed, **`InterviewScheduleSubmitted`** → repository **`scheduleInterviews`** (local: status `Scheduled`, fake date offset).
3. **Select / Reject / Onboard / Flush:** Bloc events **`InterviewSelectSubmitted`**, **`InterviewRejectSubmitted`**, **`InterviewOnboardSubmitted`**, **`InterviewFlushSubmitted`** → repository methods (`selectAfterInterview`, `rejectInterviews`, `onboardFromSelected`, `flushOnboardingToEmployees`) updating **`pipelineRound`** and status strings in memory (telephone → technical → selected → onboarding → removed on flush; reject → rejected tab + `rejectedFromRound`).

Nothing in this pipeline persists to the **`interviews`** table yet.

### Rich text (job description)

- Editor: Flutter Quill; stored as HTML in `jobs.description` for web compatibility.
- Codec: `presentation/utils/quill_description_codec.dart` (read legacy Delta JSON + HTML; write HTML).

---

## Current boundaries

- **BLoC / Cubit:** server-backed state for jobs and applications; interview scheduling state is local list + filters + selection.
- **UI:** ephemeral state (search, filters, sort, tab indices).
- **Filter logic** lives in `presentation/utils/` (`job_posting_filter_logic.dart`, `job_application_filter_logic.dart`), not inside page widgets.

---

## Planned / follow-up

1. ~~Job applications on `applications` table (Supabase)~~ — done.
2. **Interview scheduling:** replace `InterviewSchedulingLocalDataSource` + mock merge with **`interviews`** (and optionally sync `applications.current_stage` / round from server).
3. Remove or gate **`JobApplicationMockDatasource`** usage from **`InterviewSchedulingRepositoryImpl`** once all shortlist traffic comes from Supabase + sync (or from API).
4. Optional: unify status casing in interview local model with DB (`shortlisted` vs display labels).
