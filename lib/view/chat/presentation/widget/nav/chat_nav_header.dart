import 'package:employeeos/core/common/components/popup/popup.dart';
import 'package:employeeos/core/common/components/popup/responsive_popup_item.dart';
import 'package:employeeos/core/common/components/ui/custom_textfield.dart';
import 'package:employeeos/core/routing/app_routes.dart';
import 'package:employeeos/core/theme/app_pallete.dart' show AppPallete;
import 'package:employeeos/view/chat/domain/entities/conversation.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter_svg/svg.dart';

import '../../../../../core/index.dart' show ResponsivePopupController;

class ChatNavHeader extends StatelessWidget implements PreferredSizeWidget {
  final ThemeData theme;
  final VoidCallback toggleSearch;
  final VoidCallback closeAllFields;
  final bool isSearchExpanded;
  final String currentUserId;
  final TextEditingController controller;
  final VoidCallback onNewChatLandscape;
  final List<Conversation> conversations;

  @override
  Size get preferredSize => const Size.fromHeight(55);

  const ChatNavHeader({
    super.key,
    required this.theme,
    required this.toggleSearch,
    required this.isSearchExpanded,
    required this.closeAllFields,
    required this.currentUserId,
    required this.controller,
    required this.onNewChatLandscape,
    required this.conversations,
  });

  @override
  Widget build(BuildContext context) {
    final GlobalKey popupAnchorKey = GlobalKey();
    final LayerLink layerLink = LayerLink();
    final ResponsivePopupController popupController =
        ResponsivePopupController();

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
                Popup(
                  layerLink: layerLink,
                  popupAnchorKey: popupAnchorKey,
                  popupController: popupController,
                  manualOffset: const Offset(-5, 0),
                  arrowOffset: .9,
                  arrowColor: theme.brightness == Brightness.dark
                      ? AppPallete.darkBackgroundGradient.colors[3]
                      : AppPallete.lightBackgroundGradient.colors[3],
                  icon: SvgPicture.asset(
                    'assets/icons/common/solid/ic-mingcute_add-line.svg',
                    colorFilter:
                        ColorFilter.mode(theme.disabledColor, BlendMode.srcIn),
                  ),
                  items: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: ResponsivePopupItem(
                          svgIcon:
                              "assets/icons/common/solid/ic-solar_user-plus-bold.svg",
                          title: 'New Chat',
                          onTap: () {
                            // --- NEW CHAT ROUTING LOGIC ---
                            final isPortrait =
                                MediaQuery.of(context).orientation ==
                                    Orientation.portrait;

                            if (isPortrait) {
                              AppChatThreadRoute(
                                conversationId: 'new',
                                $extra: ChatThreadRouteExtra(
                                  conversation: null,
                                  conversations: conversations,
                                  currentUserId: currentUserId,
                                ),
                              ).push(context);
                            } else {
                              // In landscape, just tell the BLoC to clear the selection.
                              // The right panel will instantly render the New Chat UI.
                              onNewChatLandscape.call();
                            }
                          }),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0)
                          .copyWith(top: 5.0),
                      child: ResponsivePopupItem(
                          svgIcon:
                              'assets/icons/common/solid/ic-mingcute-group-3-fill.svg',
                          title: 'New Group',
                          onTap: () {
                            // TODO: Implement new group functionality
                          }),
                    ),
                  ],
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
