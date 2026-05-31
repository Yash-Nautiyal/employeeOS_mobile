import 'package:cached_network_image/cached_network_image.dart';
import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;

import '../../../domain/entities/participant.dart' show Participant;

class ChatNavOnline extends StatelessWidget {
  final ThemeData theme;
  final List<Participant> onlineParticipants;

  const ChatNavOnline(
      {super.key, required this.theme, required this.onlineParticipants});

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
          height: 80,
          child: onlineParticipants.isEmpty
              ? Center(
                  child: Text(
                    'No one is online',
                    style: theme.textTheme.bodyMedium,
                  ),
                )
              : ListView.builder(
                  itemCount: onlineParticipants.length,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) => SizedBox(
                    width: 80,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: badges.Badge(
                            badgeContent: CircleAvatar(
                              radius: 8.2,
                              backgroundColor: theme.scaffoldBackgroundColor,
                              child: const CircleAvatar(
                                radius: 6,
                                backgroundColor: AppPallete.successMain,
                              ),
                            ),
                            badgeStyle: const badges.BadgeStyle(
                                badgeColor: Colors.transparent),
                            position: badges.BadgePosition.bottomEnd(
                                end: 0, bottom: 0),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  fit: BoxFit.contain,
                                  image: CachedNetworkImageProvider(
                                    onlineParticipants[index].avatarUrl,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: Text(
                            onlineParticipants[index].name,
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
