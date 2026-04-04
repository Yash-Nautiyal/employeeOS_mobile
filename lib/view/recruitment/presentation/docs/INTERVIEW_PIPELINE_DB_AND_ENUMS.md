# Interview pipeline: database columns, stages, and statuses

This document defines **allowed values** for `public.interviews.stage` and `public.interviews.status`, how they map to **Flutter enums**, and how they relate to **UI tabs**. Use **lowercase** strings in the database for consistency with `applications.status` (`pending`, `shortlisted`, `rejected`).

**Related:** [RECRUITMENT_INTERVIEW_FLOW.md](RECRUITMENT_INTERVIEW_FLOW.md), [RECRUITMENT_ARCHITECTURE.md](RECRUITMENT_ARCHITECTURE.md).

---

## Row model: Option B — single moving row

**One interview row per application** (`application_id` unique in practice). The candidate moves through the pipeline by **updating** the same row:

- **`stage`** = current **round** (telephone → technical → selected → onboarding).
- **`status`** = where they are **inside that round** (eligible, scheduled, passed, rejected).

Advancing to the next round is an **UPDATE**: set `stage` to the next value and reset `status` to `eligible` (or your chosen initial status for that round). No second row per stage.

**Rejected:** set `status = 'rejected'`. **`stage`** remains the round they were in when rejected (so the Rejected tab can show “rejected in telephone”, etc.).

**Alignment with `applications.current_stage`:** Keep it in sync with **`interviews.stage`** (and application-level `status` for terminal reject if you use it elsewhere).

**Integrity:** Prefer a **unique constraint on `application_id`** (one active pipeline row per application). Revisit only if you later need history/archival as separate rows.

---

## Column priority (now vs later)

### In scope now (main columns)

These are the fields the first implementation should care about:

| Column                                         | Role                                   |
| ---------------------------------------------- | -------------------------------------- |
| `application_id`                               | FK → `applications.id`.                |
| `stage`                                        | Current pipeline round (see below).    |
| `status`                                       | Position within the round (see below). |
| `schedule_date`                                | When the interview is (`timestamptz`). |
| `interviewer`                                  | Who interviews (text: name or email).  |
| `assigned_by`                                  | Who scheduled / assigned (text).       |
| `id`, `created_at`, `updated_at`, `created_by` | Standard row metadata.                 |

### Deferred (future)

Not required for the initial pipeline; columns exist in the schema for later product work:

| Column                   | Note                                                |
| ------------------------ | --------------------------------------------------- |
| `duration_minutes`       | Slot length — add when scheduling UX needs it.      |
| `meet_link`              | Meeting URL — add with calendar / meet integration. |
| `google_meet_link`       | Same intent, Google-specific.                       |
| `google_event_id`        | Calendar sync / idempotency.                        |
| `calendar_event_details` | Raw Calendar JSON.                                  |
| `feedback`               | Post-round or reject notes.                         |

---

## `interviews.stage` (round)

Stored as **lowercase** text. Aligns with `InterviewRound` in the app (the **Rejected** tab is still a filter on **`status`**, not a `stage` value).

| DB value     | Flutter `InterviewRound` | UI (top-level tab) |
| ------------ | ------------------------ | ------------------ |
| `telephone`  | `telephone`              | Telephone Round    |
| `technical`  | `technical`              | Technical Round    |
| `selected`   | `selected`               | Selected           |
| `onboarding` | `onboarding`             | Onboarding         |

---

## `interviews.status` (within the current round)

Stored as **lowercase** text. Drives **Eligible** vs **Scheduled** for telephone and technical.

| DB value    | Meaning                                                                                                                   | Typical main fields                                                                                | UI sub-tab / screen     |
| ----------- | ------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------- | ----------------------- |
| `eligible`  | In this round, **not** scheduled yet.                                                                                     | `schedule_date` usually `NULL`; interviewer / assigned_by may be empty until schedule.             | **Eligible**            |
| `scheduled` | Interview **booked** for this round.                                                                                      | **`schedule_date` set**; **`interviewer`**, **`assigned_by`** as collected in the flow.            | **Scheduled**           |
| `passed`    | Cleared this round; next action is to **bump `stage`** and set `status` back to `eligible` for the next round (same row). | Optional use of `passed` as a short-lived state, or skip straight to stage+eligible in one update. | (transition / internal) |
| `rejected`  | Stopped in the pipeline.                                                                                                  | `stage` = round they left from.                                                                    | **Rejected** tab        |

**Eligible vs scheduled**

- **Eligible:** `status = 'eligible'`.
- **Scheduled:** `status = 'scheduled'` **and** `schedule_date IS NOT NULL` (enforce in app or optional DB `CHECK`).

**Rounds without Eligible/Scheduled:** For `selected` and `onboarding`, the UI may use a single list; define statuses as you implement those tabs (document new values here).

---

## Flutter-side references

| Concept                       | Location                                                                                         |
| ----------------------------- | ------------------------------------------------------------------------------------------------ |
| UI round tabs                 | `domain/interview_scheduling/entities/interview_enums.dart` → `InterviewRound`                   |
| Eligible / Scheduled sub-tabs | `InterviewCandidateTab`                                                                          |
| DB string constants (partial) | `domain/interview_scheduling/interview_db_values.dart` → `InterviewDbStage`, `InterviewDbStatus` |

**Implementation status:** `InterviewDbStage` / `InterviewDbStatus` in code currently expose only shortlist defaults (`telephone`, `eligible`). Extend as schedule / pass / reject / stage transitions are implemented.

---

## Suggested query patterns (reference)

- Telephone **Eligible:** `stage = 'telephone' AND status = 'eligible'`
- Telephone **Scheduled:** `stage = 'telephone' AND status = 'scheduled'`
- Technical **Eligible / Scheduled:** same with `stage = 'technical'`
- **Rejected** tab: `status = 'rejected'` (use `stage` for “round rejected in”)

Indexes (`application_id`, `stage`, `status`, `schedule_date`) support these filters.

---

## Optional: DB constraints

- `CHECK`: `status = 'scheduled'` implies `schedule_date IS NOT NULL`.
- `UNIQUE (application_id)` if you commit to **Option B** only.

---

## Document history

- **v1** — Canonical `stage` / `status` values; multi-row-per-stage option.
- **v2** — **Option B (single moving row)**; column priority (interviewer, assigned_by, schedule date vs deferred links/duration/feedback); unique on `application_id`.
