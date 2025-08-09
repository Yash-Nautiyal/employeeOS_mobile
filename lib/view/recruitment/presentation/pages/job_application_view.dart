import 'package:employeeos/core/common/components/custom_bread_crumbs.dart';
import 'package:employeeos/view/recruitment/presentation/widget/job_application_card.dart';
import 'package:flutter/material.dart';

class JobApplicationView extends StatelessWidget {
  const JobApplicationView({super.key});

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();

    final theme = Theme.of(context);
    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.only(top: 120, bottom: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomBreadCrumbs(
            theme: theme,
            heading: 'Job Applications',
            routes: const ['Dashboard', 'Job', 'Applications'],
          ),
          const SizedBox(
            height: 20,
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: JobApplicationCard(
                  scrollController: scrollController, theme: theme),
            ),
          ),
        ],
      ),
    );
  }
}
