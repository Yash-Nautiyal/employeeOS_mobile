import 'package:flutter/material.dart';

class CustomToggleButton extends StatefulWidget {
  final List<String> values;
  final ValueChanged<int> onToggle;
  final ThemeData theme;
  final double? width;
  final double height;
  final int initialIndex;

  const CustomToggleButton({
    super.key,
    required this.values,
    required this.onToggle,
    required this.theme,
    this.width,
    this.height = 40,
    this.initialIndex = 0,
  }) : assert(
          values.length == 2,
          'AnimatedToggleButton only supports two values',
        );

  @override
  State<CustomToggleButton> createState() => _CustomToggleButtonState();
}

class _CustomToggleButtonState extends State<CustomToggleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  // ignore: unused_field
  late Animation<double> _animation;
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (_selectedIndex == 1) {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onToggle(int index) {
    if (index == _selectedIndex) return;
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        _animationController.reverse();
      } else {
        _animationController.forward();
      }
      widget.onToggle(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 0),
      decoration: BoxDecoration(
        color: widget.theme.colorScheme.surfaceContainer
            .withAlpha(widget.theme.brightness == Brightness.light ? 200 : 120),
      ),
      child: widget.width != null
          ? _buildToggleContent(widget.width!)
          : LayoutBuilder(
              builder: (context, constraints) {
                return _buildToggleContent(constraints.maxWidth);
              },
            ),
    );
  }

  Widget _buildToggleContent(double width) {
    return Stack(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: width / widget.values.length,
          height: widget.height,
          margin: EdgeInsets.only(
              left: _selectedIndex == 0 ? 0 : width / widget.values.length),
          decoration: BoxDecoration(
              color: widget.theme.brightness == Brightness.dark
                  ? const Color.fromARGB(255, 20, 19, 19)
                  : Colors.white,
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: widget.theme.shadowColor,
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 1),
                )
              ]),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            widget.values.length,
            (index) => InkWell(
              onTap: () => _onToggle(index),
              child: Container(
                width: width / widget.values.length,
                height: widget.height,
                alignment: Alignment.center,
                child: Text(
                  widget.values[index],
                  style: widget.theme.textTheme.bodySmall?.copyWith(
                    color: _selectedIndex == index
                        ? widget.theme.colorScheme.tertiary
                        : widget.theme.disabledColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
