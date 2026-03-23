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

    final wideScreen = MediaQuery.of(context).size.width > 700;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    final isWideScreen = !isPortrait || wideScreen;

    final analyticsCards = [
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
    ];

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 20, bottom: 20),
        child: Column(
          children: [
            if (isWideScreen) ...[
              Row(
                children: [
                  Expanded(
                      flex: 6,
                      child: WelcomeHeader(
                          screenHeight: screenHeight, theme: theme)),
                  const SizedBox(width: 10),
                  Expanded(flex: 2, child: HeadingSlide(theme: theme)),
                ],
              ),
              const SizedBox(height: 20),
            ] else ...[
              WelcomeHeader(screenHeight: screenHeight, theme: theme),
              const SizedBox(height: 20),
              Container(
                constraints: const BoxConstraints(maxHeight: 270),
                height: screenHeight * .3,
                child: HeadingSlide(theme: theme),
              ),
              const SizedBox(height: 20),
            ],
            GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isWideScreen ? 4 : 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                mainAxisExtent: isWideScreen ? 140 : 130,
              ),
              itemCount: analyticsCards.length,
              itemBuilder: (_, index) => analyticsCards[index],
            ),
            const SizedBox(height: 20),
            if (!isWideScreen) ...[
              TasksList(theme: theme, maxHeight: screenHeight * .5),
              const SizedBox(height: 10),
              BirthdayContainer(
                theme: theme,
                maxHeight: screenHeight * .5,
              )
            ] else ...[
              Row(
                children: [
                  Expanded(
                    flex: 6,
                    child:
                        TasksList(theme: theme, maxHeight: screenHeight * .9),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 7,
                    child: BirthdayContainer(
                        theme: theme, maxHeight: screenHeight * .9),
                  ),
                ],
              )
            ]
          ],
        ),
      ),
    );
  }
}
