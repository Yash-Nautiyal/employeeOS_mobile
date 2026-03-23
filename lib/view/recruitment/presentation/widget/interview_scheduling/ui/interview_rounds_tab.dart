import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:employeeos/view/recruitment/domain/interview_scheduling/interview_scheduling_tabs.dart';
import 'package:flutter/material.dart';

class InterviewRoundsTab extends StatelessWidget {
  final ThemeData theme;
  final bool isWideScreen;
  final TabController controller;
  final List<InterviewSchedulingRoundTab> tabs;

  const InterviewRoundsTab({
    super.key,
    required this.theme,
    required this.isWideScreen,
    required this.controller,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    if (tabs.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.brightness == Brightness.dark
                ? AppPallete.grey700
                : AppPallete.grey300,
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: controller,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        tabs: tabs.map((t) => Tab(text: t.label)).toList(),
      ),
    );
  }
}
