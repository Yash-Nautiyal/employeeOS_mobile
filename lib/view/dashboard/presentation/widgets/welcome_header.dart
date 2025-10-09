import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

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
    return Stack(
      children: [
        Container(
          height: isWideScreen ? 40.w : 60.h,
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
              padding:
                  EdgeInsets.only(top: isWideScreen ? 13.h : 5.h, bottom: 10),
              child: Column(
                children: [
                  Flexible(
                    child: Column(
                      children: [
                        Text(
                          'Welcome back 👋',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.displayLarge?.copyWith(
                              color: AppPallete.white, fontSize: 25.sp),
                        ),
                        Text(
                          'Yash Nautiyal',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.displayLarge?.copyWith(
                              color: AppPallete.white, fontSize: 25.sp),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30.0)
                              .copyWith(top: 15),
                          child: Text(
                            textAlign: TextAlign.center,
                            "If you are going to use a passage of Lorem Ipsum, you need to be sure there isn't anything.",
                            style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 15.5.sp,
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
