import 'package:flutter/material.dart';

class UserAccountTab extends StatefulWidget {
  const UserAccountTab({
    super.key,
    required this.theme,
    required this.tabController,
    required this.tabs,
    required this.onTabSelected,
  });

  final ThemeData theme;
  final TabController tabController;
  final List<String> tabs;
  final Function onTabSelected;

  @override
  State<UserAccountTab> createState() => _UserAccountTabState();
}

class _UserAccountTabState extends State<UserAccountTab> {
  final ScrollController _scrollController = ScrollController();
  bool _canScrollLeft = false;
  bool _canScrollRight = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateArrows());
  }

  void _scrollListener() {
    _updateArrows();
  }

  void _updateArrows() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    setState(() {
      _canScrollLeft = currentScroll > 0;
      _canScrollRight = currentScroll < maxScroll;
    });
  }

  void _scrollLeft() {
    _scrollController.animateTo(
      _scrollController.offset - 100,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _scrollRight() {
    _scrollController.animateTo(
      _scrollController.offset + 100,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
          ), // space for arrows
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _scrollController,
            child: TabBar(
              onTap: (value) => widget.onTabSelected(value),
              controller: widget.tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.center,
              labelStyle: widget.theme.textTheme.labelLarge?.copyWith(
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
              tabs: widget.tabs
                  .map(
                    (e) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Tab(text: e),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        if (_canScrollLeft)
          Positioned(
            left: 0,
            child: IconButton(
              style: ButtonStyle(
                maximumSize: const WidgetStatePropertyAll(Size(40, 40)),
                minimumSize: const WidgetStatePropertyAll(Size(20, 20)),
                shape: const WidgetStatePropertyAll(CircleBorder()),
                backgroundColor: WidgetStatePropertyAll(
                  widget.theme.dividerColor.withOpacity(.2),
                ),
              ),
              icon: const Icon(Icons.arrow_left),
              onPressed: _scrollLeft,
            ),
          ),
        if (_canScrollRight)
          Positioned(
            right: 0,
            child: IconButton(
              style: ButtonStyle(
                maximumSize: const WidgetStatePropertyAll(Size(40, 40)),
                minimumSize: const WidgetStatePropertyAll(Size(20, 20)),
                shape: const WidgetStatePropertyAll(CircleBorder()),
                backgroundColor: WidgetStatePropertyAll(
                  widget.theme.dividerColor.withOpacity(.2),
                ),
              ),
              icon: const Icon(Icons.arrow_right),
              onPressed: _scrollRight,
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
