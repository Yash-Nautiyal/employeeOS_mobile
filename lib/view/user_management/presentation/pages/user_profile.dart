import 'package:employeeos/core/common/components/ui/custom_bread_crumbs.dart';
import 'package:employeeos/core/user/current_user_profile.dart';
import 'package:employeeos/view/user_management/presentation/widgets/user_profile_about.dart';
import 'package:employeeos/view/user_management/presentation/widgets/user_profile_contacts.dart';
import 'package:employeeos/view/user_management/presentation/widgets/user_profile_header.dart';
import 'package:employeeos/view/user_management/presentation/widgets/user_profile_role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/auth/bloc/auth_bloc.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  CurrentUserProfile? _profile;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadProfile(context.read<AuthBloc>().state.currentProfile);
    });
  }

  void _loadProfile(CurrentUserProfile? profile) {
    if (profile == null) return;
    setState(() {
      _profile = profile;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final socialLinks = _profile?.metadata?['social_links'] ?? {};
    print(socialLinks);
    return SingleChildScrollView(
      padding:
          EdgeInsets.only(top: MediaQuery.of(context).padding.top, bottom: 16),
      child: Column(
        children: [
          CustomBreadCrumbs(
            theme: theme,
            routes: const ['Dashboard', 'User', 'Profile'],
            heading: 'User Profile',
          ),
          const SizedBox(
            height: 20,
          ),
          UserProfileHeader(
              theme: theme,
              tabController: _tabController,
              fullName: _profile?.fullName ?? '',
              avatarUrl: _profile?.avatarUrl ?? '',
              designation:
                  _profile?.metadata?['designation']?.toString() ?? ''),
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
                      child: UserProfileAbout(
                          theme: theme,
                          dateOfBirth: _profile?.metadata?['date_of_birth']
                                  ?.toString() ??
                              ''),
                    ),
                    const SizedBox(
                      width: 7,
                    ),
                    Flexible(
                      flex: 4,
                      child: UserProfileRole(
                        theme: theme,
                        role: _profile?.role.value ?? '',
                        socialLinks: socialLinks,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Flexible(
                    //   flex: 7,
                    //   child: UserProfileSocialLink(theme: theme),
                    // ),
                    // const SizedBox(
                    //   width: 7,
                    // ),
                    Flexible(
                      flex: 8,
                      child: UserProfileContacts(
                          theme: theme,
                          phoneNumber: _profile?.phoneNumber ?? ''),
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
