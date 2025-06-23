import 'package:employeeos/core/common/actions/date_time_actions.dart'
    show formatRelativeTime;
import 'package:employeeos/core/common/components/custom_textfield.dart';
import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:employeeos/view/chat/domain/entities/chat_models.dart'
    show TextMessage;
import 'package:employeeos/view/chat/domain/entities/conversation_models.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter_svg/flutter_svg.dart';

class ChatNav extends StatelessWidget {
  final ThemeData theme;
  final List<Conversation> conversations;
  final void Function(Conversation) onConversationTap;
  const ChatNav({
    super.key,
    required this.theme,
    required this.conversations,
    required this.onConversationTap,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    final items = List<Conversation>.from(conversations)
      ..sort((a, b) {
        final aTime = a.messages.first.createdAt;
        final bTime = b.messages.first.createdAt;
        return bTime.compareTo(aTime);
      });
    return Scaffold(
      resizeToAvoidBottomInset: false, // Prevent resizing
      extendBody: true,
      body: Container(
        color: theme.scaffoldBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8, left: 5),
                  child: Row(
                    children: [
                      badges.Badge(
                        badgeStyle: const badges.BadgeStyle(
                          badgeColor: AppPallete.primaryMain,
                        ),
                        position:
                            badges.BadgePosition.bottomEnd(bottom: 0, end: 0),
                        child: const CircleAvatar(
                          radius: 23,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: SvgPicture.asset(
                          "assets/icons/arrow/ic-eva_arrow-ios-back-fill.svg",
                          color: theme.disabledColor,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: SvgPicture.asset(
                          "assets/icons/common/solid/ic-solar_user-plus-bold.svg",
                          color: theme.disabledColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomTextfield(
                    controller: controller,
                    keyboardType: TextInputType.text,
                    theme: theme,
                    onchange: (text) => controller.text = text,
                    hintText: "Search Conversation"),
              ),
              Expanded(
                child: ListView.builder(
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
                      child: Container(
                        height: 70,
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            badges.Badge(
                              badgeStyle: const badges.BadgeStyle(
                                badgeColor: AppPallete.primaryMain,
                              ),
                              position: badges.BadgePosition.bottomEnd(
                                  bottom: 0, end: 0),
                              child: CircleAvatar(
                                radius: 23,
                                child: Text(conv.name[0],
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(color: Colors.white)),
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    conv.name,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: theme.colorScheme.tertiary),
                                  ),
                                  Text(snippet,
                                      style: theme.textTheme.bodySmall,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1),
                                ],
                              ),
                            ),
                            Align(
                              alignment:
                                  Alignment.topLeft.add(const Alignment(0, .5)),
                              child:
                                  Text(time, style: theme.textTheme.bodySmall),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
