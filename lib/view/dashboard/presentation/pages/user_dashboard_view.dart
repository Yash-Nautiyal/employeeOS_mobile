import 'package:employeeos/view/dashboard/presentation/widgets/birthday_container.dart';
import 'package:employeeos/view/dashboard/presentation/widgets/tasks_list.dart';
import 'package:flutter/material.dart';
import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:employeeos/view/dashboard/presentation/widgets/analytics_container.dart';
import 'package:employeeos/view/dashboard/presentation/widgets/heading_slide.dart';
import 'package:employeeos/view/dashboard/presentation/widgets/welcome_header.dart';

class UserDashboardView extends StatelessWidget {
  const UserDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0).copyWith(top: 120),
        child: Column(
          children: [
            WelcomeHeader(screenHeight: screenHeight, theme: theme),
            const SizedBox(height: 20),
            HeadingSlide(theme: theme),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                AnalyticsContainer(
                    theme: theme,
                    color: AppPallete.secondaryLighter,
                    titleColor: AppPallete.secondaryDark,
                    valueColor: AppPallete.secondaryDarker,
                    icon: 'assets/icons/glass/ic-glass-users.svg',
                    title: 'New Users',
                    value: '86.6K'),
                AnalyticsContainer(
                    theme: theme,
                    color: AppPallete.successLighter,
                    titleColor: AppPallete.successDark,
                    valueColor: AppPallete.successDarker,
                    icon: 'assets/icons/glass/ic-glass-bag.svg',
                    title: 'Weekly Sales',
                    value: '2.6K'),
                AnalyticsContainer(
                    theme: theme,
                    color: AppPallete.errorLighter,
                    titleColor: AppPallete.errorDark,
                    valueColor: AppPallete.errorDarker,
                    icon: 'assets/icons/glass/ic-glass-message.svg',
                    title: 'Messages',
                    value: '123'),
                AnalyticsContainer(
                    theme: theme,
                    color: AppPallete.warningLighter,
                    titleColor: AppPallete.warningDark,
                    valueColor: AppPallete.warningDarker,
                    icon: 'assets/icons/glass/ic-glass-buy.svg',
                    title: 'Purchase Order',
                    value: '2K')
              ],
            ),
            const SizedBox(height: 20),
            TasksList(theme: theme, maxHeight: screenHeight * .5),
            const SizedBox(height: 10),
            BirthdayContainer(
              theme: theme,
              maxHeight: screenHeight * .5,
            )
          ],
        ),
      ),
    );
  }
}
