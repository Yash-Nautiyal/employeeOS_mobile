import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';

class InterviewRoundsTab extends StatelessWidget {
  final ThemeData theme;
  final bool isWideScreen;
  final TabController controller;

  const InterviewRoundsTab({
    super.key,
    required this.theme,
    required this.isWideScreen,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
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
        tabs: const [
          Tab(text: 'Telephone Round'),
          Tab(text: 'Technical Round'),
          Tab(text: 'Onboarding'),
          Tab(text: 'Selected'),
          Tab(text: 'Rejected'),
        ],
      ),
    );
  }
}

