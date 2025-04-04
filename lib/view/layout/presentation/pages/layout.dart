import 'package:employeeos/core/common/nav/home_nav.dart';
import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:employeeos/view/dashboard/presentation/pages/user_dashboard_view.dart';
import 'package:employeeos/view/kanban/presentation/pages/kanban_view.dart';
import 'package:employeeos/view/layout/presentation/widgets/menu_item.dart';
import 'package:flutter/material.dart';

class Layout extends StatefulWidget {
  const Layout({super.key});

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  final Map<String, Widget> _pages = {
    'User': const UserDashboardView(),
    'Kanban': const KanbanView(),
    'Chat': const Center(child: Text('Chat Page')),
    'File Manager': const Center(child: Text('File Manager Page')),
    'Calendar': const Center(child: Text('Calendar Page')),
    'Mail': const Center(child: Text('Mail Page')),
    'Account': const Center(child: Text('Account Page')),
    'Profile': const Center(child: Text('Profile Page')),
    'Card': const Center(child: Text('Card Page')),
  };
  String _selectedItem = 'User';
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: HomeNav(
        theme: theme,
        dashboardPage: true,
      ),
      drawer: Container(
        width: 300,
        color: theme.scaffoldBackgroundColor,
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 13).copyWith(top: 10),
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
                        color: AppPallete.grey600),
                  ),
                ),

                // Menu Items
                MenuItem(
                  icon: 'assets/icons/nav/ic-user.svg',
                  title: 'User',
                  theme: theme,
                  selectedItem: _selectedItem,
                  onSelected: (item) {
                    setState(() {
                      _selectedItem = item;
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
                        color: AppPallete.grey600),
                  ),
                ),

                // User Management Menu Items
                MenuItem(
                  icon: 'assets/icons/nav/ic-kanban.svg',
                  title: 'Kanban',
                  theme: theme,
                  selectedItem: _selectedItem,
                  onSelected: (item) {
                    setState(() {
                      _selectedItem = item;
                    });
                    Navigator.pop(context); // Close the drawer
                  },
                ),
                MenuItem(
                  icon: 'assets/icons/nav/ic-chat.svg',
                  title: 'Chat',
                  theme: theme,
                  selectedItem: _selectedItem,
                  onSelected: (item) {
                    setState(() {
                      _selectedItem = item;
                    });
                    Navigator.pop(context); // Close the drawer
                  },
                ),
                MenuItem(
                  icon: 'assets/icons/nav/ic-folder.svg',
                  title: 'File Manager',
                  theme: theme,
                  selectedItem: _selectedItem,
                  onSelected: (item) {
                    setState(() {
                      _selectedItem = item;
                    });
                    Navigator.pop(context); // Close the drawer
                  },
                ),
                MenuItem(
                  icon: 'assets/icons/nav/ic-calendar.svg',
                  title: 'Calendar',
                  theme: theme,
                  selectedItem: _selectedItem,
                  onSelected: (item) {
                    setState(() {
                      _selectedItem = item;
                    });
                    Navigator.pop(context); // Close the drawer
                  },
                ),
                MenuItem(
                  icon: 'assets/icons/nav/ic-mail.svg',
                  title: 'Mail',
                  theme: theme,
                  selectedItem: _selectedItem,
                  onSelected: (item) {
                    setState(() {
                      _selectedItem = item;
                    });
                    Navigator.pop(context); // Close the drawer
                  },
                ),
                MenuItem(
                  icon: 'assets/icons/nav/ic-user-management.svg',
                  title: 'User Management',
                  theme: theme,
                  selectedItem: _selectedItem,
                  onSelected: (item) {
                    setState(() {
                      _selectedItem = item;
                    });
                    Navigator.pop(context); // Close the drawer
                  },
                  submenuItems: const ['Account', 'Profile', 'Card'],
                ),
              ],
            ),
          ),
        ),
      ),
      body:
          _pages[_selectedItem] ?? const Center(child: Text('Page not found')),
    );
  }
}
