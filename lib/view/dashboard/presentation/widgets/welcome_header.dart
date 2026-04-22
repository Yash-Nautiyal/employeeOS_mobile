import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';

class WelcomeHeader extends StatelessWidget {
  final double screenHeight;
  final ThemeData theme;
  const WelcomeHeader(
      {super.key, required this.screenHeight, required this.theme});

  @override
  Widget build(BuildContext context) {
    final wideScreen = MediaQuery.of(context).size.width > 700;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    final isWideScreen = !isPortrait || wideScreen;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        Container(
          constraints: const BoxConstraints(maxHeight: 500),
          height: isWideScreen ? screenWidth * 0.4 : screenHeight * 0.6,
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
              padding: EdgeInsets.only(top: isWideScreen ? 20 : 30, bottom: 10),
              child: Column(
                children: [
                  Flexible(
                    child: Column(
                      children: [
                        Text(
                          'Welcome back 👋',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.displaySmall
                              ?.copyWith(color: AppPallete.white),
                        ),
                        Text(
                          'Yash Nautiyal',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.displayMedium
                              ?.copyWith(color: AppPallete.white),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30.0),
                          child: Text(
                            textAlign: TextAlign.center,
                            'Track tasks, messages, and team activity in one place to stay focused and move work forward.',
                            style: theme.textTheme.titleMedium?.copyWith(
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
