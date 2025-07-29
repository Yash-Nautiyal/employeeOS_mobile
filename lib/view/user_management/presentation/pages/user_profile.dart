import 'package:employeeos/view/user_management/presentation/widgets/user_heading.dart';
import 'package:employeeos/view/user_management/presentation/widgets/user_profile_about.dart';
import 'package:employeeos/view/user_management/presentation/widgets/user_profile_contacts.dart';
import 'package:employeeos/view/user_management/presentation/widgets/user_profile_header.dart';
import 'package:employeeos/view/user_management/presentation/widgets/user_profile_role.dart';
import 'package:employeeos/view/user_management/presentation/widgets/user_profile_social_link.dart';
import 'package:flutter/material.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 120, bottom: 10),
      child: Column(
        children: [
          UserHeading(theme: theme, page: 'Profile'),
          const SizedBox(
            height: 20,
          ),
          UserProfileHeader(theme: theme, tabController: _tabController),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      flex: 5,
                      child: UserProfileAbout(theme: theme),
                    ),
                    const SizedBox(
                      width: 7,
                    ),
                    Flexible(
                      flex: 4,
                      child: UserProfileRole(theme: theme),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      flex: 7,
                      child: UserProfileSocialLink(theme: theme),
                    ),
                    const SizedBox(
                      width: 7,
                    ),
                    Flexible(
                      flex: 8,
                      child: UserProfileContacts(theme: theme),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
