import 'dart:async';

import 'package:avatar_stack/animated_avatar_stack.dart';
import 'package:avatar_stack/positions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:employeeos/view/chat/domain/entities/conversation.dart';
import 'package:employeeos/view/chat/presentation/widget/appbar/appbar_seach_field.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter_svg/svg.dart';

import '../../../domain/entities/participant.dart';

class ChatAppBar extends StatefulWidget {
  final ThemeData theme;
  final ParticipantStatus? status;
  final String currentUserId;
  final Conversation? conversation;
  final VoidCallback onBack;
  final bool isNewChat;
  final Function(Participant) onSelectUser;
  final List<Participant> availableUsers;
  final bool isLoadingUsers;

  const ChatAppBar({
    super.key,
    required this.theme,
    this.status,
    required this.onBack,
    this.conversation,
    required this.currentUserId,
    this.isNewChat = false,
    required this.onSelectUser,
    required this.availableUsers,
    this.isLoadingUsers = false,
  });

  @override
  State<ChatAppBar> createState() => _ChatAppBarState();
}

class _ChatAppBarState extends State<ChatAppBar> {
  late bool sidebar;
  Participant? _selectedUser;
  int _loadingDotCount = 0;
  Timer? _loadingTimer;

  @override
  void initState() {
    super.initState();
    sidebar = false;

    if (widget.isLoadingUsers) {
      _startLoadingAnimation();
    }
  }

  @override
  void didUpdateWidget(ChatAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoadingUsers && !oldWidget.isLoadingUsers) {
      _startLoadingAnimation();
    } else if (!widget.isLoadingUsers && oldWidget.isLoadingUsers) {
      _stopLoadingAnimation();
    }
  }

  void _startLoadingAnimation() {
    _loadingTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          _loadingDotCount = (_loadingDotCount + 1) % 4;
        });
      }
    });
  }

  void _stopLoadingAnimation({bool isDisposing = false}) {
    _loadingTimer?.cancel();
    _loadingTimer = null;

    if (!isDisposing && mounted) {
      setState(() {
        _loadingDotCount = 0;
      });
    }
  }

  @override
  void dispose() {
    _stopLoadingAnimation(isDisposing: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final screenWidth = MediaQuery.of(context).size.width;
    final showSearchbar = widget.conversation == null && widget.isNewChat;

    return Container(
      padding: const EdgeInsets.all(10),
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
          if (!showSearchbar) ...[
            IconButton(
              onPressed: () => widget.onBack.call(),
              icon: SvgPicture.asset(
                isPortrait
                    ? 'assets/icons/arrow/ic-eva_arrow-ios-back-fill.svg'
                    : 'assets/icons/common/solid/ic-mingcute_close-line.svg',
                colorFilter: ColorFilter.mode(
                  widget.theme.colorScheme.tertiary,
                  BlendMode.srcIn,
                ),
                width: 18,
              ),
            ),
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
                            CachedNetworkImageProvider(participant.avatarUrl),
                      ],
                    ),
                  )
                : badges.Badge(
                    badgeContent: widget.status?.statusBadge(widget.theme) ??
                        const SizedBox.shrink(),
                    badgeStyle:
                        const badges.BadgeStyle(badgeColor: Colors.transparent),
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
            Expanded(
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
                            .firstWhere((p) => p.id != widget.currentUserId)
                            .name,
                    style: widget.theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.status?.name ?? '',
                    style: widget.theme.textTheme.bodySmall
                        ?.copyWith(color: widget.theme.disabledColor),
                  )
                ],
              ),
            ),
          ] else
            AppBarSeachField(
              isLoadingUsers: widget.isLoadingUsers,
              availableUsers: widget.availableUsers,
              loadingDotCount: _loadingDotCount,
              selectedUser: _selectedUser,
              onChageValue: (value) {
                setState(() {
                  _selectedUser = value;
                });
                widget.onSelectUser(value);
              },
              theme: widget.theme,
            ),
          // if (!showSearchbar) ...[
          //   IconButton(
          //     constraints: const BoxConstraints(
          //       maxWidth: 32,
          //       maxHeight: 32,
          //     ),
          //     onPressed: () {
          //       setState(() {
          //         sidebar = !sidebar;
          //       });
          //     },
          //     icon: SvgPicture.asset(
          //       sidebar
          //           ? 'assets/icons/common/solid/ic-ri_sidebar-unfold-fill.svg'
          //           : 'assets/icons/common/solid/ic-ri_sidebar-fold-fill.svg',
          //       color: AppPallete.grey600,
          //     ),
          //   ),
          //   IconButton(
          //     constraints: const BoxConstraints(
          //       maxWidth: 32,
          //       maxHeight: 32,
          //     ),
          //     onPressed: () {
          //       // TODO: Implement more options menu
          //     },
          //     icon: SvgPicture.asset(
          //       'assets/icons/common/solid/ic-eva_more-vertical-fill.svg',
          //       colorFilter: const ColorFilter.mode(
          //         AppPallete.grey600,
          //         BlendMode.srcIn,
          //       ),
          //     ),
          //   )
          // ]
        ],
      ),
    );
  }
}
