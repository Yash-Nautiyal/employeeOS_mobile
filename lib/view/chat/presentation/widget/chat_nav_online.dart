import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;

class ChatNavOnline extends StatelessWidget {
  final ThemeData theme;
  const ChatNavOnline({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            'Online',
            style: theme.textTheme.labelLarge,
          ),
        ),
        const SizedBox(
          height: 2,
        ),
        SizedBox(
          height: 90,
          child: ListView.builder(
            itemCount: 8,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) => SizedBox(
              width: 80,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: badges.Badge(
                      badgeContent: const CircleAvatar(
                        radius: 8.5,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 6,
                          backgroundColor: AppPallete.successMain,
                        ),
                      ),
                      badgeStyle: const badges.BadgeStyle(
                          badgeColor: Colors.transparent),
                      position:
                          badges.BadgePosition.bottomEnd(end: 0, bottom: 0),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            fit: BoxFit.contain,
                            image: AssetImage(
                                'assets/images/avatar/#Img_Avatar.${index + 1}.jpg'),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: Text(
                      'Yash Nautiyal',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.tertiary,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
