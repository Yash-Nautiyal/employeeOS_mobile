import 'package:employeeos/core/common/actions/date_time_actions.dart'
    show formatRelativeTime;
import 'package:employeeos/core/common/components/ui/custom_divider.dart';
import 'package:employeeos/view/chat/domain/entities/chat_models.dart'
    show TextMessage;
import 'package:employeeos/view/chat/domain/entities/conversation_models.dart'
    show Conversation;
import 'package:employeeos/view/chat/presentation/pages/thread_page.dart';
import 'package:employeeos/view/chat/presentation/widget/landscape/chat_nav_appbar_landscape.dart';
import 'package:employeeos/view/chat/presentation/widget/landscape/chat_nav_item_landscape.dart';
import 'package:flutter/material.dart';

class ThreadPageLandscape extends StatefulWidget {
  final Conversation? selectedConversation;
  final String currentUserId;
  final List<Conversation> conversations;
  final Function onConversationTap;
  const ThreadPageLandscape({
    super.key,
    this.selectedConversation,
    required this.currentUserId,
    required this.conversations,
    required this.onConversationTap,
  });

  @override
  State<ThreadPageLandscape> createState() => _ThreadPageLandscapeState();
}

class _ThreadPageLandscapeState extends State<ThreadPageLandscape>
    with TickerProviderStateMixin {
  late AnimationController textAnimationController;
  late Animation<double> textAnimation;
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    textAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      animationBehavior: AnimationBehavior.preserve,
    );

    textAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: textAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    textAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(50)),
            child: AnimatedContainer(
              constraints: const BoxConstraints(
                maxWidth: 350,
                minWidth: 80,
              ),
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(50),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              width: isExpanded ? screenWidth * 0.35 : screenWidth * 0.05,
              child: Column(
                children: [
                  ChatNavAppbarLandscape(
                    theme: theme,
                    isExpanded: isExpanded,
                    textAnimation: textAnimation,
                    onClickExpand: () async {
                      if (isExpanded) {
                        // CLOSING: fade text out first
                        await textAnimationController.reverse();
                        if (!mounted) return;
                        setState(() {
                          isExpanded = false; // now collapse the container
                        });
                      } else {
                        // OPENING: expand container first
                        setState(() {
                          isExpanded = true;
                        });
                        // wait for the width animation (matches your AnimatedContainer duration)
                        await Future.delayed(const Duration(milliseconds: 200));
                        if (!mounted) return;
                        textAnimationController.forward(); // then fade text in
                      }
                    },
                  ),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: widget.conversations.length,
                      separatorBuilder: (context, index) => Padding(
                        padding: EdgeInsets.symmetric(
                                vertical: isExpanded ? 9.0 : 7.0)
                            .copyWith(left: 7),
                        child: CustomDivider(
                          color: theme.dividerColor,
                        ),
                      ),
                      itemBuilder: (context, index) {
                        final conv = widget.conversations[index];
                        final lastMsg = conv.messages.first;
                        final snippet = lastMsg is TextMessage
                            ? lastMsg.text
                            : '[${lastMsg.type.name}]';
                        final time = formatRelativeTime(lastMsg.createdAt);
                        return ChatNavItemLandscape(
                          theme: theme,
                          conv: conv,
                          currentUserId: widget.currentUserId,
                          isExpanded: isExpanded,
                          textAnimation: textAnimation,
                          snippet: snippet,
                          time: time,
                          onConversationTap: (conv) =>
                              widget.onConversationTap(conv),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Flexible(
          child: ThreadPage(
            selectedConversation: widget.selectedConversation,
            onConversationTap: widget.onConversationTap,
          ),
        ),
      ],
    );
  }
}
