import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class MenuItem extends StatefulWidget {
  final String icon;
  final String title;
  final ThemeData theme;
  final String selectedItem;
  final Function(String) onSelected;
  final List<String> submenuItems;

  const MenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.theme,
    this.submenuItems = const [],
    required this.selectedItem,
    required this.onSelected,
  });

  @override
  State<MenuItem> createState() => _MenuItemState();
}

class _MenuItemState extends State<MenuItem>
    with SingleTickerProviderStateMixin {
  late bool openDropDown = false;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    openDropDown = widget.submenuItems.contains(widget.selectedItem);

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Initialize slide animation
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    // Set initial animation state
    if (openDropDown) {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isParentSelected = widget.submenuItems.contains(widget.selectedItem);
    bool isSelected = widget.selectedItem == widget.title || isParentSelected;

    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Parent Tile
          Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? widget.theme.colorScheme.primary.withAlpha(30)
                  : openDropDown
                      ? widget.theme.hoverColor
                      : Colors.transparent,
              borderRadius: const BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            child: ListTile(
              dense: true,
              trailing: widget.submenuItems.isNotEmpty
                  ? AnimatedRotation(
                      turns: openDropDown ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: isSelected
                            ? widget.theme.colorScheme.primaryContainer
                            : widget.theme.disabledColor,
                      ),
                    )
                  : null,
              selected: isSelected,
              leading: SvgPicture.asset(
                widget.icon,
                width: 22,
                color: isSelected
                    ? widget.theme.colorScheme.primaryContainer
                    : widget.theme.disabledColor,
              ),
              title: Text(
                widget.title,
                style: widget.theme.textTheme.labelLarge?.copyWith(
                  fontSize: 15,
                  color: isSelected
                      ? widget.theme.colorScheme.primaryContainer
                      : widget.theme.disabledColor,
                ),
              ),
              onTap: () {
                if (widget.submenuItems.isEmpty) {
                  widget.onSelected(widget.title);
                } else {
                  setState(() {
                    openDropDown = !openDropDown;
                    if (openDropDown) {
                      _animationController.forward();
                    } else {
                      _animationController.reverse();
                    }
                  });
                }
              },
            ),
          ),

          // Animated Submenu Container
          SizeTransition(
            sizeFactor: _slideAnimation,
            axisAlignment: -1.0, // Align to top
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -0.2),
                end: Offset.zero,
              ).animate(_slideAnimation),
              child: FadeTransition(
                opacity: _slideAnimation,
                child: Column(
                  children: widget.submenuItems.map((item) {
                    bool isSubmenuSelected = widget.selectedItem == item;
                    int itemIndex = widget.submenuItems.indexOf(item);
                    bool isLastItem =
                        itemIndex == widget.submenuItems.length - 1;
                    return SizedBox(
                      child: Row(
                        children: [
                          CustomPaint(
                            painter: SubMenuLinePainter(
                              theme: widget.theme,
                              hasSubmenuItems: widget.submenuItems.isNotEmpty,
                              isLastItem: isLastItem,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 50.0, top: 5),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSubmenuSelected
                                      ? widget.theme.hoverColor
                                      : Colors.transparent,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                child: ListTile(
                                  dense: true,
                                  minTileHeight: 0,
                                  title: Text(
                                    item,
                                    style: widget.theme.textTheme.labelLarge
                                        ?.copyWith(
                                      fontSize: 14,
                                      color: isSubmenuSelected
                                          ? widget.theme.colorScheme.tertiary
                                          : widget.theme.disabledColor,
                                    ),
                                  ),
                                  onTap: () {
                                    widget.onSelected(item);
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SubMenuLinePainter extends CustomPainter {
  final ThemeData theme;
  final bool hasSubmenuItems;
  final bool isLastItem;

  SubMenuLinePainter({
    required this.theme,
    required this.hasSubmenuItems,
    this.isLastItem = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!hasSubmenuItems) return;

    final paint = Paint()
      ..color = theme.hoverColor
      ..strokeWidth = 2.6
      ..style = PaintingStyle.stroke;

    // Draw vertical line
    const startPoint = Offset(35, -23);
    const endPoint = Offset(35, -10);

    // Draw horizontal line connecting to first submenu item
    const horizontalStartPoint = startPoint;
    const horizontalEndPoint = Offset(35, -10);
    canvas.drawLine(horizontalStartPoint, horizontalEndPoint, paint);

    // Draw curved line at the end
    final curvePath = Path()
      ..moveTo(endPoint.dx, endPoint.dy)
      ..quadraticBezierTo(
        endPoint.dx + 0, // Control point x
        endPoint.dy + 15, // Control point y
        endPoint.dx + 20, // End point x
        endPoint.dy + 14, // End point y
      );
    canvas.drawPath(curvePath, paint);

    // Only draw the final vertical line if it's not the last item
    if (!isLastItem) {
      final verticalLineStart = Offset(35, endPoint.dy + 0);
      final verticalLineEnd = Offset(35, endPoint.dy + 32);
      canvas.drawLine(verticalLineStart, verticalLineEnd, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
