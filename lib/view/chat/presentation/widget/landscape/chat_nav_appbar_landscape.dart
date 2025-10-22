import 'package:employeeos/core/theme/app_pallete.dart' show AppPallete;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:badges/badges.dart' as badges;
import 'package:sizer/sizer.dart';

class ChatNavAppbarLandscape extends StatelessWidget {
  final ThemeData theme;
  final bool isExpanded;
  final Function onClickExpand;
  final Animation<double> textAnimation;

  const ChatNavAppbarLandscape({
    super.key,
    required this.theme,
    required this.isExpanded,
    required this.onClickExpand,
    required this.textAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.all(5).copyWith(bottom: 10),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Flexible(
            flex: isExpanded ? 8 : 1,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              constraints: BoxConstraints(
                maxWidth: isExpanded ? 250 : 0,
              ),
              child: Row(
                children: [
                  Flexible(
                    child: FadeTransition(
                      opacity: textAnimation,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isExpanded)
                            SizedBox(
                              width: 45,
                              child: badges.Badge(
                                badgeContent: CircleAvatar(
                                  radius: 7,
                                  backgroundColor:
                                      theme.scaffoldBackgroundColor,
                                  child: const CircleAvatar(
                                    radius: 5,
                                    backgroundColor: AppPallete.successMain,
                                  ),
                                ),
                                badgeStyle: const badges.BadgeStyle(
                                    badgeColor: Colors.transparent),
                                position: badges.BadgePosition.bottomEnd(
                                    end: -4.5, bottom: 0),
                                child: const CircleAvatar(),
                              ),
                            ),
                          if (isExpanded) const SizedBox(width: 5),
                          if (isExpanded)
                            Flexible(
                              child: Text(
                                'Yash (You) Yash (You)',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 15.sp,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Flexible(
              child: FadeTransition(
                opacity: textAnimation,
                child: IgnorePointer(
                  ignoring: !isExpanded,
                  child: InkWell(
                    onTap: () {
                      onClickExpand.call();
                    },
                    child: SvgPicture.asset(
                      'assets/icons/common/solid/ic-eva_more-vertical-fill.svg',
                      color: theme.colorScheme.tertiary,
                      width: 20,
                    ),
                  ),
                ),
              ),
            ),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () {
                onClickExpand.call();
              },
              child: AnimatedRotation(
                turns: isExpanded
                    ? 0.5
                    : 0.0, // 180deg when expanded, 0deg when collapsed
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: SvgPicture.asset(
                  'assets/icons/arrow/ic-eva_arrow-ios-forward-fill.svg',
                  color: theme.colorScheme.tertiary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
