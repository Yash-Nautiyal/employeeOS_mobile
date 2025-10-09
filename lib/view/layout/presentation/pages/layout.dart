import 'dart:async';
import 'dart:ui';

import 'package:employeeos/core/common/components/home_nav.dart';
import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:employeeos/view/chat/presentation/pages/chat_view.dart';
import 'package:employeeos/view/dashboard/presentation/pages/user_dashboard_view.dart';
import 'package:employeeos/view/filemanager/presentation/pages/filemanager_view.dart';
import 'package:employeeos/view/hiring/presentation/pages/hiring_view.dart';
import 'package:employeeos/view/kanban/presentation/pages/kanban_view.dart';
import 'package:employeeos/view/layout/presentation/widgets/menu_item.dart';
import 'package:employeeos/view/recruitment/presentation/pages/job_application_view.dart';
import 'package:employeeos/view/recruitment/presentation/pages/job_posting_view.dart';
import 'package:employeeos/view/user_management/presentation/pages/user_account.dart';
import 'package:employeeos/view/user_management/presentation/pages/user_cards.dart';
import 'package:employeeos/view/user_management/presentation/pages/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class Layout extends StatefulWidget {
  const Layout({super.key});

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> with SingleTickerProviderStateMixin {
  late AnimationController _appBarController;
  late Animation<Offset> _appBarAnimation;
  Timer? _hideTimer;
  final Map<String, Widget> _pages = {
    'User': const UserDashboardView(),
    'Hirings': const HiringView(),
    'Kanban': const KanbanView(),
    'Chat': const ChatView(),
    'File Manager': const FilemanagerView(),
    // 'Calendar': const Center(child: Text('Calendar Page')),
    // 'Mail': const Center(child: Text('Mail Page')),
    'Job Posting': const JobPostingView(),
    'Job Application': const JobApplicationView(),
    'Interview Scheduling': const Center(child: Text('Interview Scheduling')),
    'Account': const UserAccount(),
    'Profile': const UserProfile(),
    'Card': const UserCards(),
  };
  String _selectedItem = 'Chat';

  @override
  void initState() {
    super.initState();
    _appBarController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _appBarAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _appBarController,
      curve: Curves.easeInOut,
    ));

    // Show appbar initially
    _appBarController.forward();

    // Start hide timer for landscape mode
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startHideTimer();
    });
  }

  @override
  void dispose() {
    _appBarController.dispose();
    _hideTimer?.cancel();
    super.dispose();
  }

  void _startHideTimer() {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    if (!isLandscape) return;

    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        final currentlyLandscape =
            MediaQuery.of(context).orientation == Orientation.landscape;
        if (currentlyLandscape) {
          _appBarController.reverse();
        }
      }
    });
  }

  void _showAppBar() {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    if (!isLandscape) return;

    if (!_appBarController.isCompleted) {
      _appBarController.forward();
    }
    _startHideTimer();
  }

  @override
  Widget build(BuildContext context) {
    final wideScreen = MediaQuery.of(context).size.width > 700;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final isLandscape = !isPortrait;
    final isWideScreen = !isPortrait || wideScreen;
    final theme = Theme.of(context);

    // Ensure appbar is visible in portrait mode
    if (isPortrait && !_appBarController.isCompleted) {
      _appBarController.forward();
      _hideTimer?.cancel();
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      // Show appbar normally in portrait, hide in landscape (will be added as overlay)
      appBar: isPortrait
          ? HomeNav(
              theme: theme,
              dashboardPage: true,
            )
          : null,
      drawerScrimColor: Colors.black54,
      drawer: ClipRRect(
        child: Container(
          width: isWideScreen ? 40.w : 75.w,
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
                  selectedItem: _selectedItem,
                  onSelected: (item) {
                    setState(() {
                      _selectedItem = item;
                    });
                    Navigator.pop(context); // Close the drawer
                  },
                ),
                MenuItem(
                  icon: 'assets/icons/nav/ic-recruitment.svg',
                  title: 'Recruitment',
                  theme: theme,
                  selectedItem: _selectedItem,
                  onSelected: (item) {
                    setState(() {
                      _selectedItem = item;
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
      body: Stack(
        children: [
          // Main content with gesture detection
          GestureDetector(
            onVerticalDragEnd: (_) => _showAppBar(),
            behavior: HitTestBehavior.translucent,
            child: Padding(
              padding:
                  EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10),
              child: _pages[_selectedItem] ??
                  const Center(child: Text('Page not found')),
            ),
          ),

          // Animated overlay appbar for landscape mode with frosted glass effect
          if (isLandscape)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SlideTransition(
                position: _appBarAnimation,
                child: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: HomeNav(
                      theme: theme,
                      dashboardPage: true,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
