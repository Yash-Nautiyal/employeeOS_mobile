import 'package:flutter/material.dart';

class CustomTextButton extends StatelessWidget {
  final Widget child;
  final Function onClick;
  final Color? backgroundColor;
  const CustomTextButton({
    super.key,
    required this.child,
    required this.onClick,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () {},
        style: backgroundColor != null
            ? ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(backgroundColor),
              )
            : null,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: child,
        ));
  }
}
