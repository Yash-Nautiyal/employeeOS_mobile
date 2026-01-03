import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:employeeos/view/layout/presentation/widgets/menu_item.dart';
import 'package:flutter/material.dart';

class MenuDrawer extends StatefulWidget {
  final String selectedItem;
  final Function(String) onSelected;
  const MenuDrawer(
      {super.key, required this.selectedItem, required this.onSelected});

  @override
  State<MenuDrawer> createState() => _MenuDrawerState();
}

class _MenuDrawerState extends State<MenuDrawer> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final wideScreen = MediaQuery.of(context).size.width > 700;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final isWideScreen = !isPortrait || wideScreen;
    final screenWidth = MediaQuery.of(context).size.width;
    return ClipRRect(
      child: Container(
        width: isWideScreen ? screenWidth * 0.4 : screenWidth * 0.75,
        decoration: BoxDecoration(
          gradient: Theme.of(context).brightness == Brightness.dark
              ? AppPallete.darkBackgroundGradient
              : AppPallete.lightBackgroundGradient,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13)
              .copyWith(top: MediaQuery.of(context).padding.top + 10),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // Logo and User section
              Align(
                alignment: Alignment.centerLeft,
                child: Image.asset(
                  'assets/logo/employeeos-logo.png',
                  height: 50,
                ),
              ),

              // Services Section
              Padding(
                padding: const EdgeInsets.only(top: 16, left: 16),
                child: Text(
                  'OVERVIEW',
                  style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      color: theme.dividerColor),
                ),
              ),

              // Menu Items
              MenuItem(
                icon: 'assets/icons/nav/ic-user.svg',
                title: 'User',
                theme: theme,
                selectedItem: widget.selectedItem,
                onSelected: (item) {
                  setState(() {
                    widget.onSelected(item);
                  });
                  Navigator.pop(context); // Close the drawer
                },
              ),

              MenuItem(
                icon: 'assets/icons/nav/ic-dashboard.svg',
                title: 'Hirings',
                theme: theme,
                selectedItem: widget.selectedItem,
                onSelected: (item) {
                  setState(() {
                    widget.onSelected(item);
                  });
                  Navigator.pop(context); // Close the drawer
                },
              ),

              // User Management Section
              Padding(
                padding: const EdgeInsets.only(top: 16, left: 16),
                child: Text(
                  'SERVICES',
                  style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      color: theme.dividerColor),
                ),
              ),

              // User Management Menu Items
              MenuItem(
                icon: 'assets/icons/nav/ic-kanban.svg',
                title: 'Kanban',
                theme: theme,
                selectedItem: widget.selectedItem,
                onSelected: (item) {
                  setState(() {
                    widget.onSelected(item);
                  });
                  Navigator.pop(context); // Close the drawer
                },
              ),
              MenuItem(
                icon: 'assets/icons/nav/ic-chat.svg',
                title: 'Chat',
                theme: theme,
                selectedItem: widget.selectedItem,
                onSelected: (item) {
                  setState(() {
                    widget.onSelected(item);
                  });
                  Navigator.pop(context); // Close the drawer
                },
              ),
              MenuItem(
                icon: 'assets/icons/nav/ic-folder.svg',
                title: 'File Manager',
                theme: theme,
                selectedItem: widget.selectedItem,
                onSelected: (item) {
                  setState(() {
                    widget.onSelected(item);
                  });
                  Navigator.pop(context); // Close the drawer
                },
              ),
              // MenuItem(
              //   icon: 'assets/icons/nav/ic-calendar.svg',
              //   title: 'Calendar',
              //   theme: theme,
              //   selectedItem: _selectedItem,
              //   onSelected: (item) {
              //     setState(() {
              //       _selectedItem = item;
              //     });
              //     Navigator.pop(context); // Close the drawer
              //   },
              // ),
              MenuItem(
                icon: 'assets/icons/nav/ic-mail.svg',
                title: 'Mail',
                theme: theme,
                selectedItem: widget.selectedItem,
                onSelected: (item) {
                  setState(() {
                    widget.onSelected(item);
                  });
                  Navigator.pop(context); // Close the drawer
                },
              ),
              MenuItem(
                icon: 'assets/icons/nav/ic-recruitment.svg',
                title: 'Recruitment',
                theme: theme,
                selectedItem: widget.selectedItem,
                onSelected: (item) {
                  setState(() {
                    widget.onSelected(item);
                  });
                  Navigator.pop(context); // Close the drawer
                },
                submenuItems: const [
                  'Job Posting',
                  'Job Application',
                  'Interview Scheduling'
                ],
              ),
              MenuItem(
                icon: 'assets/icons/nav/ic-user-management.svg',
                title: 'User Management',
                theme: theme,
                selectedItem: widget.selectedItem,
                onSelected: (item) {
                  setState(() {
                    widget.onSelected(item);
                  });
                  Navigator.pop(context); // Close the drawer
                },
                submenuItems: const ['Account', 'Profile', 'Card'],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
