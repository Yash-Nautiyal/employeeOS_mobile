import 'dart:ui';

import 'package:employeeos/view/home/presentation/widgets/home_hero.dart';
import 'package:employeeos/view/home/presentation/widgets/home_minimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  final _scrollController = ScrollController();
  bool _showBackToTop = false;

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
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.offset >= MediaQuery.of(context).size.height &&
        !_showBackToTop) {
      setState(() => _showBackToTop = true);
    } else if (_scrollController.offset < MediaQuery.of(context).size.height &&
        _showBackToTop) {
      setState(() => _showBackToTop = false);
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
            decelerationRate: ScrollDecelerationRate.normal),
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            centerTitle: true,
            leading: Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Image.asset(
                'assets/logo/employeeos-logo.png',
              ),
            ),
            leadingWidth: 70,
            elevation: 0,
            backgroundColor: Colors.transparent,
            toolbarHeight: 70,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: theme.brightness == Brightness.dark
                  ? Brightness.light
                  : Brightness.dark,
            ),
            flexibleSpace: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  color: theme.scaffoldBackgroundColor.withOpacity(0.5),
                ),
              ),
            ),
            actionsPadding: const EdgeInsets.only(right: 10),
            actions: [
              IconButton(
                icon: RotationTransition(
                  turns: turnsTween.animate(_controller),
                  child: SvgPicture.asset('assets/icons/ic-settings.svg',
                      width: 24, height: 24),
                ),
                onPressed: () {},
              ),
              TextButton(
                onPressed: () {},
                child: Text('Sign In',
                    style: theme.textTheme.bodyLarge?.copyWith(fontSize: 15)),
              )
            ],
          ),
          const SliverToBoxAdapter(
            child: HomeHero(),
          ),
          SliverToBoxAdapter(child: MinimalFeatures())
        ],
      ),
    );
  }
}
