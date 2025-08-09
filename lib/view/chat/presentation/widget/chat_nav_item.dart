import 'package:employeeos/core/common/actions/date_time_actions.dart'
    show formatRelativeTime;
import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:employeeos/view/chat/domain/entities/chat_models.dart'
    show TextMessage;
import 'package:employeeos/view/chat/domain/entities/conversation_models.dart'
    show Conversation;
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;

class ChatNavItem extends StatelessWidget {
  final ThemeData theme;
  final Function onConversationTap;
  final List<Conversation> items;
  const ChatNavItem(
      {super.key,
      required this.theme,
      required this.onConversationTap,
      required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8).copyWith(right: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: theme.cardColor,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
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
                    badges.Badge(
                      badgeContent: const CircleAvatar(
                        radius: 6.5,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 5,
                          backgroundColor: AppPallete.successMain,
                        ),
                      ),
                      badgeStyle: const badges.BadgeStyle(
                          badgeColor: Colors.transparent),
                      position:
                          badges.BadgePosition.bottomEnd(end: -5, bottom: 0),
                      child: CircleAvatar(
                        radius: 27,
                        child: Text(
                          conv.name[0],
                        ),
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
                                  conv.name,
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
