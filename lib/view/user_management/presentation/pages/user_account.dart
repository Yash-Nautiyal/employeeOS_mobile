import 'package:employeeos/core/common/components/custom_bread_crumbs.dart';
import 'package:employeeos/view/user_management/presentation/widgets/user_account_general.dart';
import 'package:employeeos/view/user_management/presentation/widgets/user_account_security.dart';
import 'package:employeeos/view/user_management/presentation/widgets/user_account_social_links.dart';
import 'package:employeeos/view/user_management/presentation/widgets/user_account_tab.dart';
import 'package:flutter/material.dart';

class UserAccount extends StatefulWidget {
  const UserAccount({super.key});

  @override
  State<UserAccount> createState() => _UserAccountState();
}

class _UserAccountState extends State<UserAccount>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isPublicProfile = true;
  String selectedCountry = 'Country';

  final facebookController = TextEditingController();
  final instagramController = TextEditingController();
  final xController = TextEditingController();
  final linkedinController = TextEditingController();

  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final TextEditingController nameController =
      TextEditingController(text: 'Jayvion Simon');
  final TextEditingController emailController =
      TextEditingController(text: 'nannie.abernathy70@yahoo.com');
  final TextEditingController phoneController =
      TextEditingController(text: '365-374-4961');
  final TextEditingController addressController =
      TextEditingController(text: '19034 Verna Unions Apt. 164 - Honol...');
  final TextEditingController stateController =
      TextEditingController(text: 'Chalandri');
  final TextEditingController cityController =
      TextEditingController(text: 'Chalandri');
  final TextEditingController zipController =
      TextEditingController(text: '22000');
  final TextEditingController aboutController = TextEditingController(
      text:
          'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Sed aliquam, nisl quis porttitor congue, elit erat euismod orci, ac placerat dolor lectus quis orci.');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    stateController.dispose();
    cityController.dispose();
    zipController.dispose();
    aboutController.dispose();

    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();

    facebookController.dispose();
    xController.dispose();
    linkedinController.dispose();
    instagramController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomBreadCrumbs(
            theme: theme,
            routes: const ['Dashboard', 'User', 'Account'],
            heading: 'User Account',
          ),
          const SizedBox(height: 30),
          UserAccountTab(
            theme: theme,
            tabController: _tabController,
            tabs: const ['General', 'Security', 'Social Links'],
            onTabSelected: (index) {
              // Handle tab selection if needed
            },
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                UserAccountGeneral(
                    theme: theme,
                    isPublicProfile: isPublicProfile,
                    nameController: nameController,
                    emailController: emailController,
                    phoneController: phoneController,
                    addressController: addressController,
                    stateController: stateController,
                    cityController: cityController,
                    zipController: zipController,
                    aboutController: aboutController,
                    selectedCountry: selectedCountry,
                    onPublicProfileChanged: (value) {
                      setState(() {
                        isPublicProfile = value;
                      });
                    }),
                UserAccountSecurity(
                  theme: theme,
                  oldPasswordController: oldPasswordController,
                  newPasswordController: newPasswordController,
                  confirmPasswordController: confirmPasswordController,
                ),
                UserAccountSocialLinks(
                    theme: theme,
                    facebookController: facebookController,
                    instagramController: instagramController,
                    xController: xController,
                    linkedinController: linkedinController)
              ],
            ),
          ),
        ],
      ),
    );
  }
}
