import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class UserCardsGridCard extends StatelessWidget {
  final ThemeData theme;
  final UserCard card;
  const UserCardsGridCard({super.key, required this.card, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.shadowColor),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor,
            spreadRadius: 2,
            blurRadius: 10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          child: Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: Column(
                  children: [
                    Flexible(
                      flex: 4,
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                              getBackgroundImage(),
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const Flexible(
                      flex: 2,
                      child: SizedBox(),
                    )
                  ],
                ),
              ),
              // Content
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ClipPath(
                  clipper: JsonPathClipper(),
                  child: Container(
                    color: theme.colorScheme.surface,
                    padding: const EdgeInsets.only(top: 10, bottom: 20),
                    child: Column(
                      children: [
                        // Avatar
                        const CircleAvatar(
                          radius: 30,
                          child: Icon(
                            Icons.person,
                            size: 20,
                          ),
                        ),
                        // Name and Title
                        Text(card.name, style: theme.textTheme.titleLarge),

                        Text(card.title, style: theme.textTheme.bodyMedium),
                        const SizedBox(height: 16),
                        // Social Icons
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 80.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SvgPicture.asset(
                                "assets/icons/social/ic-facebbook.svg",
                                width: 20,
                              ),
                              SvgPicture.asset(
                                "assets/icons/social/ic-instagram.svg",
                                width: 20,
                              ),
                              SvgPicture.asset(
                                "assets/icons/social/ic-linkedin.svg",
                                width: 20,
                              ),
                              SvgPicture.asset(
                                "assets/icons/social/ic-twitter.svg",
                                width: 20,
                                color: theme.colorScheme.tertiary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getBackgroundImage() {
    final random = Random().nextInt(7) + 2;
    return "assets/images/background/background-$random.jpg";
  }
}

class UserCard {
  final String name;
  final String title;
  final String followers;
  final String following;
  final String totalPosts;
  final String backgroundImage;
  final String avatar;

  UserCard({
    required this.name,
    required this.title,
    required this.followers,
    required this.following,
    required this.totalPosts,
    required this.backgroundImage,
    required this.avatar,
  });
}

class JsonPathClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    // Same path logic as the painter but returns the path
    const originalWidth = 588.160009765625;
    const originalHeight = 588.160009765625;

    final scaleX = size.width / originalWidth;
    final scaleY = size.height / originalHeight;

    final path = Path();

    path.moveTo(194.6 * scaleX, 82.1 * scaleY);

    // Apply all the same cubic curves as in the painter
    path.cubicTo(208.5 * scaleX, 65.45 * scaleY, 203.726 * scaleX,
        71.325 * scaleY, 220.699 * scaleX, 52.3625 * scaleY);
    path.cubicTo(236.785 * scaleX, 34.081 * scaleY, 231.5 * scaleX,
        38.2 * scaleY, 247.6 * scaleX, 20.4 * scaleY);
    path.cubicTo(262.1 * scaleX, 4 * scaleY, 289.236 * scaleX, 0 * scaleY,
        292.48 * scaleX, 0 * scaleY);
    path.cubicTo(321.432 * scaleX, 0 * scaleY, 334.136 * scaleX,
        13.007 * scaleY, 343 * scaleX, 22.814 * scaleY);
    path.cubicTo(351.863 * scaleX, 32.621 * scaleY, 357.081 * scaleX,
        44.029 * scaleY, 364.9 * scaleX, 53.632 * scaleY);
    path.cubicTo(390.004 * scaleX, 87.644 * scaleY, 378.563 * scaleX,
        74.188 * scaleY, 392 * scaleX, 86.866 * scaleY);
    path.cubicTo(403.038 * scaleX, 98.744 * scaleY, 417.158 * scaleX,
        110.356 * scaleY, 468.128 * scaleX, 117.7 * scaleY);
    path.cubicTo(499.314 * scaleX, 117.7 * scaleY, 551.36 * scaleX,
        117.248 * scaleY, 588.16 * scaleX, 117.7 * scaleY);
    path.cubicTo(588.16 * scaleX, 139.751 * scaleY, 588.16 * scaleX,
        204.078 * scaleY, 588.16 * scaleX, 235.264 * scaleY);
    path.lineTo(588.16 * scaleX, 470.528 * scaleY);
    path.cubicTo(588.16 * scaleX, 501.714 * scaleY, 588.16 * scaleX,
        588.16 * scaleY, 588.16 * scaleX, 588.16 * scaleY);
    path.cubicTo(588.16 * scaleX, 588.16 * scaleY, 501.714 * scaleX,
        588.16 * scaleY, 470.528 * scaleX, 588.16 * scaleY);
    path.lineTo(117.632 * scaleX, 588.16 * scaleY);
    path.cubicTo(86.446 * scaleX, 588.16 * scaleY, 0 * scaleX, 588.16 * scaleY,
        0 * scaleX, 588.16 * scaleY);
    path.cubicTo(0 * scaleX, 588.16 * scaleY, 0 * scaleX, 501.714 * scaleY,
        0 * scaleX, 470.528 * scaleY);
    path.lineTo(0 * scaleX, 235.264 * scaleY);
    path.cubicTo(0 * scaleX, 204.078 * scaleY, 0 * scaleX, 139.737 * scaleY,
        0 * scaleX, 117.686 * scaleY);
    path.cubicTo(55.2 * scaleX, 118.834 * scaleY, 59 * scaleX, 119.2 * scaleY,
        120.1 * scaleX, 117.7 * scaleY);
    path.cubicTo(171.3 * scaleX, 108.1 * scaleY, 168 * scaleX, 105.4 * scaleY,
        194.6 * scaleX, 82.1 * scaleY);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
