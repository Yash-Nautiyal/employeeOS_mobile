# Recruitment – Use Cases & Implementation Guide

This document explains the recruitment feature: the **design** (role permissions, stages, flows), what is **implemented** in the app, and **where** to find or extend it.

---

## 1. Role permissions (who can do what)

Three roles drive recruitment access. The current user’s role comes from **AuthBloc** → **currentProfile.role** (from `user_info.role` in the database).

| Role         | Recruitment in drawer | Job list access | Add Posting | Add Department | Edit / Delete job |
| ------------ | --------------------- | --------------- | ----------- | -------------- | ----------------- |
| **Employee** | Hidden                | —               | No          | No             | No                |
| **HR**       | Visible               | Yes             | Yes         | No             | Own jobs only     |
| **Admin**    | Visible               | Yes             | Yes         | Yes            | Any job           |

- **Own job (HR):** A job is “own” if `job.postedByEmail == currentUser.profile.email`. When you have a real backend, prefer `posted_by_id == currentUser.id`.
- **Add Department** is reserved for Admin (★ Department configuration in the design).

---

## 2. Where role is used in the app

The **current user profile** (and thus role) is **global** and comes from **AuthBloc**:

```dart
final profile = context.watch<AuthBloc>().state.currentProfile;
// profile?.role → UserRole (employee, hr, admin)
// profile?.isEmployee, profile?.isHR, profile?.isAdmin
// profile?.canManageOwnJobs, profile?.canManageGlobalConfig, profile?.canManageAnyJob
```

### 2.1 Menu drawer (Recruitment visibility)

- **File:** `lib/view/layout/presentation/widgets/menu_drawer.dart`
- **Logic:** `showRecruitment = profile != null && !profile.isEmployee`
- **Effect:** Recruitment (Job Posting, Job Application, Interview Scheduling) is **hidden** for Employee; **shown** for HR and Admin.

### 2.2 Layout (redirect Employee away from recruitment tabs)

- **File:** `lib/view/layout/presentation/pages/layout.dart`
- **Logic:** If `profile?.isEmployee == true` and the selected tab is one of Job Posting, Job Application, or Interview Scheduling, the app switches the selection to **User** (so Employees never stay on a recruitment tab).
- **Effect:** Prevents an Employee from landing on recruitment content even if they had it selected before a role change.

### 2.3 Job Posting list (Add button & Add Department)

- **File:** `lib/view/recruitment/presentation/pages/job_posting_view.dart`
- **Logic:**
  - **Add (+) popup** is shown only if `profile?.canManageOwnJobs == true` (HR or Admin).
  - **“Add Department”** item inside the popup is shown only if `profile?.canManageGlobalConfig == true` (Admin only).
- **Effect:** Only HR/Admin see Add Posting; only Admin sees Add Department.

### 2.4 Job card (Edit / Delete in ⋯ menu)

- **Files:**
  - `lib/view/recruitment/presentation/pages/job_posting_view.dart` – computes `canEditAndDelete` per job.
  - `lib/view/recruitment/presentation/widget/job_posting/components/job_posting_card.dart` – passes `canEditAndDelete` to the card.
  - `lib/view/recruitment/presentation/widget/job_posting/components/job_posting_card_header.dart` – shows/hides Edit and Delete based on `canEditAndDelete`.
- **Logic:**
  - `canEditAndDelete = profile != null && (profile.canManageAnyJob || (profile.canManageOwnJobs && job.postedByEmail == profile.email))`
  - **Admin:** can edit/delete any job.
  - **HR:** can edit/delete only jobs where `postedByEmail` matches their email.
  - **Employee:** no edit/delete (and typically no access to the list at all).
- **Effect:** View and Copy Link stay visible; Edit and Delete are hidden when the user must not change that job.

---

## 3. Design context (from product/spec)

These are the **intended** recruitment behaviours we discussed; not all are implemented yet.

### 3.1 Role permissions matrix (summary)

- **Employee:** No recruitment management; dashboard limited.
- **HR:** Create / edit / delete **own** jobs; list, filter, import applications; shortlist/reject (pending); full recruitment (all stage tabs); schedule & update interviews; upcoming interviews on dashboard.
- **Admin:** View / edit / delete **any** job; all applications; full recruitment; plus ★ Department configuration, ★ Stage pool management, ★ Preset pipeline definition.

### 3.5 Key data flows (conceptual)

- **Job creation:** HR selects (or creates) a department → submit → insert `jobs`. Recruitment stages are constant (see `interview_enums.dart`).
- **Submission stage:** Application reaches submission stage → magic link to candidate → candidate submits → insert `stage_submissions` → HR sees and advances/rejects.
- **Interview scheduling:** Candidate in “Eligible Candidates” for interview stage → HR schedules (date, time, interviewer) → optional Google Cal → insert `interviews` → update `application.current_stage_id` → after interview HR advances/rejects.

---

## 4. What is implemented today (Phase 1)

- **Role-based visibility**
  - Recruitment menu item in drawer: hidden for Employee, visible for HR/Admin.
  - Layout: redirect Employee off recruitment tabs to User.
- **Job Posting list**
  - Add Posting: HR and Admin.
  - Per-card Edit/Delete: Admin for any job; HR for own jobs (by `postedByEmail == profile.email`).
- **Current user source**
  - Profile (and role) from **AuthBloc** (`state.currentProfile`), loaded from `user_info` + auth metadata when the user signs in or on app start.

---

## 5. How to add new role-based behaviour

1. **Get the current profile**
   - `final profile = context.watch<AuthBloc>().state.currentProfile;`
   - Or `context.read<AuthBloc>().state.currentProfile` if you don’t need rebuilds.
2. **Use role or permission flags**
   - `profile?.isEmployee`, `profile?.isHR`, `profile?.isAdmin`
   - Or `profile?.canManageOwnJobs`, `profile?.canManageGlobalConfig`, `profile?.canManageAnyJob`
3. **Guard UI or actions**
   - e.g. `if (profile != null && profile.canManageOwnJobs) { ... show button ... }`
   - Or compute a boolean (e.g. `canEditThisJob`) and pass it into child widgets (as with `canEditAndDelete` on the job card).

---

## 6. File reference (recruitment + auth/layout)

| Purpose                             | File(s)                                                         |
| ----------------------------------- | --------------------------------------------------------------- |
| Role enum & helpers                 | `lib/core/user/user_role.dart`                                  |
| Current user profile                | `lib/core/user/current_user_profile.dart`                       |
| Auth state (includes profile)       | `lib/core/auth/bloc/auth_bloc.dart`, `auth_state.dart`          |
| Drawer (Recruitment visibility)     | `lib/view/layout/presentation/widgets/menu_drawer.dart`         |
| Layout (redirect Employee)          | `lib/view/layout/presentation/pages/layout.dart`                |
| Job Posting list (Add, permissions) | `lib/view/recruitment/presentation/pages/job_posting_view.dart` |
| Job card (Edit/Delete visibility)   | `job_posting_card.dart`, `job_posting_card_header.dart`         |

This document is the single place for recruitment use cases we discussed and how they map to the codebase.
