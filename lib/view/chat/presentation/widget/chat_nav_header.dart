import 'package:employeeos/core/common/components/custom_textfield.dart';
import 'package:employeeos/core/theme/app_pallete.dart' show AppPallete;
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter_svg/svg.dart';

class ChatNavHeader extends StatelessWidget implements PreferredSizeWidget {
  final ThemeData theme;
  final VoidCallback toggleSearch;
  final VoidCallback closeAllFields;
  final bool isSearchExpanded;
  final TextEditingController controller;

  @override
  Size get preferredSize => const Size.fromHeight(55);

  const ChatNavHeader(
      {super.key,
      required this.theme,
      required this.toggleSearch,
      required this.isSearchExpanded,
      required this.closeAllFields,
      required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Chat',
            style: theme.textTheme.displaySmall,
          ),
          const SizedBox(
            height: 10,
          ),
          Flexible(
            child: Row(
              children: [
                badges.Badge(
                  badgeContent: CircleAvatar(
                    radius: 6.7,
                    backgroundColor: theme.scaffoldBackgroundColor,
                    child: const CircleAvatar(
                      radius: 5,
                      backgroundColor: AppPallete.successMain,
                    ),
                  ),
                  badgeStyle:
                      const badges.BadgeStyle(badgeColor: Colors.transparent),
                  position: badges.BadgePosition.bottomEnd(end: -7, bottom: -2),
                  child: const CircleAvatar(
                    radius: 23,
                  ),
                ),
                const SizedBox(width: 10),
                const Spacer(),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SizeTransition(
                        sizeFactor: animation,
                        axis: Axis.horizontal,
                        child: child,
                      ),
                    );
                  },
                  child: isSearchExpanded
                      ? Container(
                          key: const ValueKey('search-field'),
                          height:
                              55, // <-- Increase height to fit floating label
                          alignment: Alignment.center,
                          child: _buildSearchField(),
                        )
                      : GestureDetector(
                          onTap: toggleSearch.call,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: theme.brightness == Brightness.dark
                                  ? AppPallete.grey500.withAlpha(70)
                                  : const Color.fromARGB(119, 238, 236, 234),
                              shape: BoxShape.circle,
                            ),
                            key: const ValueKey('search-icon'),
                            child: SvgPicture.asset(
                              'assets/icons/ic-eva_search-fill.svg',
                              color: theme.disabledColor,
                            ),
                          ),
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
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      key: const ValueKey('search-field'),
      constraints: const BoxConstraints(maxWidth: 210),
      child: CustomTextfield(
        controller: controller,
        keyboardType: TextInputType.text,
        theme: theme,
        fontSize: 17,
        isSearchField: true,
        onchange: (text) => controller.text = text,
        hintText: "Search Conversation",
        close: true,
        onClose: () => closeAllFields.call(),
      ),
    );
  }
}
