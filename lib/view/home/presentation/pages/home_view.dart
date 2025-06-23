import 'package:employeeos/core/common/components/home_nav.dart';
import 'package:employeeos/view/home/presentation/widgets/home_hero.dart';
import 'package:employeeos/view/home/presentation/widgets/home_minimal.dart';
import 'package:flutter/material.dart';

import '../../../auth/presentation/pages/auth_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  final _scrollController = ScrollController();
  bool _showBackToTop = false;

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

  // void _scrollToTop() {
  //   _scrollController.animateTo(
  //     0,
  //     duration: const Duration(milliseconds: 500),
  //     curve: Curves.easeInOut,
  //   );
  // }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: HomeNav(
        theme: theme,
        signinPage: true,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AuthView()),
          );
        },
      ),
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: SingleChildScrollView(
        physics: const RangeMaintainingScrollPhysics(
          parent: BouncingScrollPhysics(
              decelerationRate: ScrollDecelerationRate.fast),
        ),
        controller: _scrollController,
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            const HomeHero(),
            HomeMinimal(theme: theme)
          ],
        ),
      ),
    );
  }
}
