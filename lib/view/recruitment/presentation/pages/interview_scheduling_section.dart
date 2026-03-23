import 'package:employeeos/view/recruitment/domain/job_posting/entities/job_posting.dart';
import 'package:employeeos/view/recruitment/presentation/widget/interview_scheduling/pages/interview_scheduling_detail_view.dart';
import 'package:employeeos/view/recruitment/presentation/widget/interview_scheduling/pages/interview_scheduling_jobs_list_page.dart';
import 'package:employeeos/view/recruitment/presentation/widget/interview_scheduling/routes/interview_scheduling_routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InterviewSchedulingSection extends StatelessWidget {
  const InterviewSchedulingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: const ValueKey('InterviewSchedulingSection'),
      initialRoute: InterviewSchedulingRoutes.list,
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case InterviewSchedulingRoutes.list:
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => const InterviewSchedulingJobsListPage(),
            );
          case InterviewSchedulingRoutes.detail:
            final args = settings.arguments is Map
                ? settings.arguments as Map<String, dynamic>?
                : null;
            final job = args?['job'];
            if (job is! JobPosting) {
              return MaterialPageRoute<void>(
                settings: settings,
                builder: (_) => const InterviewSchedulingJobsListPage(),
              );
            }
            return CupertinoPageRoute<void>(
              settings: settings,
              builder: (_) => InterviewSchedulingDetailView(job: job),
            );
          default:
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => const InterviewSchedulingJobsListPage(),
            );
        }
      },
    );
  }
}
