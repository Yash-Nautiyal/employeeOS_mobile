import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../domain/index.dart' show JobPosting;
import '../index.dart' show JobEditingPage, JobPostingView, JobViewPage;

/// Wrapper that provides a [Navigator] for the Job Posting section.
/// Keeps the layout's app bar visible while only the content area transitions
/// between list (JobPostingView) and detail (JobViewPage).
class JobPostingSection extends StatelessWidget {
  const JobPostingSection({super.key});

  static const String routeList = '/';
  static const String routeJobView = '/job';
  static const String routeJobEdit = '/job/edit';

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: const ValueKey('JobPostingSection'),
      initialRoute: routeList,
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case routeList:
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => const JobPostingView(),
            );
          case routeJobView:
            final args = settings.arguments is Map
                ? settings.arguments as Map<String, dynamic>?
                : null;
            final jobId = args?['id'];
            return CupertinoPageRoute<void>(
              settings: settings,
              builder: (_) => JobViewPage(jobId: jobId),
            );
          case routeJobEdit:
            final args = settings.arguments is Map
                ? settings.arguments as Map<String, dynamic>?
                : null;
            final job = args?['job'] as JobPosting?;
            if (job == null) {
              return MaterialPageRoute<void>(
                settings: settings,
                builder: (_) => const JobPostingView(),
              );
            }
            return CupertinoPageRoute<void>(
              settings: settings,
              builder: (_) => JobEditingPage(job: job),
            );
          default:
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => const JobPostingView(),
            );
        }
      },
    );
  }
}
