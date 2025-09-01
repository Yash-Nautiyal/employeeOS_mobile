import 'package:employeeos/view/chat/domain/entities/conversation_models.dart';
import 'package:employeeos/view/chat/presentation/widget/chat_nav_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ChatNavPinned extends StatelessWidget {
  final ThemeData theme;
  final Function onConversationTap;
  final List<Conversation> items;
  final String currentUserId;
  const ChatNavPinned(
      {super.key,
      required this.theme,
      required this.onConversationTap,
      required this.items,
      required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: theme.scaffoldBackgroundColor,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 15),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/common/solid/ic-solar-pin-bold.svg',
                    width: 17,
                    color: theme.colorScheme.tertiary,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    'Pinned Chats',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.tertiary),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ChatNavItem(
                  theme: theme,
                  currentUserId: currentUserId,
                  onConversationTap: (conv) => onConversationTap(conv),
                  items: items.take(2).toList()),
            ),
          ],
        ),
      ),
    );
  }
}
