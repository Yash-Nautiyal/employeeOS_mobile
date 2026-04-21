# Navigation Policy

This project uses `go_router` typed routes for page-level navigation.

## Rules

- Use generated typed routes from `lib/core/routing/app_routes.dart`.
- Prefer `.go(context)` for section switches and auth redirects.
- Prefer `.push(context)` for drill-down detail pages that should support back navigation.
- Do not introduce new `Navigator.push*` calls for page-to-page navigation.
- `Navigator` is still allowed for:
  - dialogs
  - bottom sheets
  - fullscreen media viewers
  - local ephemeral overlays

## Examples

- Good: `const AppUserRoute().go(context);`
- Good: `AppRecruitmentJobPostingDetailRoute(jobId: id).push(context);`
- Allowed local UI modal: `showDialog(...)`, `showModalBottomSheet(...)`
- Avoid for page routing: `Navigator.push(...)`, `Navigator.pushNamed(...)`

## Maintenance

- When adding a new page, first add a typed route class to `app_routes.dart`.
- Run `dart run build_runner build --delete-conflicting-outputs`.
- Use generated route helpers in widgets/cubits instead of raw string paths.
