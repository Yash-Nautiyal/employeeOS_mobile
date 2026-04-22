## Auth Architecture – Gap Analysis & Upgrade Plan

This guide lists **concrete changes** to make your Supabase + Flutter + BLoC/Cubit authentication stack “industrial‑grade”, grouped by the four phases we discussed.

Use it as a **checklist** when refactoring.

---

## Phase 1 – Architectural Layers & Decoupling

**Goal:** UI → BLoC/Cubit → Repository → SupabaseClient (no shortcuts, no raw exceptions in UI).

### Current Status

- `SignInCubit` already talks only to `AuthRepository`, which then uses `SupabaseClient`.
- `AuthBloc` still talks directly to `SupabaseClient` and performs its own error handling.

### Required Changes

- **P1‑A: Introduce full repository usage in `AuthBloc`**
  - Create methods in `AuthRepository` for:
    - `Future<void> signUp(...)`
    - `Future<void> resetPassword(...)`
    - `Future<void> signOut(...)`
  - Move all Supabase calls out of `AuthBloc` into `AuthRepository`:
    - Replace direct `_client.auth.signInWithPassword`, `.signUp`, `.signOut`, `.resetPasswordForEmail` calls with repository calls.
  - Inject `AuthRepository` into `AuthBloc` (similar pattern to `SignInCubit`).

- **P1‑B: Normalize error mapping**
  - Ensure **all** auth exceptions from Supabase are mapped to a domain type (e.g. `AuthFailure`) in `AuthRepository`.
  - In BLoCs/Cubits, catch only `AuthFailure` (or similar) and surface **clean, user‑friendly** messages.
  - Remove (or centralize) any remaining places where `AuthException` or `Exception.toString()` are directly shown to the user.

---

## Phase 2 – Authentication Lifecycle Flows

**Goal:** Robust handling for **startup**, **active auth**, and **background token refresh**.

### 2.1 App Startup (`Supabase.initialize`)

**Status:** Timeout behaviour is not explicit yet.

**Changes**

- **P2‑A: Add startup timeout wrapper**
  - Wrap `Supabase.initialize` (and any other heavy startup tasks) with `Future.timeout`, e.g. 10–15s.
  - On timeout:
    - Log a non‑fatal telemetry event.
    - Continue to boot the app in a **degraded / offline‑mode friendly** state (e.g. still build `MyApp`, but show an error banner or offline view).
  - Document the behaviour in a short comment near `main.dart` initialization so future maintainers understand the trade‑off.

### 2.2 Active Auth (Sign In / Sign Up)

**Status:** Sign‑in path is strong; sign‑up/reset require alignment.

**Sign‑In – Already Good (keep as reference)**

- **UI protections**
  - `AuthView` uses `PopScope` to block back navigation while `SignInCubit.state.isLoading == true`.
  - App bar back button is disabled during sign‑in and shows a toast instead.
  - The “Sign in” button:
    - Is visually disabled while loading.
    - Has an `onClick` guard that is a no‑op when loading.
  - `SignInCubit` also checks `state.isLoading` and `isClosed` to drop duplicate events.

- **Repository timeout**
  - `AuthRepository.signIn` wraps `signInWithPassword` in `.timeout(...)` (15s) and maps `TimeoutException` to a friendly `AuthFailure` message.

**Required Changes**

- **P2‑B: Align Sign‑Up & Reset Password flows with Sign‑In**
  - Route **sign‑up** and **reset password** through `AuthRepository`:
    - Implement `signUp` and `resetPassword` methods with:
      - Explicit timeouts.
      - `AuthFailure` mapping (including validation and Supabase messages).
  - Ensure any sign‑up/reset UI:
    - Uses a Cubit/BLoC similar to `SignInCubit` for state management.
    - Disables buttons and uses `PopScope` or equivalent during in‑flight requests.

- **P2‑C: Ensure navigation is always driven by auth state**
  - Prefer using `AuthBloc`’s `Authenticated` / `Unauthenticated` states as the **single source of truth** for post‑auth navigation (e.g. to `Layout`), and avoid duplicating navigation decisions in multiple places.

### 2.3 Background Maintenance (Token Refresh)

**Status:** Well‑implemented; just keep it consistent.

**Already in place**

- Global handlers:
  - `PlatformDispatcher.instance.onError` and `runZonedGuarded` call `AuthErrorHandler.handleUnhandledError`.
- `AuthErrorHandler`:
  - Classifies Supabase refresh errors as:
    - **Retryable network** (timeouts, `SocketException`, `AuthRetryableFetch*`).
    - **Explicit auth failure** (401/403/400 invalid/refresh/revoked).
  - Returns `true` only for retryable errors (so the app doesn’t crash/hang).
- `AuthBloc`:
  - Uses `wasRetryableAuthErrorRecently()` to avoid logging out when the SDK clears the session after a network refresh failure.

**Optional Upgrade**

- **P2‑D: Add explicit logout callback for hard auth failures**
  - Expose an optional callback on `AuthErrorHandler` for explicit auth failures (e.g. 401/400 invalid refresh token).
  - Wire it so the global error handler can dispatch an `AuthSignOutRequested` (or equivalent) to `AuthBloc` immediately, instead of relying solely on `onAuthStateChange`.

---

## Phase 3 – Error Handling Matrix

**Goal:** Clean separation of **network issues vs. auth rejection**, plus consistent timeouts for user‑initiated actions.

### 3.1 Network vs Auth Rejection

**Status:** Already strong; just document and keep tests around it.

**Keep & Document**

- Keep the current logic in `AuthErrorHandler`:
  - Treat `SocketException`, timeouts, and `AuthRetryableFetch*` as **retryable** (no logout, no crash).
  - Treat 401/403 and 400 invalid/refresh/revoked as **explicit auth failures** that should lead to logout.
- Keep `AuthBloc`’s integration:
  - Use `wasRetryableAuthErrorRecently()` to suppress logout on transient refresh failures.
  - Clear the retryable flag when a valid session returns or on intentional sign‑out.

**Optional Enhancement**

- Add a short section in your docs (or tests) enumerating:
  - Example error messages that must be treated as retryable.
  - Example messages that must be treated as hard auth failures.

### 3.2 Repository Timeouts

**Status:** Only sign‑in is fully covered.

**Required Changes**

- **P3‑A: Apply timeouts to all user‑initiated auth calls**
  - In `AuthRepository`, mirror the sign‑in behaviour for:
    - `signUp`
    - `resetPassword`
    - Any other auth endpoints you add later (e.g. `magicLink`, `updatePassword`).
  - Always:
    - Wrap the Supabase call in `.timeout(...)`.
    - Map `TimeoutException` to a clear, user‑facing `AuthFailure` message.

- **P3‑B: Ensure UI always clears loading state on failure**
  - For any new Cubit/BLoC around sign‑up/reset/password flows, follow the `SignInCubit` pattern:
    - `loading → success/failure` transitions.
    - No code paths where `loading` can remain `true` indefinitely.

---

## Phase 4 – Security & Scaling Readiness

**Goal:** Production‑grade security (storage) and observability (telemetry).

### 4.1 Secure Storage

**Status:** Uses Supabase default storage; explicit secure config not yet present.

**Required Changes**

- **P4‑A: Configure Supabase for secure session storage**
  - Review the current Supabase Flutter API and:
    - Provide a `localStorage` implementation backed by secure storage (e.g. `flutter_secure_storage`) where supported.
    - Or enable any built‑in option that uses the OS keychain/keystore for session tokens.
  - Document in `main.dart` (and this guide) which storage strategy is used on:
    - Android
    - iOS
    - Web / Desktop (if applicable)

### 4.2 Telemetry & Observability

**Status:** Hooks and TODOs exist, but no concrete integration.

**Required Changes**

- **P4‑B: Add a telemetry adapter (Crashlytics/Sentry/etc.)**
  - Create a small abstraction, e.g. `ErrorReporter` service, with methods:
    - `recordNonFatal(error, stack, {tags})`
    - `recordFatal(error, stack, {tags})`
  - Implement it using your telemetry provider of choice (Crashlytics, Sentry, etc.).

- **P4‑C: Wire telemetry into existing hooks**
  - In `AuthErrorHandler.handleUnhandledError`:
    - For **retryable** errors: call `recordNonFatal` with a tag like `{"category": "auth_retryable"}`.
    - For **explicit auth failures**: call `recordNonFatal` with a tag like `{"category": "auth_failure"}`.
  - In `main.dart` global handlers:
    - When `handleUnhandledError` returns `false`, forward the error to `recordFatal` (or crash‑level reporting) in addition to `FlutterError.presentError`.

- **P4‑D: Track key auth lifecycle metrics**
  - Optionally, log custom events/metrics, e.g.:
    - Number of sign‑in attempts, successes, failures.
    - Count of retryable refresh errors (network blips) per day.
    - Count of explicit auth revocations (password changes, bans).

---

## How to Use This Guide

- Treat each bullet (**P1‑A**, **P2‑A**, etc.) as an actionable backlog item.
- Start with:
  1. **Phase 1 (repository unification)** – this simplifies all later work.
  2. **Phase 3 (timeouts everywhere)** – directly improves UX under bad networks.
  3. **Phase 4 (secure storage + telemetry)** – required for production readiness.
- Keep `AUTH_ERROR_HANDLING_EDGECASES.md` alongside this file as the **behavioural spec**, and use this document as the **implementation checklist**.
