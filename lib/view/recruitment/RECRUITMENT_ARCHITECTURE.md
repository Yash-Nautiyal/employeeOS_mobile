# Recruitment Architecture Reference

This document is a working reference for the Recruitment module so implementation details do not get lost between iterations.

## Database Structure

### `jobs`

- Primary key: `id` (uuid)
- Business id: `job_id` (text, unique)
- Main fields used by mobile:
  - `title`, `department`, `description`, `location`
  - `is_internship`, `expected_ctc_range`, `is_active`
  - `joining_type`, `positions`, `last_date`
  - `posted_by_name`, `posted_by_email`
  - `created_at`, `updated_at`, `created_by`
- Triggers:
  - `set_job_application_link` (before insert)
  - `set_updated_at` (before update)

### `applications`

- Primary key: `id` (text, generated)
- Foreign key: `job_id` -> `jobs.id` (uuid)
- Main fields:
  - `applicant_name`, `email`, `phone_number`, `resume_url`
  - `status`, `current_stage`
  - `created_at`, `updated_at`, `created_by`
- Indexes: `job_id`, `created_at`, `status`
- Trigger: `update_applications_updated_at` (before update)

### `interviews`

- Primary key: `id` (uuid)
- Foreign key: `application_id` -> `applications.id` (text)
- Main fields:
  - `stage`, `status`, `schedule_date`
  - `interviewer`, `assigned_by`, `feedback`, `duration_minutes`
  - `google_event_id`, `google_meet_link`, `calendar_event_details`, `meet_link`
  - `created_at`, `updated_at`, `created_by`
- Indexes: `application_id`, `stage`, `status`, `schedule_date`
- Trigger: `update_interviews_updated_at` (before update)

## UI / Feature Structure

Under `lib/view/recruitment/` there are 3 feature sections:

1. `job_posting`
2. `job_application`
3. `interview_scheduling`

### Job Posting (current implementation snapshot)

- Data path:
  - `data/job_posting/datasources/job_posting_remote_datasource.dart`
  - `data/job_posting/repositories/job_posting_repository_impl.dart`
- Domain:
  - `entities/job_posting.dart`
  - `repositories/job_posting_repository.dart`
  - use cases:
    - `get_all_jobs`, `get_job_by_id`
    - `add_job`, `update_job`, `delete_job`
    - `toggle_job_status`, `get_job_department`
- Presentation:
  - `bloc/job_posting/job_posting_bloc.dart`
  - `pages/job_posting_section.dart` (provides bloc)
  - `widget/job_posting/job_posting_view.dart`
  - `widget/job_posting/components/...`

### Rich Text Format

- Mobile editor: Flutter Quill document.
- Stored format in DB (`jobs.description`): HTML (for web compatibility).
- Compatibility codec:
  - `presentation/utils/quill_description_codec.dart`
  - Reads both legacy Delta JSON and HTML.
  - Writes HTML.

## Current Boundaries

- BLoC handles server/domain state (jobs, counts, mutations, loading, errors).
- UI holds ephemeral screen state (search text, selected filters, sort option).
- Filtering/sorting logic is separated into:
  - `presentation/utils/job_posting_filter_logic.dart`

## Next Planned Phases

1. Job Posting hardening complete (add/update/delete/close, HTML description support)
2. Move Job Applications from mock to `applications` table
3. Move Interview Scheduling from local/mock to `interviews` table and align pipeline transitions
