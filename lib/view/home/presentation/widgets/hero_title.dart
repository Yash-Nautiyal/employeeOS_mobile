import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';

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
