import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:employeeos/view/chat/domain/entities/conversation_models.dart';
import 'package:employeeos/view/chat/presentation/widget/chat_nav_header.dart';
import 'package:employeeos/view/chat/presentation/widget/chat_nav_item.dart';
import 'package:employeeos/view/chat/presentation/widget/chat_nav_online.dart';
import 'package:employeeos/view/chat/presentation/widget/chat_nav_pinned.dart';
import 'package:flutter/material.dart';

class ChatNav extends StatefulWidget {
  final ThemeData theme;
  final String currentUserId;
  final List<Conversation> conversations;

  final void Function(Conversation) onConversationTap;
  const ChatNav({
    super.key,
    required this.theme,
    required this.conversations,
    required this.onConversationTap,
    required this.currentUserId,
  });

  @override
  State<ChatNav> createState() => _ChatNavState();
}

class _ChatNavState extends State<ChatNav> with TickerProviderStateMixin {
  late TabController tabController;
  late AnimationController _searchController;
  final FocusNode _searchFocusNode = FocusNode();
  final scrollController = ScrollController();
  final controller = TextEditingController();
  bool _isSearchExpanded = false;

  @override
  void initState() {
    super.initState();
    _searchController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();

    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchExpanded = true;
      _searchController.forward();
      _searchFocusNode.requestFocus();
    });
  }

  void _closeAllFields() {
    if (_isSearchExpanded) {
      _searchController.reverse();
      controller.clear();
    }
    setState(() {
      _isSearchExpanded = false;
    });
  }

  double get maxHeight => 30 + MediaQuery.of(context).padding.top;

  double get minHeight => 20 + MediaQuery.of(context).padding.top;

  @override
  Widget build(BuildContext context) {
    final items = List<Conversation>.from(widget.conversations)
      ..sort((a, b) {
        final aTime = a.messages.first.createdAt;
        final bTime = b.messages.first.createdAt;
        return bTime.compareTo(aTime);
      });
    return Column(
      children: [
        ChatNavHeader(
            theme: widget.theme,
            toggleSearch: _toggleSearch,
            isSearchExpanded: _isSearchExpanded,
            closeAllFields: _closeAllFields,
            controller: controller),
        Expanded(
          child: NotificationListener<ScrollEndNotification>(
            onNotification: (_) {
              _snapAppbar();
              return false;
            },
            child: CustomScrollView(
              physics: const ClampingScrollPhysics(),
              controller: scrollController,
              slivers: [
                SliverAppBar(
                  primary: false,
                  automaticallyImplyLeading: false,
                  expandedHeight: 130,
                  toolbarHeight: 0,
                  collapsedHeight: 0,
                  scrolledUnderElevation: 0,
                  elevation: 0,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                      background: ChatNavOnline(theme: widget.theme)),
                ),
                SliverPersistentHeader(
                  floating: true,
                  pinned: true,
                  delegate: _SliverAppBarDelegate(
                    Container(
                      color: widget.theme.brightness == Brightness.dark
                          ? AppPallete.grey900
                          : AppPallete.white,
                      child: Container(
                        margin: EdgeInsets.zero, // Add this
                        key: ValueKey(widget.theme.brightness),
                        padding: const EdgeInsets.symmetric(horizontal: 6)
                            .copyWith(top: 10, bottom: 10),
                        decoration: BoxDecoration(
                          color: widget.theme.brightness == Brightness.dark
                              ? AppPallete.grey800
                              : const Color(0xFFEEECEA),
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(40),
                            topLeft: Radius.circular(40),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TabBar(
                              controller: tabController,
                              tabs: const [
                                Tab(
                                  text: 'All',
                                ),
                                Tab(
                                  text: 'Unread',
                                ),
                                Tab(
                                  text: 'Groups',
                                ),
                                Tab(
                                  text: 'Contacts',
                                ),
                              ],
                              tabAlignment: TabAlignment.center,
                              labelStyle:
                                  widget.theme.textTheme.labelLarge?.copyWith(
                                color: widget.theme.colorScheme.onSurface,
                              ),
                              unselectedLabelColor: widget.theme.disabledColor,
                              indicatorSize: TabBarIndicatorSize.label,
                              dividerColor: Colors.transparent,
                              indicator: UnderlineTabIndicator(
                                borderSide: BorderSide(
                                  width: 2,
                                  color: widget.theme.colorScheme.onSurface,
                                ),
                                insets:
                                    const EdgeInsets.symmetric(horizontal: 4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    widget.theme,
                  ),
                ),
                // Replace the SliverList section with:
                SliverToBoxAdapter(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height * .7),
                    child: Container(
                      margin: EdgeInsets.zero, // Add this
                      padding: const EdgeInsets.symmetric(horizontal: 10)
                          .copyWith(top: 10),
                      decoration: BoxDecoration(
                        color: widget.theme.brightness == Brightness.dark
                            ? AppPallete.grey800
                            : const Color(0xFFEEECEA),
                      ),
                      child: Column(
                        children: [
                          ChatNavPinned(
                            currentUserId: widget.currentUserId,
                            theme: widget.theme,
                            onConversationTap: widget.onConversationTap,
                            items: items,
                          ),
                          const SizedBox(height: 10),
                          ChatNavItem(
                            currentUserId: widget.currentUserId,
                            theme: widget.theme,
                            onConversationTap: widget.onConversationTap,
                            items: items,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Container(
                    color: widget.theme.brightness == Brightness.dark
                        ? AppPallete.grey800
                        : const Color(0xFFEEECEA),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _snapAppbar() {
    const double expandedHeight = 130.0; // SliverAppBar expandedHeight

    // If scroll is in the middle of the expanded area, snap to closest position
    if (scrollController.offset > 0 &&
        scrollController.offset < expandedHeight) {
      // Determine whether to snap up (0) or down (expandedHeight)
      final double snapOffset =
          scrollController.offset < expandedHeight / 1.5 ? 0.0 : expandedHeight;

      Future.microtask(
        () => scrollController.animateTo(
          snapOffset,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        ),
      );
    }
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget _child;
  final ThemeData theme; // Add theme parameter

  _SliverAppBarDelegate(this._child, this.theme);

  @override
  double get minExtent => 68;
  @override
  double get maxExtent => 68;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return _child;
  }

  @override
  bool shouldRebuild(covariant _SliverAppBarDelegate oldDelegate) {
    print(oldDelegate.theme.brightness);
    return oldDelegate.theme.brightness != theme.brightness;
  }
}
