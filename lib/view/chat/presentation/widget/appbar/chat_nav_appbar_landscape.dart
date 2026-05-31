import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

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
    final TextEditingController controller = TextEditingController();
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.all(5).copyWith(bottom: 10),
      alignment: Alignment.center,
      padding: EdgeInsets.all(isExpanded ? 10 : 6),
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
                          if (isExpanded) ...[
                            const SizedBox(width: 5),
                            SvgPicture.asset(
                              'assets/icons/ic-eva_search-fill.svg',
                            ),
                            Expanded(
                              child: SizedBox(
                                height: 45,
                                child: TextField(
                                  controller: controller,
                                  keyboardType: TextInputType.text,
                                  onChanged: (value) {},
                                  decoration: InputDecoration(
                                    hintText: "Search Conversation",
                                    hintStyle: theme.textTheme.bodyMedium,
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 10)
                                        .copyWith(bottom: 3),
                                    // focusedBorder: InputBorder.none,
                                  ),
                                ),
                              ),
                            )
                          ]
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // if (isExpanded)
          //   Flexible(
          //     child: FadeTransition(
          //       opacity: textAnimation,
          //       child: IgnorePointer(
          //         ignoring: !isExpanded,
          //         child: InkWell(
          //           onTap: () {
          //             onClickExpand.call();
          //           },
          //           child: SvgPicture.asset(
          //             'assets/icons/common/solid/ic-eva_more-vertical-fill.svg',
          //             color: theme.colorScheme.tertiary,
          //             width: 20,
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: () {
                onClickExpand.call();
              },
              icon: AnimatedRotation(
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
