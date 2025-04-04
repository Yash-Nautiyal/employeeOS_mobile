import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class HomeNav extends StatefulWidget implements PreferredSizeWidget {
  final ThemeData theme;
  final bool signinPage;
  final bool dashboardPage;
  final Function? onPressed;
  const HomeNav(
      {super.key,
      required this.theme,
      this.signinPage = false,
      this.dashboardPage = false,
      this.onPressed});

  @override
  State<HomeNav> createState() => _HomeNavState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _HomeNavState extends State<HomeNav> with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 5),
    vsync: this,
  )..repeat();

  final Tween<double> turnsTween = Tween<double>(
    begin: 0,
    end: 1,
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: widget.dashboardPage
          ? Builder(
              builder: (context) => IconButton(
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                icon: SvgPicture.asset(
                  'assets/icons/ic-menu-item.svg',
                  width: 24,
                ),
              ),
            )
          : Navigator.canPop(context)
              ? IconButton(
                  icon: Icon(Icons.arrow_back,
                      color: widget.theme.iconTheme.color),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              : Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Image.asset(
                    'assets/logo/employeeos-logo.png',
                    width: 70,
                  ),
                ),
      titleSpacing: 0,
      elevation: 0,
      toolbarHeight: 70,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
          child: Container(
            color: widget.theme.scaffoldBackgroundColor.withOpacity(0.8),
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.only(right: 8),
      actions: [
        if (widget.dashboardPage) ...[
          IconButton(
            onPressed: () {},
            icon: SvgPicture.asset('assets/icons/ic-eva_search-fill.svg',
                width: 24, height: 24),
          ),
          IconButton(
            onPressed: () {},
            icon: SvgPicture.asset('assets/icons/ic-bell.svg',
                width: 24, height: 24),
          ),
          IconButton(
            onPressed: () {},
            icon: SvgPicture.asset('assets/icons/ic-user-group.svg',
                width: 24, height: 24),
          ),
        ],
        IconButton(
          icon: RotationTransition(
            turns: turnsTween.animate(_controller),
            child: SvgPicture.asset('assets/icons/ic-settings.svg',
                width: 24, height: 24),
          ),
          onPressed: () {},
        ),
        if (widget.signinPage)
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: TextButton(
              onPressed: () => widget.onPressed?.call(),
              child: Text(
                'Sign In',
                style: widget.theme.textTheme.bodyLarge?.copyWith(fontSize: 15),
              ),
            ),
          )
      ],
    );
  }
}
