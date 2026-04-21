import 'dart:async';
import 'dart:ui';

import 'package:employeeos/core/common/components/ui/connectivity_banner.dart';
import 'package:employeeos/core/common/components/appBar/home_nav.dart';
import 'package:employeeos/view/layout/presentation/widgets/exit_toast.dart';
import 'package:employeeos/view/layout/presentation/widgets/menu_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Layout extends StatefulWidget {
  final String selectedItem;
  final Widget child;

  const Layout({
    super.key,
    this.selectedItem = 'User',
    required this.child,
  });

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> with SingleTickerProviderStateMixin {
  late AnimationController _appBarController;
  late Animation<Offset> _appBarAnimation;
  Timer? _hideTimer;
  Orientation? _previousOrientation;
  DateTime? _currentBackPressTime;
  bool _showExitToast = false;

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
      if (mounted) _startHideTimer();
    });
  }

  @override
  void dispose() {
    _appBarController.dispose();
    _hideTimer?.cancel();
    super.dispose();
  }

  void _startHideTimer() {
    if (!mounted) return;
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
    if (!mounted) return;
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

    final selectedItem = widget.selectedItem;
    final selectedPage = widget.child;

    // Detect orientation change
    if (_previousOrientation != currentOrientation) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
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

    return PopScope(
      canPop: false, // Prevents the default system back behavior
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) return;

        final now = DateTime.now();
        // Check if this is the first press OR if more than 2 seconds have passed
        if (_currentBackPressTime == null ||
            now.difference(_currentBackPressTime!) >
                const Duration(seconds: 2)) {
          _currentBackPressTime = now; // Update the time

          // Show toast with enter/exit animation
          setState(() => _showExitToast = true);
          return;
        }

        // If pressed within 2 seconds, exit the app securely
        SystemNavigator.pop();
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: false,
        appBar: isPortrait
            ? HomeNav(
                theme: theme,
                dashboardPage: true,
              )
            : null,
        drawerScrimColor: Colors.black54,
        drawer: MenuDrawer(
          selectedItem: selectedItem,
        ),
        body: Stack(
          children: [
            // Main content with scroll detection for nested scrollables
            NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                // Only detect scroll updates in landscape mode
                if (!isLandscape) return false;
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
                child: selectedItem == 'Kanban'
                    ? Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).padding.top +
                                (isPortrait ? kToolbarHeight : 10),
                            bottom: 10),
                        child: selectedPage,
                      )
                    : selectedPage,
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

            // Global "No internet connection" banner shown above the nav bar.
            const ConnectivityBanner(),

            // "Press back again to exit" toast with enter + exit animation
            if (_showExitToast)
              ExitToast(
                message: 'Press back again to exit',
                displayDuration: const Duration(seconds: 2),
                onDismissed: () => setState(() => _showExitToast = false),
              ),
          ],
        ),
      ),
    );
  }
}
