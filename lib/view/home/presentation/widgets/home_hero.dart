import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';

class HomeHero extends StatelessWidget {
  const HomeHero({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Background with animated elements
        Container(
          height: size.height * 0.5, // 50vh equivalent
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

class HeroTitle extends StatefulWidget {
  final ThemeData theme;

  const HeroTitle({
    super.key,
    required this.theme,
  });

  @override
  State<HeroTitle> createState() => _HeroTitleState();
}

class _HeroTitleState extends State<HeroTitle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 10),
        animationBehavior: AnimationBehavior.preserve)
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLarge = size.width > 900;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8.0,
      runSpacing: 8.0,
      children: [
        Text('Welcome to', style: widget.theme.textTheme.displayMedium),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Text(
              'EmployeeOS',
              style: widget.theme.textTheme.displayMedium?.copyWith(
                foreground: Paint()
                  ..shader = LinearGradient(
                    colors: const [
                      AppPallete.primaryMain,
                      AppPallete.warningMain,
                      AppPallete.primaryMain,
                      AppPallete.warningMain,
                      AppPallete.primaryMain,
                    ],
                    stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    // This is the key part - animate the transform
                    transform: SlidingGradientTransform(
                      translation: _controller.value,
                    ),
                  ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
              ),
            );
          },
        ),
      ],
    );
  }
}

// Custom GradientTransform to create the sliding effect
class SlidingGradientTransform extends GradientTransform {
  const SlidingGradientTransform({
    required this.translation,
  });

  final double translation;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(
      bounds.width * translation,
      0.0,
      0.0,
    );
  }
}
