# Recruitment implementation — phased plan

## Principle: swap only the data layer later

| Layer                                                  | Now                                                    | Later (database)        |
| ------------------------------------------------------ | ------------------------------------------------------ | ----------------------- |
| **Presentation** (pages, widgets, blocs)               | Unchanged                                              | Unchanged               |
| **Domain** (entities, repository contracts, use cases) | Unchanged                                              | Unchanged               |
| **Data — repository impl**                             | Thin: delegates to remote datasource                   | Same                    |
| **Data — datasource**                                  | `*RemoteDatasource` (Supabase) for jobs / applications | Same or additional APIs |

**Rule:** All “fetch / save” logic lives in **datasources**. Repositories only map DTOs ↔ entities and call one datasource. Use cases stay one-liners calling repositories.

---

## Phase 1 — Job applications (done)

**Goal:** List applications from Supabase `applications`; HR can shortlist or reject; status reflects DB values; resume via URL.

**Deliverables:**

- `JobApplicationRepository` + `JobApplicationRepositoryImpl` + `JobApplicationRemoteDatasource`.
- Use cases: load applications, shortlist, reject.
- `JobApplicationBloc` + wire `JobApplicationView` / `JobApplicationCard`.

### Phase 1 — implemented (files)

| Layer                 | Path                                                                                                                         |
| --------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| Entity                | `domain/job_application/entities/job_application.dart`                                                                       |
| Repository (abstract) | `domain/job_application/repositories/job_application_repository.dart`                                                        |
| Use cases             | `domain/job_application/usecases/get_job_applications.dart`, `shortlist_job_application.dart`, `reject_job_application.dart` |
| Model                 | `data/job_application/models/job_application_model.dart`                                                                     |
| Datasource            | `data/job_application/datasources/job_application_remote_datasource.dart`                                                    |
| Repository impl       | `data/job_application/repositories/job_application_repository_impl.dart`                                                     |
| Bloc                  | `presentation/bloc/job_application/job_application_bloc.dart` (+ `*_event.dart`, `*_state.dart` part files)                  |
| UI                    | `presentation/pages/job_application_view.dart`, `presentation/widget/job_application/job_application_card.dart`              |

**Optional filter:** dispatch `JobApplicationsLoadRequested(jobId: 'job-mock-1')` when navigating from a job detail (Phase 4).

---

## Phase 2 — Interview scheduling UI rules

**Goal:** Inner tabs **Eligible | Scheduled** only for **Telephone** and **Technical**; hide them for **Onboarding**, **Selected**, **Rejected**.

**Deliverables:**

- Adjust `InterviewSchedulingView` / `CandidateTabs` based on `activeRound`.
- Mock candidate data still from `InterviewSchedulingLocalDataSource` until DB exists.

### Phase 2 — implemented

- `InterviewRound.usesEligibleScheduledTabs` on `interview_enums.dart` (`telephone` + `technical` only).
- `InterviewSchedulingView`: renders `CandidateTabs` only when `state.activeRound.usesEligibleScheduledTabs`.
- `InterviewSchedulingBloc`: eligible/scheduled filter runs only for those rounds; `_onRoundChanged` calls `_applyFilters` so lists refresh when switching rounds.
- Bloc listener syncs `_candidateTabController` only when sub-tabs are visible.

---

## Phase 3 — Interview pipeline actions (mock) (done)

**Goal:** Eligible → schedule → scheduled; scheduled → select / reject; selected → onboard / reject; reject anywhere → rejected tab with **round** column.

**Deliverables:**

- Extend `InterviewSchedulingBloc` events/states; extend mock datasource to mutate lists per round/tab.
- Table column for rejected round in rejected view.

### Phase 3 — implemented

- `InterviewCandidate`: `pipelineRound`, `rejectedFromRound`; model `copyWith` in `data/interview_scheduling/models/interview_candidate_model.dart`.
- `InterviewSchedulingLocalDataSource` (singleton `instance`): `scheduleInterviews`, `selectAfterInterview`, `rejectInterviews`, `onboardFromSelected`.
- `InterviewSchedulingRepository` + `InterviewSchedulingRepositoryImpl`: same operations; `fetchCandidates` unchanged for the bloc.
- `InterviewSchedulingBloc`: `InterviewScheduleSubmitted`, `InterviewSelectSubmitted`, `InterviewRejectSubmitted`, `InterviewOnboardSubmitted`; filters by `candidate.pipelineRound == activeRound`; reload after mutations.
- `CandidatesTable`: `actionToolbar`, `showRejectedRoundColumn`; `InterviewTableHeaderRow` / `InterviewTableDataRow` optional **Rejected in round** column.
- `interview_scheduling_view.dart`: repository + bloc wiring; `_buildActionToolbar` per round/tab (Schedule, Select+Reject, Onboard+Reject, Reject-only, shrink on rejected).

---

## Phase 4 — Job posting card ↔ applications

**Goal:** Job posting card shows application count / deep-link to filtered applications by `jobId`.

**Deliverables:**

- Navigation args or route params; `JobApplicationBloc` filter by `jobId`.

---

## Phase 5 — Real database

**Goal:** Implement remote datasources; register in DI; remove or keep mocks for tests.

---

_Document version: 1 — aligned with `RECRUITMENT_INTERVIEW_FLOW.md`._
