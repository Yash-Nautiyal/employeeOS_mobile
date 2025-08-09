import 'package:employeeos/view/chat/domain/entities/conversation_models.dart';
import 'package:employeeos/view/chat/presentation/widget/chat_nav_header.dart';
import 'package:employeeos/view/chat/presentation/widget/chat_nav_item.dart';
import 'package:employeeos/view/chat/presentation/widget/chat_nav_online.dart';
import 'package:employeeos/view/chat/presentation/widget/chat_nav_pinned.dart';
import 'package:flutter/material.dart';

class ChatNav extends StatefulWidget {
  final ThemeData theme;
  final List<Conversation> conversations;

  final void Function(Conversation) onConversationTap;
  const ChatNav({
    super.key,
    required this.theme,
    required this.conversations,
    required this.onConversationTap,
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
                      padding: const EdgeInsets.symmetric(horizontal: 6)
                          .copyWith(top: 10),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEEECEA),
                        borderRadius: BorderRadius.only(
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
                            tabAlignment: TabAlignment.fill,
                            labelStyle:
                                widget.theme.textTheme.labelLarge?.copyWith(
                              color: widget.theme.colorScheme.tertiary,
                            ),
                            unselectedLabelColor: widget.theme.disabledColor,
                            indicatorSize: TabBarIndicatorSize.label,
                            dividerColor: Colors.transparent,
                            indicator: UnderlineTabIndicator(
                              borderSide: BorderSide(
                                width: 2,
                                color: widget.theme.colorScheme.tertiary,
                              ),
                              insets: const EdgeInsets.symmetric(horizontal: 4),
                            ),
                          ),
                          const SizedBox(
                            height: 12,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEEECEA),
                    ),
                    child: Column(
                      children: [
                        ChatNavPinned(
                          theme: widget.theme,
                          onConversationTap: widget.onConversationTap,
                          items: items,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        ChatNavItem(
                          theme: widget.theme,
                          onConversationTap: widget.onConversationTap,
                          items: items,
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _snapAppbar() {
    final scrollDistance = maxHeight - minHeight;
    if (scrollController.offset > 0 &&
        scrollController.offset < scrollDistance + 120) {
      final double snapOffset = scrollController.offset / scrollDistance;
      Future.microtask(
        () => scrollController.animateTo(snapOffset,
            duration: const Duration(milliseconds: 200), curve: Curves.easeIn),
      );
    }
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget _child;
  _SliverAppBarDelegate(this._child);

  @override
  double get minExtent => 70;
  @override
  double get maxExtent => 70;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _child,
    );
  }

  @override
  bool shouldRebuild(covariant _SliverAppBarDelegate oldDelegate) => false;
}
