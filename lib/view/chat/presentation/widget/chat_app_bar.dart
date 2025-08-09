import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter_svg/svg.dart';

class ChatAppBar extends StatefulWidget {
  final ThemeData theme;
  final String name;
  final String subTitle;
  final String avatar;
  final VoidCallback onBack;
  const ChatAppBar({
    super.key,
    required this.theme,
    required this.name,
    required this.subTitle,
    required this.avatar,
    required this.onBack,
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
    return Container(
      padding: const EdgeInsets.all(15).copyWith(right: 8, left: 0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: widget.theme.dividerColor.withAlpha(100),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => widget.onBack.call(),
            icon: SvgPicture.asset(
              'assets/icons/arrow/ic-eva_arrow-ios-back-fill.svg',
              color: widget.theme.colorScheme.tertiary,
            ),
          ),
          const SizedBox(
            width: 5,
          ),
          badges.Badge(
            badgeStyle:
                const badges.BadgeStyle(badgeColor: AppPallete.primaryMain),
            position: badges.BadgePosition.bottomEnd(bottom: 0, end: 0),
            child: CircleAvatar(
              radius: 20,
              child: Text(widget.avatar),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.name,
                style: widget.theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                widget.subTitle,
                style: widget.theme.textTheme.bodySmall
                    ?.copyWith(color: widget.theme.disabledColor),
              )
            ],
          ),
          const Spacer(),
          IconButton(
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
      ),
    );
  }
}
