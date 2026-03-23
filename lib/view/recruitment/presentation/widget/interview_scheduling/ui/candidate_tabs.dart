import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';

class CandidateTabs extends StatelessWidget {
  final ThemeData theme;
  final TabController controller;

  const CandidateTabs({
    super.key,
    required this.theme,
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
          Tab(text: 'Eligible Candidates'),
          Tab(text: 'Scheduled Interviews'),
        ],
      ),
    );
  }
}

