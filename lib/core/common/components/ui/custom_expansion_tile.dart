import 'package:flutter/material.dart';

/// A custom expansion tile with smooth open/close animations and optional
/// trailing icon with rotation animation. Does not use [ExpansionTile].
class CustomExpansionTile extends StatefulWidget {
  const CustomExpansionTile({
    super.key,
    required this.title,
    required this.children,
    this.trailing,
    this.initiallyExpanded = false,
    this.duration = const Duration(milliseconds: 250),
    this.curve = Curves.easeInOut,
    this.tilePadding,
    this.childrenPadding,
    this.backgroundColor,
    this.collapsedBackgroundColor,
  });

  /// The header widget (e.g. title text). Tapping it toggles expansion.
  final Widget title;

  /// Content shown when expanded. Height is animated.
  final List<Widget> children;

  /// Optional trailing widget (e.g. chevron). If provided, it rotates
  /// 180° when expanding/collapsing. If null, no trailing is shown.
  final Widget? trailing;

  /// Whether the tile is expanded on first build.
  final bool initiallyExpanded;

  /// Duration for both the panel and the icon rotation.
  final Duration duration;

  /// Curve for open/close and icon rotation.
  final Curve curve;

  /// Padding around the title row.
  final EdgeInsetsGeometry? tilePadding;

  /// Padding around the [children] when expanded.
  final EdgeInsetsGeometry? childrenPadding;

  /// Background color of the title row when expanded.
  final Color? backgroundColor;

  /// Background color of the title row when collapsed.
  final Color? collapsedBackgroundColor;

  @override
  State<CustomExpansionTile> createState() => _CustomExpansionTileState();
}

class _CustomExpansionTileState extends State<CustomExpansionTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _sizeFactor;
  late Animation<double> _iconTurns;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _sizeFactor = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );
    _iconTurns = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );
    if (widget.initiallyExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_controller.isCompleted) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final showTrailing = widget.trailing != null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final color = _controller.value > 0.5
                ? (widget.backgroundColor ?? Colors.transparent)
                : (widget.collapsedBackgroundColor ?? Colors.transparent);
            return Material(
              color: color,
              child: InkWell(
                onTap: _toggle,
                child: Padding(
                  padding: widget.tilePadding ?? EdgeInsets.zero,
                  child: Row(
                    children: [
                      Expanded(child: widget.title),
                      if (showTrailing)
                        RotationTransition(
                          turns: _iconTurns,
                          child: widget.trailing,
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        ClipRect(
          child: SizeTransition(
            sizeFactor: _sizeFactor,
            axisAlignment: -1,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.childrenPadding != null)
                  Padding(
                    padding: widget.childrenPadding!,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: widget.children,
                    ),
                  )
                else
                  ...widget.children,
              ],
            ),
          ),
        ),
      ],
    );
  }
}
