import 'package:employeeos/core/common/components/custom_bread_crumbs.dart';
import 'package:employeeos/view/recruitment/presentation/widget/job_posting_card.dart';
import 'package:flutter/material.dart';

class JobPostingView extends StatefulWidget {
  const JobPostingView({super.key});

  @override
  State<JobPostingView> createState() => _JobPostingViewState();
}

class _JobPostingViewState extends State<JobPostingView> {
  final scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.only(top: 120, bottom: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomBreadCrumbs(
            theme: theme,
            heading: 'Job Posting',
            routes: const ['Dashboard', 'Job', 'Posting'],
          ),
          const SizedBox(
            height: 20,
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.builder(
                controller: scrollController,
                itemCount: 3,
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  mainAxisSpacing: 20,
                  crossAxisCount: 1,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) => JobPostingCard(theme: theme),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
