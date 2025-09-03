import 'package:avatar_stack/animated_avatar_stack.dart'
    show AnimatedAvatarStack;
import 'package:avatar_stack/positions.dart';
import 'package:employeeos/core/common/actions/date_time_actions.dart'
    show formatRelativeTime;
import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:employeeos/view/chat/domain/entities/chat_models.dart'
    show TextMessage;
import 'package:employeeos/view/chat/domain/entities/conversation_models.dart'
    show Conversation, ConversationType;
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;

class ChatNavItem extends StatelessWidget {
  final ThemeData theme;
  final String currentUserId;
  final Function onConversationTap;
  final List<Conversation> items;
  const ChatNavItem(
      {super.key,
      required this.theme,
      required this.onConversationTap,
      required this.items,
      required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(right: 15, left: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(35),
        color: theme.scaffoldBackgroundColor,
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.horizontal(
            left: Radius.circular(35), right: Radius.circular(30)),
        child: ListView.separated(
          separatorBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(left: 65.0),
            child: Divider(
              color: theme.dividerColor.withAlpha(100),
            ),
          ),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: items.length,
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            final conv = items[index];
            final lastMsg = conv.messages.first;
            final snippet = lastMsg is TextMessage
                ? lastMsg.text
                : '[${lastMsg.type.name}]';
            final time = formatRelativeTime(lastMsg.createdAt);
            return GestureDetector(
              onTap: () => onConversationTap(conv),
              child: SizedBox(
                height: 80,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    conv.type == ConversationType.group
                        ? SizedBox(
                            width: 60,
                            height: 43,
                            child: AnimatedAvatarStack(
                              key: ValueKey(theme.brightness),
                              borderColor: theme.brightness == Brightness.dark
                                  ? AppPallete.grey800
                                  : AppPallete.grey200,
                              settings: RestrictedPositions(
                                maxCoverage: 0.80,
                              ),
                              avatars: [
                                for (var participant in conv.participants)
                                  if (participant.id != currentUserId)
                                    NetworkImage(participant.avatarUrl),
                              ],
                            ),
                          )
                        : badges.Badge(
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
                                end: -8, bottom: 0),
                            child: CircleAvatar(
                              radius: 27,
                              backgroundImage: NetworkImage(conv.participants
                                  .firstWhere((p) => p.id != currentUserId)
                                  .avatarUrl),
                            ),
                          ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  conv.participants
                                      .where((p) => p.id != currentUserId)
                                      .map((p) => p.name)
                                      .join(", "),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.tertiary),
                                ),
                              ),
                              Text(
                                time,
                                style: theme.textTheme.labelLarge
                                    ?.copyWith(color: theme.dividerColor),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  snippet,
                                  style: theme.textTheme.bodyMedium,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              Badge(
                                backgroundColor: AppPallete.successMain,
                                label: Text(
                                  '2',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                      fontSize: 12, color: AppPallete.white),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
