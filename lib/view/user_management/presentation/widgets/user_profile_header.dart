import 'package:employeeos/core/common/actions/user_actions.dart';
import 'package:employeeos/core/theme/app_pallete.dart' show AppPallete;
import 'package:employeeos/view/user_management/presentation/widgets/user_account_tab.dart';
import 'package:flutter/material.dart';

class UserProfileHeader extends StatelessWidget {
  final ThemeData theme;
  final TabController tabController;
  final String fullName;
  final String designation;
  final String avatarUrl;
  const UserProfileHeader(
      {super.key,
      required this.theme,
      required this.tabController,
      required this.fullName,
      required this.designation,
      required this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.maxFinite,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.shadowColor),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor,
            spreadRadius: 2,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Stack(
              children: [
                SizedBox(
                  width: double.maxFinite,
                  child: Image.asset(
                    'assets/images/background/background-8.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: AppPallete.primaryDark.withOpacity(.7),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundImage: avatarUrl.isNotEmpty
                              ? NetworkImage(avatarUrl)
                              : null,
                          child: avatarUrl.isEmpty
                              ? Text(
                                  getInitials(fullName),
                                  style: theme.textTheme.displaySmall
                                      ?.copyWith(color: Colors.white),
                                )
                              : null,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          fullName,
                          style: theme.textTheme.displaySmall
                              ?.copyWith(color: Colors.white),
                        ),
                        Text(
                          designation,
                          style: theme.textTheme.titleSmall
                              ?.copyWith(color: Colors.white),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          UserAccountTab(
            theme: theme,
            tabController: tabController,
            tabs: const ['Profile'],
            onTabSelected: (index) {},
          )
        ],
      ),
    );
  }
}
