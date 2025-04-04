import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';

class WelcomeHeader extends StatelessWidget {
  final double screenHeight;
  final ThemeData theme;
  const WelcomeHeader(
      {super.key, required this.screenHeight, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: screenHeight * .6,
          constraints: const BoxConstraints(minHeight: 430),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage('assets/images/background/background-5.jpg'),
            ),
          ),
        ),
        Positioned(
          bottom: 1,
          left: 0,
          right: .2,
          top: .2,
          child: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage('assets/images/background/overlay.png'),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 50.0, bottom: 10),
              child: Column(
                children: [
                  Flexible(
                    child: Column(
                      children: [
                        Text(
                          'Welcome back 👋 Yash Nautiyal',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.displayLarge
                              ?.copyWith(color: AppPallete.white),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30.0)
                              .copyWith(top: 15),
                          child: Text(
                            textAlign: TextAlign.center,
                            "If you are going to use a passage of Lorem Ipsum, you need to be sure there isn't anything.",
                            style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: AppPallete.grey500),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: Image.asset(
                        fit: BoxFit.contain,
                        'assets/illustrations/illustration-seo.png'),
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
