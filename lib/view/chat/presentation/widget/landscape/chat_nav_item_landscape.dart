import 'package:avatar_stack/animated_avatar_stack.dart';
import 'package:avatar_stack/positions.dart';
import 'package:employeeos/core/theme/app_pallete.dart' show AppPallete;
import 'package:employeeos/view/chat/domain/entities/conversation_models.dart'
    show Conversation, ConversationType;
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;

class ChatNavItemLandscape extends StatelessWidget {
  final ThemeData theme;
  final Conversation conv;
  final String currentUserId;
  final bool isExpanded;
  final Animation<double> textAnimation;
  final String snippet;
  final String time;
  final Function onConversationTap;
  const ChatNavItemLandscape({
    super.key,
    required this.theme,
    required this.conv,
    required this.currentUserId,
    required this.isExpanded,
    required this.textAnimation,
    required this.snippet,
    required this.time,
    required this.onConversationTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onConversationTap(conv),
      child: SizedBox(
        height: 47,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              constraints: const BoxConstraints(
                maxWidth: 60,
                maxHeight: 45,
              ),
              child: conv.type == ConversationType.group
                  ? AnimatedAvatarStack(
                      key: ValueKey(theme.brightness),
                      borderColor: theme.brightness == Brightness.dark
                          ? AppPallete.grey800
                          : AppPallete.white,
                      settings: RestrictedPositions(
                        maxCoverage: 0.80,
                        laying: StackLaying.last,
                      ),
                      avatars: [
                        for (var participant in conv.participants)
                          if (participant.id != currentUserId)
                            NetworkImage(participant.avatarUrl),
                      ],
                    )
                  : Padding(
                      padding: EdgeInsets.only(right: isExpanded ? 8.0 : 0),
                      child: badges.Badge(
                        badgeContent: CircleAvatar(
                          radius: 7,
                          backgroundColor: theme.scaffoldBackgroundColor,
                          child: const CircleAvatar(
                            radius: 5,
                            backgroundColor: AppPallete.successMain,
                          ),
                        ),
                        badgeStyle: const badges.BadgeStyle(
                            badgeColor: Colors.transparent),
                        position: badges.BadgePosition.bottomEnd(
                            end: -4.5, bottom: 0),
                        child: CircleAvatar(
                          radius: 27,
                          backgroundImage: NetworkImage(conv.participants
                              .firstWhere((p) => p.id != currentUserId)
                              .avatarUrl),
                        ),
                      ),
                    ),
            ),
            if (isExpanded)
              Expanded(
                child: FadeTransition(
                  opacity: textAnimation,
                  child: IgnorePointer(
                    ignoring: !isExpanded,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  conv.participants
                                      .where((p) => p.id != currentUserId)
                                      .map((p) => p.name)
                                      .join(", "),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurface,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                time,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.dividerColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  snippet,
                                  style: theme.textTheme.bodySmall,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              Badge(
                                padding: const EdgeInsets.all(2),
                                backgroundColor: AppPallete.successMain,
                                label: Text(
                                  '2',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                      color: AppPallete.white,
                                      fontWeight: FontWeight.w700),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
