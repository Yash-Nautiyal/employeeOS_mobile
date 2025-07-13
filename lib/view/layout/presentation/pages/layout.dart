import 'package:employeeos/core/common/components/home_nav.dart';
import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:employeeos/view/chat/presentation/pages/chat_view.dart';
import 'package:employeeos/view/dashboard/presentation/pages/user_dashboard_view.dart';
import 'package:employeeos/view/filemanager/presentation/pages/filemanager_view.dart';
import 'package:employeeos/view/hiring/presentation/pages/hiring_view.dart';
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
    'Hirings': const HiringView(),
    'Kanban': const KanbanView(),
    'Chat': const ChatPage(),
    'File Manager': const FilemanagerView(),
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
      drawer: ClipRRect(
        child: Container(
          width: 300,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).brightness == Brightness.dark
                    ? const Color.fromARGB(255, 84, 47, 45)
                    : AppPallete.errorLighter,
                Theme.of(context).brightness == Brightness.dark
                    ? const Color.fromARGB(
                        255,
                        18,
                        21,
                        25,
                      ).withOpacity(.9)
                    : const Color.fromARGB(255, 251, 251, 251),
                Theme.of(context).brightness == Brightness.dark
                    ? const Color.fromARGB(255, 18, 21, 25)
                    : const Color.fromARGB(255, 251, 251, 251),
                Theme.of(context).brightness == Brightness.dark
                    ? const Color.fromARGB(255, 46, 76, 88)
                    : const Color.fromARGB(255, 212, 251, 251),
              ],
              stops: theme.brightness == Brightness.dark
                  ? [0.0, .17, .86, 1]
                  : [0.05, 0.3, .7, 0.99],
              begin: const Alignment(-1.7, 1),
              end: const Alignment(1.2, -1),
            ),
          ),
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
                          color: theme.dividerColor),
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

                  MenuItem(
                    icon: 'assets/icons/nav/ic-dashboard.svg',
                    title: 'Hirings',
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
                          color: theme.dividerColor),
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
      ),
      body:
          _pages[_selectedItem] ?? const Center(child: Text('Page not found')),
    );
  }
}
