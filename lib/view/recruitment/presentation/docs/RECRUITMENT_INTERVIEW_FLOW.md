# Recruitment & interview workflow (design reference)

This document captures the **intended end-to-end flow** for job postings → applications → shortlisting → interview scheduling → rounds → onboarding / rejection. It is meant for **review before** implementing clean-architecture wiring (repositories, use cases, blocs, UI).

**Related enums:** `lib/view/recruitment/domain/interview_scheduling/entities/interview_enums.dart`

- **Interview rounds (top-level tabs):** `telephone`, `technical`, `onboarding`, `selected`, `rejected`
- **Candidate sub-tabs (only for main interview rounds):** `eligible`, `scheduled`

---

## 1. End-to-end flow (high level)

```mermaid
flowchart LR
  subgraph posting["Job posting"]
    A[HR / Admin creates job posting] --> B[Job posted / stored]
  end

  subgraph apps["Applications"]
    C[Applications submitted for job via database] --> D[Applications visible in UI]
  end

  B --> C
  D --> E[job_posting_card: context / link to applications]
  D --> F[job_application page: list of applications]

  subgraph shortlist["Shortlisting"]
    F --> G{HR action}
    G -->|Accept / Shortlist| H[Status: Shortlisted]
    G -->|Deny| I[Rejected at application stage or terminal]
  end

  H --> J[interview_scheduling_view: pipeline starts]

  subgraph interview["Interview scheduling & rounds"]
    J --> K[Main rounds: Telephone & Technical]
    K --> L[Eligible → Schedule → Scheduled → Select / Reject]
    L --> M[Selected round tab]
    M --> N[Onboarding round tab]
    L --> O[Rejected round tab]
    M --> O
    N --> O
  end

  O --> P[Rejected tab shows round column]
```

---

## 2. Application layer (job application card)

```mermaid
flowchart TB
  subgraph card["job_application_card"]
    A[Application row] --> B[Resume / actions row]
    B --> C[Resume button]
    B --> D[Accept — e.g. checkmark]
    B --> E[Deny — e.g. close]
    A --> F[Status chip e.g. Shortlisted]
  end

  D -->|Shortlist| G[Supabase: status shortlisted, current_stage telephone]
  E -->|Deny| H[Supabase: status rejected, current_stage rejected]

  G --> I[Also: syncEligibleFromShortlistedApplication → interview local list Telephone / Eligible]
```

**Implemented persistence:** `applications.status` and `applications.current_stage` (see `application_db_values.dart` and `JobApplicationRemoteDatasource`). The interview scheduling screen still uses an **in-memory** pipeline; shortlist keeps it in sync via `InterviewSchedulingLocalDataSource.syncEligibleFromShortlistedApplication` from `JobApplicationRepositoryImpl`.

---

## 3. Interview scheduling UI hierarchy (target behavior)

**Rule:** Inner tabs **Eligible | Scheduled** apply **only** to **main rounds** (`Telephone`, `Technical`). They **do not** appear for **additional** rounds (`Onboarding`, `Selected`, `Rejected`).

```mermaid
flowchart TB
  subgraph top["Top-level round tabs InterviewRound"]
    T1[Telephone]
    T2[Technical]
    T3[Selected]
    T4[Onboarding]
    T5[Rejected]
  end

  subgraph main["Main rounds only"]
    T1 --> ST1[Sub-tabs: Eligible | Scheduled]
    T2 --> ST2[Sub-tabs: Eligible | Scheduled]
  end

  subgraph additional["Additional rounds — no Eligible/Scheduled sub-tabs"]
    T3 --> UI4[Single layout: Select + Reject — no inner tabs]
    T4 --> UI3[Single layout: flush button]
    T5 --> UI5[Table + extra column: Round rejected in]
  end
```

---

## 4. Main rounds (Telephone & Technical) — eligible vs scheduled

Same pattern for **both** main rounds.

```mermaid
stateDiagram-v2
  [*] --> Eligible: Shortlisted applications appear

  Eligible --> Scheduled: HR schedules meeting
  Scheduled --> Eligible: Optional undo / reschedule rules TBD

  Scheduled --> SelectedNext: HR selects candidate
  Scheduled --> RejectedGlobal: HR rejects candidate

  note right of Eligible
    Primary action: Schedule
  end note

  note right of Scheduled
    Replace Schedule with Select and Reject
  end note
```

**Eligible tab**

- Lists applicants who are **in this round** and **not yet scheduled** (or per your product rules).
- Primary action: **Schedule** (opens scheduling flow / meet).

**Scheduled tab**

- Lists applicants with a **scheduled** interview for this round.
- Actions: **Select** and **Reject** (not Schedule).

---

## 5. Selected round tab (no inner tabs)

```mermaid
flowchart LR
  A[Selected top-level tab] --> B[No Eligible / Scheduled sub-tabs]
  B --> C[Actions: Onboard and Reject]
  C -->|Onboard| D[Move toward Onboarding round]
  C -->|Reject| E[Rejected round with round = Selected or policy]
```

---

## 6. Onboarding round tab

```mermaid
flowchart LR
  A[Onboarding top-level tab] --> B[No Eligible / Scheduled sub-tabs]
  B --> C[Final-stage UX TBD: tasks, start date, etc.]
```

Candidates reach onboarding after being **selected** and **onboard** action (or equivalent) from the **Selected** tab.

---

## 7. Rejected round tab (aggregate + round column)

Any rejection from **any stage** that should appear in the global “rejected” view lands here.

```mermaid
flowchart TB
  R1[Reject from application shortlist stage]
  R2[Reject from Telephone eligible/scheduled]
  R3[Reject from Technical eligible/scheduled]
  R4[Reject from Selected tab]
  R5[Reject from Onboarding]

  R1 --> RJ[Rejected round tab]
  R2 --> RJ
  R3 --> RJ
  R4 --> RJ
  R5 --> RJ

  RJ --> T[Table includes column: Round in which rejected]
```

The **round** value should be explicit (e.g. `application`, `telephone`, `technical`, `selected`, `onboarding`) so HR can see **where** the candidate left the pipeline.

---

## 8. Summary matrix (for implementation planning)

| Top-level round | Inner tabs (Eligible \| Scheduled) | Primary UX                                       |
| --------------- | ---------------------------------- | ------------------------------------------------ |
| Telephone       | Yes                                | Eligible → Schedule; Scheduled → Select / Reject |
| Technical       | Yes                                | Same as Telephone                                |
| Selected        | No                                 | Onboard / Reject                                 |
| Onboarding      | No                                 | Onboarding workflow                              |
| Rejected        | No                                 | Table + **Round** column                         |

---

## 9. Implementation status (vs this doc)

| Item                                                                    | Status                                                                                                            |
| ----------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- |
| Job applications → Supabase `applications`                              | Done                                                                                                              |
| Shortlist / reject + `current_stage`                                    | Done                                                                                                              |
| Eligible \| Scheduled only for telephone & technical                    | Done — `InterviewRound.usesEligibleScheduledTabs` in `interview_enums.dart`; view listens to bloc round/tab state |
| Interview pipeline mutations (schedule, select, reject, onboard, flush) | Done **in memory** — `InterviewSchedulingLocalDataSource`                                                         |
| Google Calendar template flow before “mark scheduled”                   | Done — `interview_scheduling_view.dart` + dialogs + `open_google_calendar.dart`                                   |
| Persist interviews to `interviews` table; drop mock merge               | **Not done** — see `RECRUITMENT_ARCHITECTURE.md` “Planned / follow-up”                                            |
| `rejected_in_round` as a dedicated DB column                            | Not done; local model uses `rejectedFromRound` on `InterviewCandidate`                                            |

Remaining product/engineering work is mainly **backing the interview UI with `interviews` + server truth** and removing reliance on **`JobApplicationMockDatasource`** inside `InterviewSchedulingRepositoryImpl`’s first-load merge.

---

## Document history

- **v1** — Flowcharts from product discussion; UI rules for sub-tabs and rejected round column.
- **v2** — Synced with code: Supabase applications, shortlist → local interview sync, eligible/scheduled rule implemented, Calendar scheduling path, explicit gaps (`interviews` table, mock merge).
