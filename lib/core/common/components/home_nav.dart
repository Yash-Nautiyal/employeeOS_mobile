import 'dart:ui';

import 'package:employeeos/core/common/components/custom_bagde.dart';
import 'package:employeeos/core/common/components/header/profile.dart';
import 'package:employeeos/core/common/components/header/settings/settings.dart';
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
  Size get preferredSize => const Size.fromHeight(70);
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
      surfaceTintColor: Colors.transparent,
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
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: widget.theme.scaffoldBackgroundColor.withOpacity(0.9),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  widget.theme.scaffoldBackgroundColor.withOpacity(.9),
                  widget.theme.scaffoldBackgroundColor.withOpacity(.5),
                ],
              ),
            ),
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
          CustomBagde(
            theme: widget.theme,
            label: "1",
            child: IconButton(
              onPressed: () {},
              icon: SvgPicture.asset('assets/icons/ic-bell.svg',
                  width: 24, height: 24),
            ),
          ),
        ],
        IconButton(
          icon: RotationTransition(
            turns: turnsTween.animate(_controller),
            child: SvgPicture.asset('assets/icons/ic-settings.svg',
                width: 24, height: 24),
          ),
          onPressed: () {
            Navigator.of(context).push(
              PageRouteBuilder(
                opaque: false,
                barrierColor: Colors.black54,
                pageBuilder: (context, _, __) => const SettingsDialog(),
              ),
            );
          },
        ),
        if (widget.dashboardPage)
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  opaque: false,
                  barrierColor: Colors.black54,
                  pageBuilder: (context, _, __) =>
                      ProfileDialog(theme: widget.theme),
                ),
              );
            },
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) => Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    center: Alignment.center,
                    startAngle: 0.0,
                    endAngle: 6.28319,
                    colors: const [
                      Colors.blue,
                      Colors.purple,
                      Colors.red,
                      Colors.orange,
                      Colors.yellow,
                      Colors.blue,
                    ],
                    stops: const [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
                    transform: GradientRotation(
                      _controller.value * 6.28319,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: CircleAvatar(
                    backgroundColor: widget.theme.scaffoldBackgroundColor,
                    child: const CircleAvatar(radius: 14),
                  ),
                ),
              ),
            ),
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
