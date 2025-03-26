import 'package:employeeos/view/home/presentation/widgets/hero_title.dart';
import 'package:flutter/material.dart';

class HomeHero extends StatelessWidget {
  const HomeHero({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        SizedBox(
          height: size.height * 0.65,
          width: double.infinity,
          child: Image.asset('assets/images/Bg.png', fit: BoxFit.cover),
        ),

        Positioned(
          left: 50,
          right: 50,
          top: 50,
          bottom: 50,
          child: Image.asset(
            'assets/images/dots.png',
            fit: BoxFit.contain,
          ),
        ),
        // Content overlay
        Positioned(
          top: 0,
          bottom: 0,
          left: 0,
          right: 0,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title with gradient text
                  HeroTitle(theme: theme),

                  // Subtitle
                  const SizedBox(height: 24),
                  Text(
                    'Your one stop solution for all your Employee Management needs including Job Tracking and more.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
