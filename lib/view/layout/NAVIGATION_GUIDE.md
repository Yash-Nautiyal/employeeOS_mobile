# Nested Navigator Guide

This doc explains how the **nested Navigator** is implemented for the Job Posting section so you can reuse the same pattern in other sections (e.g. Job Application, Interview Scheduling).

---

## 1. Why a nested Navigator?

- **Root Navigator** (from `MaterialApp`) is used for full-screen routes (e.g. Login, Add Job Posting dialog).
- **Layout** owns the shell: one `Scaffold` with one app bar and a body that shows one of several section widgets from `_pages`.
- If we used the **root** Navigator to push the "View Job" page, the new route would replace the **entire** screen (including the Layout and app bar).
- So we put a **second Navigator** _inside_ the Layout body, only for the Job Posting section. That Navigator has its own stack (list → detail). Pushing and popping happen **inside** that stack, so the Layout (and app bar) never go away.

---

## 2. Widget tree (conceptual)

```
MaterialApp
└── Navigator (root)  ← full-screen routes (e.g. AddJobPostingPage)
    └── Layout
        ├── Scaffold (appBar: HomeNav, drawer: MenuDrawer)
        └── body: _pages[_selectedItem]
                │
                │  When _selectedItem == 'Job Posting':
                │
                └── JobPostingSection
                    └── Navigator (nested)  ← section-specific stack
                        ├── Route 1: JobPostingView (list)     ← initial
                        └── Route 2: JobViewPage (detail)      ← after push
```

- **Layout** never changes; it always shows one widget from `_pages`.
- For "Job Posting", that widget is **JobPostingSection**, which is **only** a `Navigator`.
- The **nested** Navigator’s **first route** is the list (JobPostingView). When you push, the **second route** (JobViewPage) is added to _this_ Navigator’s stack, so only the content inside the Layout body changes.

---

## 3. How Flutter chooses which Navigator to use

When you call:

```dart
Navigator.of(context).pushNamed(...);
// or
Navigator.of(context).pop();
```

Flutter looks up the **widget tree** from `context` and uses the **nearest** `Navigator` ancestor.

- If `context` is from a widget **inside** `JobPostingSection` (e.g. inside `JobPostingView` or a card), the **nearest** Navigator is the **nested** one → push/pop only affect the Job Posting stack; Layout stays.
- If `context` is from a widget **above** that (e.g. Layout, or a dialog opened from the app bar), the nearest Navigator is the **root** one → full-screen routes.

So the only “trick” is: **any navigation to the detail page must be called with a context that is a descendant of the section’s Navigator** (e.g. from inside JobPostingView or its children).

---

## 4. Implementation in three parts

### Part A: Section wrapper (the nested Navigator)

**File:** `lib/view/recruitment/presentation/pages/job_posting_section.dart`

- A **StatelessWidget** whose `build` returns a **single** `Navigator`.
- **`initialRoute`**: the first route (e.g. `'/'`) → list page.
- **`onGenerateRoute`**: given `settings.name` (and `settings.arguments`), return the right `Route` (e.g. `MaterialPageRoute` or `PageRouteBuilder` for custom transition).
- **Route name constants** (e.g. `routeList`, `routeJobView`) are on the section class so the list page can push by name without hard-coding strings.

So the section widget is literally: “a Navigator that shows list by default and can show detail when you push.”

### Part B: Layout uses the section, not the list

**File:** `lib/view/layout/presentation/pages/layout.dart`

- In `_pages`, the entry for that section uses the **section wrapper**, not the list page:
  - Before: `'Job Posting': const JobPostingView()`
  - After: `'Job Posting': const JobPostingSection()`

So when the user selects "Job Posting", the **body** of the Layout is the **Navigator** (JobPostingSection), and the **first route** of that Navigator is JobPostingView.

### Part C: List page pushes using the same context

**File:** `lib/view/recruitment/presentation/pages/job_posting_view.dart`

- The list page (and its children, e.g. card, header) get a `BuildContext` that is **under** the nested Navigator.
- So when the “View” action runs, it does:
  - `Navigator.of(context).pushNamed(JobPostingSection.routeJobView, arguments: {'id': index});`
- That `context` is inside JobPostingSection → `Navigator.of(context)` is the **nested** Navigator → push happens inside the section; Layout and app bar stay.

Detail page (JobViewPage) uses **the same** context, so `Navigator.of(context).pop()` pops from the nested Navigator and returns to the list.

---

## 5. Checklist: add a nested Navigator to another section

Use this for e.g. "Job Application" or "Interview Scheduling".

| Step | What to do                                                                                                                                                                                   |
| ---- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1    | Create a **section widget** (e.g. `JobApplicationSection`) in the same feature folder (e.g. `presentation/pages/`).                                                                          |
| 2    | In that widget’s `build`, return a **Navigator** with: `initialRoute: '/'` (or your list route name), and `onGenerateRoute` that maps route names to your list/detail (and any other) pages. |
| 3    | Define **route name constants** on the section class (e.g. `static const String routeList = '/'`, `static const String routeDetail = '/detail'`).                                            |
| 4    | In **Layout**’s `_pages`, use the **section** widget instead of the list: e.g. `'Job Application': const JobApplicationSection()`.                                                           |
| 5    | Export the section from your view/recruitment index (and from `view/index.dart` if Layout imports from there).                                                                               |
| 6    | From the **list** page (or a child), call `Navigator.of(context).pushNamed(YourSection.routeDetail, arguments: {...})` so the context is **inside** the section.                             |
| 7    | On the **detail** page, use `Navigator.of(context).pop()` for back; optionally add an in-content back button.                                                                                |

Optional:

- Use **PageRouteBuilder** in `onGenerateRoute` for a custom transition (slide, fade, etc.).
- Pass data via `arguments` and read `settings.arguments` in the route’s `pageBuilder`.

---

## 6. Minimal section template

```dart
// my_section.dart
import 'package:flutter/material.dart';
import 'my_list_view.dart';   // your list page
import 'my_detail_page.dart'; // your detail page

class MySection extends StatelessWidget {
  const MySection({super.key});

  static const String routeList = '/';
  static const String routeDetail = '/detail';

  @override
  Widget build(BuildContext context) {
    return Navigator(
      initialRoute: routeList,
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case routeList:
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => const MyListView(),
            );
          case routeDetail:
            final args = settings.arguments is Map
                ? settings.arguments as Map<String, dynamic>?
                : null;
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => MyDetailPage(id: args?['id']),
            );
          default:
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => const MyListView(),
            );
        }
      },
    );
  }
}
```

Then in the list (or a child):

```dart
Navigator.of(context).pushNamed(MySection.routeDetail, arguments: {'id': myId});
```

And in the detail:

```dart
Navigator.of(context).pop();
```

---

## 7. Summary

- **Nested Navigator** = a `Navigator` used as the body content for one section inside Layout.
- **Layout** shows the **section widget** (which is that Navigator), not the list page directly.
- **Context** of widgets inside the section is below that Navigator, so `Navigator.of(context)` is the nested one → push/pop stay inside the section and keep the app bar and layout unchanged.
- To reuse: add a section widget that returns a Navigator, plug it into `_pages`, and navigate from the list with `pushNamed`/`pop` using the same pattern.
