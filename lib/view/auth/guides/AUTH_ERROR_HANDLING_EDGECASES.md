# Auth Error Handling – Edge Cases & How They Are Resolved

This document explains **what problem we solved**, **which edge cases exist**, and **how each one is (or should be) handled** in the app.

---

## 1. What Problem We Solved

### Background

- **Supabase refreshes the access token in the background** (e.g. when it’s about to expire or when the app is used). This runs **even on screens that don’t call the database** (e.g. Job Posting).
- If that refresh request **fails because of the network** (timeout, tunnel, Wi‑Fi blip, etc.), the SDK can throw an error like:
  - `AuthRetryableFetchException(message: ClientException with SocketException: Connection timed out...)`
- Before the fix:
  - This error was **unhandled** → showed in logs and could **hang the app**.
  - In some cases the SDK might clear the session when refresh fails → the app would treat the user as **logged out** and send them to the login screen even though they just had bad internet.

### Rule We Follow

| Type of failure         | Meaning                                                               | What we do                                                                                |
| ----------------------- | --------------------------------------------------------------------- | ----------------------------------------------------------------------------------------- |
| **Network / retryable** | Device can’t reach the server (timeout, no internet).                 | **Do not sign out.** Keep session. Log only. Let Supabase retry when the network is back. |
| **Auth failure**        | Server was reached but rejected the token (401, revoked token, etc.). | **This is when we sign out** and send the user to login.                                  |

The code changes implement this rule and handle the edge cases below.

---

## 2. Edge Cases and How They Are Resolved

### Edge case 1: Token refresh times out (e.g. in a tunnel or bad Wi‑Fi)

**Scenario:** User is on Job Posting (or any screen). Supabase tries to refresh the token in the background. The request times out (e.g. `SocketException: Connection timed out`).

**Without fix:**

- An **unhandled exception** is thrown → appears in logs as `Unhandled Exception: AuthRetryableFetchException(...)`.
- The app can **hang** or behave oddly because the error is never caught.
- In some SDK versions, the session might be cleared and the user is sent to login even though they didn’t do anything wrong.

**How we resolve it:**

1. **Global error handler** (`main.dart`):
   - `PlatformDispatcher.instance.onError` and `runZonedGuarded` catch the error.
   - They call `AuthErrorHandler.handleUnhandledError(error, stack)`.
   - For this error we classify it as **retryable** (network), so we:
     - Set the “retryable error just happened” flag (used for edge case 2).
     - Return `true` (error handled) so it is **not propagated** → no hang, no unhandled exception.
   - **Where:** `lib/main.dart` (onError callback and runZonedGuarded).

2. **Classification** (`auth_error_handler.dart`):
   - We treat as **retryable** (do not sign out):
     - `AuthException` with `statusCode == null` (no HTTP response = network issue).
     - Message or type containing: `AuthRetryableFetchError`, `AuthRetryableFetchException`, `Connection timed out`, `SocketException`, `ClientException` (when combined with socket).
   - **Where:** `lib/core/auth/auth_error_handler.dart` → `isRetryableAuthError()`.

**Result:** User stays on the same screen. Error is logged (and can later be sent to telemetry as non-fatal). When the network is back, Supabase can retry the refresh.

---

### Edge case 2: SDK clears session right after a refresh timeout

**Scenario:** Same as edge case 1, but the Supabase SDK **also clears the session** when the refresh fails. So `onAuthStateChange` fires with `session == null`.

**Without fix:**

- Auth bloc would receive “session is null” and emit `AuthLoggedOut` → user is sent to the login screen even though the only problem was network.

**How we resolve it:**

- In **AuthBloc**, when we get `session == null` from `onAuthStateChange`, we **do not** immediately add `AuthLoggedOut`.
- We only add `AuthLoggedOut` if **we did not** just see a retryable auth/network error:
  - We call `AuthErrorHandler.wasRetryableAuthErrorRecently()` (true for 5 seconds after such an error).
  - If it’s true, we **do not** add `AuthLoggedOut` → user stays on the app.
- **Where:** `lib/view/auth/presentation/bloc/auth_bloc.dart` → `onAuthStateChange` listener.

**Result:** Short network blips don’t log the user out. When the SDK eventually refreshes successfully (or the user goes back to login later for a real reason), behaviour is correct.

---

### Edge case 3: User really is logged out (401, revoked token, etc.)

**Scenario:** The server was reached but rejected the token (e.g. 401 Unauthorized, or 400 “Invalid Refresh Token” / “Refresh Token Not Found” after password change or admin action).

**Without fix:**

- If we treated everything as “retryable”, we would never sign the user out and they could stay on a broken session.

**How we resolve it:**

- We **do not** treat these as retryable:
  - `AuthException` with `statusCode == 401` or `403` → always **auth failure**.
  - `statusCode == 400` with message containing refresh/token/invalid/revoked → **auth failure**.
- So:
  - `AuthErrorHandler.handleUnhandledError()` returns `false` for these → error can still be reported (e.g. Crashlytics).
  - When the SDK clears the session, `onAuthStateChange` gets `session == null`. This time we did **not** just set the retryable flag, so `wasRetryableAuthErrorRecently()` is false → we **do** add `AuthLoggedOut` → user is correctly sent to login.
- **Where:** `lib/core/auth/auth_error_handler.dart` → `isRetryableAuthError()` (explicitly returns false for 401/403/400 token errors), and `auth_bloc.dart` (emits logout when session is null and it wasn’t a recent retryable error).

**Result:** Real auth failures still lead to sign-out and login screen; only network/retryable errors are “ignored” for logout.

---

### Edge case 4: User opens app with no internet, then gets online later

**Scenario:** User opens the app while offline. Token refresh fails (retryable error). Later they get online; Supabase may retry and restore the session.

**How we resolve it:**

- The retryable error is caught by the global handler (edge case 1) → no crash, no hang.
- If the SDK had cleared the session, we don’t emit logout (edge case 2).
- When the network is back, Supabase’s own logic can retry; when it succeeds, `onAuthStateChange` will fire with a non-null session → we clear the retryable flag and add `AuthLoggedIn` (we already do this when `session != null`).
- **Where:** `auth_bloc.dart` → on `session != null` we call `AuthErrorHandler.clearRetryableErrorFlag()`.

**Result:** App doesn’t crash; user can stay in the app and session can recover when online.

---

### Edge case 5: User intentionally signs out

**Scenario:** User taps “Sign out”. We call `signOut()` and the auth stream will eventually emit `session == null`.

**Without fix:**

- If we had recently had a retryable error, `wasRetryableAuthErrorRecently()` could still be true. We might then **not** add `AuthLoggedOut` and the user would stay “logged in” in the UI after signing out.

**How we resolve it:**

- On **intentional sign-out** we call `AuthErrorHandler.clearRetryableErrorFlag()` before calling `_client.auth.signOut()`. So when `onAuthStateChange` later fires with `session == null`, `wasRetryableAuthErrorRecently()` is false and we correctly add `AuthLoggedOut`.
- **Where:** `lib/view/auth/presentation/bloc/auth_bloc.dart` → `_onSignOutRequested`.

**Result:** Sign-out always leads to logout state and login screen.

---

### Edge case 6: Errors that are not auth-related

**Scenario:** Some other part of the app throws an unhandled error (e.g. a bug in business logic).

**How we resolve it:**

- `AuthErrorHandler.isRetryableAuthError()` and `isExplicitAuthFailure()` only return true for auth/network patterns. Other errors return false.
- So `handleUnhandledError()` returns `false` → in `main.dart` we don’t “handle” it and we call `FlutterError.presentError(...)` so the error is still reported and the app can crash or show error UI as normal.
- **Where:** `lib/core/auth/auth_error_handler.dart` (classification), `lib/main.dart` (onError / runZonedGuarded only treat as handled when `handleUnhandledError` returns true).

**Result:** Only auth-related retryable errors are swallowed; other errors are still reported.

---

### Edge case 7: Error happens in a zone that doesn’t hit runZonedGuarded

**Scenario:** The token refresh runs in a future/timer that might not be inside our `runZonedGuarded` zone, but the error still reaches the root isolate.

**How we resolve it:**

- We use **both**:
  - **`PlatformDispatcher.instance.onError`** – catches unhandled errors in the root isolate (including from async code that might not be in our zone).
  - **`runZonedGuarded`** – catches errors that occur inside the zone we created (e.g. during app startup and `runApp`).
- So we cover both “zone” and “platform” unhandled errors.
- **Where:** `lib/main.dart` – both handlers call the same `AuthErrorHandler.handleUnhandledError()`.

**Result:** Retryable auth errors are caught whether they escape from our zone or not (as long as they reach the root isolate).

---

## 3. Summary Table

| Edge case                                   | Risk if not handled                           | Where it’s handled                                                                                                              |
| ------------------------------------------- | --------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| 1. Token refresh timeout (network)          | Unhandled exception, app hang                 | `main.dart` (onError + runZonedGuarded), `auth_error_handler.dart` (classify as retryable, handle)                              |
| 2. SDK clears session after refresh timeout | User wrongly sent to login                    | `auth_bloc.dart` (don’t emit logout if `wasRetryableAuthErrorRecently()`)                                                       |
| 3. Real auth failure (401, revoked token)   | Must still sign out                           | `auth_error_handler.dart` (don’t treat as retryable), `auth_bloc.dart` (emit logout when session null and not recent retryable) |
| 4. App used offline then online             | Crash or wrong logout; session should recover | Same as 1 + 2; `auth_bloc.dart` clears flag when session is back                                                                |
| 5. Intentional sign-out                     | User could stay “logged in” in UI             | `auth_bloc.dart` clears retryable flag in `_onSignOutRequested`                                                                 |
| 6. Non-auth errors                          | Should not be swallowed                       | `auth_error_handler.dart` only treats auth/network patterns as retryable; others propagate                                      |
| 7. Error outside our zone                   | Might not be caught by runZonedGuarded        | `main.dart` uses both PlatformDispatcher.onError and runZonedGuarded                                                            |

---

## 4. Optional / Future Improvements

- **Telemetry:** In `AuthErrorHandler.handleUnhandledError()`, for retryable errors you can send a **non-fatal** event to Crashlytics (or similar) so you see how often “tunnel”/network refresh failures happen without treating them as crashes.
- **Explicit auth failure in global handler:** If you want to force sign-out as soon as we see a 401/400 invalid token in the global handler (e.g. before the auth stream emits), you could register a callback (e.g. “onExplicitAuthFailure”) that the global handler calls and that triggers `AuthBloc.add(AuthSignOutRequested())` or clears session. Right now we rely on the SDK clearing the session and the auth stream to emit logout.
- **Tuning the 5-second window:** `_retryableErrorTtl` in `auth_error_handler.dart` is 5 seconds. If you see wrong logouts after slow networks, you can increase it slightly; if you see delayed logout after a real auth failure, you can decrease it (or clear the flag when you get an explicit auth failure in the global handler).

---

## 5. File Reference

| File                                             | Role                                                                                                                                                               |
| ------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `lib/core/auth/auth_error_handler.dart`          | Classifies errors (retryable vs auth failure), handles unhandled errors, exposes `wasRetryableAuthErrorRecently()` and `clearRetryableErrorFlag()`.                |
| `lib/main.dart`                                  | Sets `PlatformDispatcher.instance.onError` and `runZonedGuarded`, both calling `AuthErrorHandler.handleUnhandledError()`.                                          |
| `lib/view/auth/presentation/bloc/auth_bloc.dart` | Uses retryable flag: don’t emit logout when session is null if `wasRetryableAuthErrorRecently()`; clears flag when session is present and on intentional sign-out. |

---

## 6. Logic Flowchart

```mermaid
flowchart TD
    Start([App Running]) -->|1. Unhandled Error| GlobalError[Global Error Handler]
    Start -->|2. Auth State Change| AuthStateListener[AuthBloc Listener]

    %% Path 1: Global Error Handling
    GlobalError --> CheckError{AuthErrorHandler.\nisRetryableAuthError?}
    CheckError -- Yes (Network/Timeout) --> SetFlag[Set Flag: wasRetryableAuthErrorRecently = true]
    SetFlag --> SwallowError[Return true (Handled)\nDon't Crash]
    CheckError -- No (Other Error) --> CheckExplicit{AuthErrorHandler.\nisExplicitAuthFailure?}
    CheckExplicit -- Yes (401/400) --> LogExplicit[Log Explicit Failure]
    LogExplicit --> Propagate[Return false (Not Handled)\nLet App Report/Crash]
    CheckExplicit -- No (Business Logic Error) --> Propagate

    %% Path 2: Auth State Change
    AuthStateListener --> SessionCheck{Session == null?}

    SessionCheck -- No (Has Session) --> ClearFlag[Clear Flag:\nwasRetryableAuthErrorRecently = false]
    ClearFlag --> EmitLoggedIn[Emit: AuthLoggedIn]

    SessionCheck -- Yes (No Session) --> CheckFlag{AuthErrorHandler.\nwasRetryableAuthErrorRecently?}
    CheckFlag -- Yes (Recently Failed) --> IgnoreLogout[Do Nothing\n(Keep User Logged In)]
    CheckFlag -- No (Real Logout) --> EmitLoggedOut[Emit: AuthLoggedOut\n(Go to Login Screen)]

    %% Connections
    SwallowError -.->|Supabase clears session| AuthStateListener
```
