import 'dart:async';
import 'dart:ui';

import 'package:employeeos/core/common/components/home_nav.dart';
import 'package:employeeos/view/chat/presentation/pages/chat_view.dart';
import 'package:employeeos/view/dashboard/presentation/pages/user_dashboard_view.dart';
import 'package:employeeos/view/filemanager/presentation/pages/filemanager_view.dart';
import 'package:employeeos/view/hiring/presentation/pages/hiring_view.dart';
import 'package:employeeos/view/kanban/presentation/pages/kanban_view.dart';
import 'package:employeeos/view/layout/presentation/widgets/menu_drawer.dart';
import 'package:employeeos/view/recruitment/presentation/pages/job_application_view.dart';
import 'package:employeeos/view/recruitment/presentation/pages/job_posting_view.dart';
import 'package:employeeos/view/user_management/presentation/pages/user_account.dart';
import 'package:employeeos/view/user_management/presentation/pages/user_cards.dart';
import 'package:employeeos/view/user_management/presentation/pages/user_profile.dart';
import 'package:flutter/material.dart';

class Layout extends StatefulWidget {
  const Layout({super.key});

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> with SingleTickerProviderStateMixin {
  late AnimationController _appBarController;
  late Animation<Offset> _appBarAnimation;
  Timer? _hideTimer;
  Orientation? _previousOrientation;
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
  String _selectedItem = 'File Manager';

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
    final currentOrientation = MediaQuery.of(context).orientation;
    final isPortrait = currentOrientation == Orientation.portrait;
    final isLandscape = !isPortrait;
    final theme = Theme.of(context);

    // Detect orientation change
    if (_previousOrientation != currentOrientation) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (isLandscape) {
          // Just switched to landscape - show appbar and start hide timer
          if (!_appBarController.isCompleted) {
            _appBarController.forward();
          }
          _startHideTimer();
        } else {
          // Switched to portrait - ensure appbar is visible and cancel timer
          if (!_appBarController.isCompleted) {
            _appBarController.forward();
          }
          _hideTimer?.cancel();
        }
      });
      _previousOrientation = currentOrientation;
    }

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
      drawer: MenuDrawer(
        selectedItem: _selectedItem,
        onSelected: (p0) {
          setState(() {
            _selectedItem = p0;
          });
        },
      ),
      body: Stack(
        children: [
          // Main content with scroll detection for nested scrollables
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              // Only detect scroll updates in landscape mode
              if (!isLandscape) return false;

              if (notification is ScrollUpdateNotification) {
                // Check if this is a VERTICAL scroll (ignore horizontal PageViews, etc.)
                final isVerticalScroll =
                    notification.metrics.axisDirection == AxisDirection.down ||
                        notification.metrics.axisDirection == AxisDirection.up;

                // Only respond to vertical scrolling downward
                if (isVerticalScroll &&
                    notification.scrollDelta != null &&
                    notification.scrollDelta! < -10) {
                  // Threshold of -10 to avoid accidental triggers
                  _showAppBar();
                }
              }
              if (notification is OverscrollNotification) {
                if (notification.overscroll < -10) {
                  _showAppBar();
                }
              }
              return false;
            },
            child: GestureDetector(
              // Detect vertical drag down for non-scrollable areas
              onVerticalDragUpdate: (details) {
                if (!isLandscape) return;
                // Only show appbar when dragging downward (threshold of 5px)
                if (details.delta.dy > 5) {
                  _showAppBar();
                }
              },
              behavior: HitTestBehavior.translucent,
              child: _selectedItem == 'Kanban'
                  ? Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top +
                              (isPortrait ? 70 : 10),
                          bottom: 10),
                      child: _pages[_selectedItem] ??
                          const Center(child: Text('Page not found')),
                    )
                  : _pages[_selectedItem] ??
                      const Center(
                        child: Text('Page not found'),
                      ),
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
