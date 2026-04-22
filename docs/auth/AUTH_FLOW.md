# Auth flow – step by step

This doc explains **exactly** what happens when a user signs in, signs out, or opens the app already signed in. It also clarifies how **SignInCubit**, **AuthBloc**, and **UserInfoService** work together.

---

## The three pieces (and their job)

| Piece               | Job                                                                                                                                                                                                                               | Who listens?                                                                               |
| ------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------ |
| **AuthBloc**        | **Single source of truth** for "is the user logged in?". Listens to **Supabase’s** auth stream. Decides whether the app shows **HomeView** (login) or **Layout** (main app). Holds **current user + profile** when authenticated. | **main.dart** (`BlocBuilder<AuthBloc>`) – drives the **root** screen (HomeView vs Layout). |
| **SignInCubit**     | **Form-only** state for the sign-in screen: loading, success, failure + error message. Calls `AuthRepository.signIn()`. **Does not** drive navigation.                                                                            | **AuthPage** – disables button, shows toasts (error/success).                              |
| **UserInfoService** | Fetches user row from `user_info` (and we merge auth metadata). Used by **AuthBloc** to build **CurrentUserProfile** (role, name, etc.) after sign-in or app start.                                                               | Only **AuthBloc** (via `_loadProfile()`).                                                  |

**Important:** The app does **not** “know” the user signed in because SignInCubit emitted success. It knows because **Supabase** updated the session and **AuthBloc** reacted to that. SignInCubit’s success is only used to show a toast on the sign-in screen.

---

## Use case 1: User opens app (already signed in)

1. **main.dart** runs → `AuthBloc` is created.
2. In **AuthBloc** constructor:
   - It subscribes to `_client.auth.onAuthStateChange` (Supabase stream).
   - It dispatches `AuthCheckRequested()`.
3. **AuthBloc** handles `AuthCheckRequested`:
   - Reads `_client.auth.currentSession`.
   - Session **exists** → calls `_loadProfile(session.user.id)`:
     - **UserInfoService** → `fetchUserById(userId)` → row from `user_info`.
     - Merge auth metadata (userMetadata, appMetadata).
     - Build **CurrentUserProfile** (role, name, email, etc.).
   - Emits **`Authenticated(session.user, profile)`**.
4. **main.dart** `BlocBuilder<AuthBloc, AuthState>`:
   - Sees `Authenticated` → returns **`Layout()`**.
5. User sees the main app (drawer, tabs, etc.) and **profile** (e.g. role) is in `authState.profile`.

---

## Use case 2: User signs in (from login screen)

1. User is on **HomeView** (login landing). Taps "Sign In" → **AuthView** is pushed (sign-in form).
2. **AuthView** creates **SignInCubit** (and **AuthPage** uses it).
3. User enters email/password and taps **"Sign in"**.
4. **AuthPage** calls `context.read<SignInCubit>().signIn(email, password)`.
5. **SignInCubit**:
   - Emits **loading** (button shows "Sign in...").
   - Calls **`AuthRepository.signIn(email, password)`**.
6. **AuthRepository**:
   - Calls **Supabase** `signInWithPassword()`.
   - Supabase sets the **session** (and stores tokens, etc.).
7. **SignInCubit** (after `signIn` returns):
   - Emits **success**.
8. **AuthPage** `BlocListener<SignInCubit>`:
   - On **success** → only shows **"Sign-in successful"** toast. **No navigation.**

**How does the app actually switch to the main screen?**

9. **Supabase** emits on **`onAuthStateChange`** (session is now non-null).
10. **AuthBloc**’s subscription runs → it dispatches **`AuthLoggedIn()`**.
11. **AuthBloc** handles **`AuthLoggedIn`**:
    - Reads `currentSession` (still non-null).
    - Calls **`_loadProfile(session.user.id)`** (same as above: UserInfoService + metadata → **CurrentUserProfile**).
    - Emits **`Authenticated(session.user, profile)`**.
12. **main.dart** `BlocBuilder<AuthBloc, AuthState>`:
    - Rebuilds; state is now **`Authenticated`**.
    - Returns **`Layout()`** instead of **`HomeView()`**.
13. The **root** of the app changes from HomeView to Layout. User sees the main app. The sign-in screen is gone because the whole tree under `home:` was replaced.

So: **Supabase session change → AuthBloc → root builder → Layout.** SignInCubit’s success is only for the toast; the **navigation** is 100% driven by AuthBloc (and thus by Supabase’s auth state).

---

## Use case 3: User signs out

1. User is in **Layout**. Taps sign out (e.g. in **profile** / menu).
2. That code calls:  
   `context.read<AuthBloc>().add(AuthSignOutRequested())`.
3. **AuthBloc** handles **`AuthSignOutRequested`**:
   - Calls **`AuthRepository.signOut()`**.
4. **AuthRepository**:
   - Calls **Supabase** `signOut()` → session cleared.
5. **AuthBloc** (same handler):
   - Emits **`Unauthenticated()`**.
6. **main.dart** `BlocBuilder<AuthBloc, AuthState>`:
   - Rebuilds; state is **`Unauthenticated`**.
   - Returns **`HomeView()`**.
7. User sees the login/landing screen again.

(Optionally, Supabase’s `onAuthStateChange` also fires with no session; AuthBloc would then get **AuthLoggedOut** and emit **Unauthenticated** again — redundant but harmless.)

---

## Flow diagram (sign-in)

```
User taps "Sign in"
       ↓
SignInCubit.signIn()  ──→  AuthRepository.signIn()  ──→  Supabase sets session
       ↓
SignInCubit emits success  ──→  AuthPage shows toast only (no navigation)
       ↓
Supabase onAuthStateChange fires (session != null)
       ↓
AuthBloc receives it  ──→  add(AuthLoggedIn())
       ↓
AuthBloc: _loadProfile(userId)  ──→  UserInfoService.fetchUserById  ──→  CurrentUserProfile
       ↓
AuthBloc emits Authenticated(user, profile)
       ↓
main.dart BlocBuilder<AuthBloc>  ──→  home: becomes Layout()
       ↓
User sees main app; profile/role available as authState.profile
```

---

## Is this a professional way to do auth (e.g. for a large user base)?

**Short answer: yes, with one optional simplification.**

- **Single source of truth:** Using **one** place (AuthBloc) that listens to the **auth provider** (Supabase) and drives **all** “logged in vs not” UI (including root screen) is the right pattern. No duplicate navigation, no “who’s in charge?” confusion.
- **Repository:** AuthRepository wraps Supabase and maps errors (e.g. to `AuthFailure`). That’s good for testability and consistent error handling.
- **Profile/role:** Loading profile (UserInfoService + metadata) when the session appears and keeping it in **AuthBloc** state is a solid approach. The rest of the app just reads `authState.profile` (or `state.currentProfile`).

**Where it can feel confusing:**

- You have **two** state holders for “sign-in”: **SignInCubit** (form) and **AuthBloc** (app-level). Sign-in could be done **only** with AuthBloc (e.g. a single “Sign in” event; form could listen to AuthBloc for loading/success/error). The current split is valid (form cubit for form UX, bloc for global auth), but if you want **one** mental model, you could:
  - Remove SignInCubit and have the form call  
    `context.read<AuthBloc>().add(AuthSignInRequested(email, password))`,
  - and use **AuthBloc** state (e.g. `AuthLoading`, `AuthError`, then `Authenticated`) for button state and toasts. Then “user signed in” and “app shows Layout” are obviously the same thing (AuthBloc → Authenticated).

So: the way the app **knows** the user signed in (Supabase → AuthBloc → root builder) is professional and correct. The only “extra” piece is SignInCubit, which is optional and mainly for form-level UX.
