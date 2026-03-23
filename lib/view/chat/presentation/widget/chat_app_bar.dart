import 'package:avatar_stack/animated_avatar_stack.dart';
import 'package:avatar_stack/positions.dart';
import 'package:employeeos/core/common/components/custom_textfield.dart';
import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:employeeos/view/chat/domain/entities/conversation_models.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter_svg/svg.dart';

class ChatAppBar extends StatefulWidget {
  final ThemeData theme;
  final String subTitle;
  final String currentUserId;
  final Conversation? conversation;
  final VoidCallback onBack;
  const ChatAppBar({
    super.key,
    required this.theme,
    required this.subTitle,
    required this.onBack,
    this.conversation,
    required this.currentUserId,
  });

  @override
  State<ChatAppBar> createState() => _ChatAppBarState();
}

class _ChatAppBarState extends State<ChatAppBar> {
  late bool sidebar;

  @override
  void initState() {
    super.initState();
    sidebar = false;
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
        padding: const EdgeInsets.all(10).copyWith(right: 8, left: 0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: widget.theme.dividerColor.withAlpha(100),
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            if (widget.conversation != null)
              IconButton(
                onPressed: () => widget.onBack.call(),
                icon: SvgPicture.asset(
                  isPortrait
                      ? 'assets/icons/arrow/ic-eva_arrow-ios-back-fill.svg'
                      : 'assets/icons/common/solid/ic-mingcute_close-line.svg',
                  color: widget.theme.colorScheme.onSurface,
                  width: 18,
                ),
              ),
            if (widget.conversation != null)
              widget.conversation!.type == ConversationType.group
                  ? Container(
                      constraints: const BoxConstraints(maxWidth: 90),
                      width: screenWidth * 0.3,
                      height: 43,
                      child: AnimatedAvatarStack(
                        settings: RestrictedPositions(),
                        avatars: [
                          for (var participant
                              in widget.conversation!.participants)
                            if (participant.id != widget.currentUserId)
                              NetworkImage(participant.avatarUrl),
                        ],
                      ),
                    )
                  : badges.Badge(
                      badgeContent: CircleAvatar(
                        radius: 7,
                        backgroundColor: widget.theme.scaffoldBackgroundColor,
                        child: const CircleAvatar(
                          radius: 5,
                          backgroundColor: AppPallete.successMain,
                        ),
                      ),
                      badgeStyle: const badges.BadgeStyle(
                          badgeColor: Colors.transparent),
                      position:
                          badges.BadgePosition.bottomEnd(end: -10, bottom: -1),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(widget
                            .conversation!.participants
                            .firstWhere((p) => p.id != widget.currentUserId)
                            .avatarUrl),
                      ),
                    ),
            const SizedBox(width: 10),
            widget.conversation != null
                ? Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.conversation!.type == ConversationType.group
                              ? widget.conversation!.participants
                                  .where((p) => p.id != widget.currentUserId)
                                  .map((p) => p.name)
                                  .join(", ")
                              : widget.conversation!.participants
                                  .firstWhere(
                                      (p) => p.id == widget.currentUserId)
                                  .name,
                          style: widget.theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          widget.subTitle,
                          style: widget.theme.textTheme.bodySmall
                              ?.copyWith(color: widget.theme.disabledColor),
                        )
                      ],
                    ),
                  )
                : Flexible(
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 200),
                      child: CustomTextfield(
                          controller: TextEditingController(),
                          keyboardType: TextInputType.text,
                          theme: widget.theme,
                          onchange: (value) {},
                          hintText: "Search"),
                    ),
                  ),
            if (widget.conversation != null)
              IconButton(
                constraints: const BoxConstraints(
                  maxWidth: 32,
                  maxHeight: 32,
                ),
                onPressed: () {
                  setState(() {
                    sidebar = !sidebar;
                  });
                },
                icon: SvgPicture.asset(
                  sidebar
                      ? 'assets/icons/common/solid/ic-ri_sidebar-unfold-fill.svg'
                      : 'assets/icons/common/solid/ic-ri_sidebar-fold-fill.svg',
                  color: AppPallete.grey600,
                ),
              ),
            if (widget.conversation != null)
              IconButton(
                constraints: const BoxConstraints(
                  maxWidth: 32,
                  maxHeight: 32,
                ),
                onPressed: () {},
                icon: SvgPicture.asset(
                  'assets/icons/common/solid/ic-eva_more-vertical-fill.svg',
                  color: AppPallete.grey600,
                ),
              )
          ],
        ));
  }
}
