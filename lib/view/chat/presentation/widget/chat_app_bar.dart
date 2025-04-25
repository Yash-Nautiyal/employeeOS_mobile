import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter_svg/svg.dart';

class ChatAppBar extends StatefulWidget {
  final ThemeData theme;

  const ChatAppBar({
    super.key,
    required this.theme,
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
      padding: const EdgeInsets.all(15).copyWith(right: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: widget.theme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          badges.Badge(
            badgeStyle:
                const badges.BadgeStyle(badgeColor: AppPallete.primaryMain),
            position: badges.BadgePosition.bottomEnd(bottom: 0, end: 0),
            child: const CircleAvatar(
              radius: 20,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Simform",
                style: widget.theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "Online",
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
