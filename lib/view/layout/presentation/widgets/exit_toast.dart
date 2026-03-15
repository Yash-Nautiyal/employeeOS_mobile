import 'package:flutter/material.dart';

/// A floating toast with explicit enter (slide up + fade in) and exit
/// (slide down + fade out) animations. Used for "Press back again to exit".
class ExitToast extends StatefulWidget {
  final String message;
  final Duration displayDuration;
  final VoidCallback onDismissed;

  const ExitToast({
    super.key,
    required this.message,
    this.displayDuration = const Duration(seconds: 2),
    required this.onDismissed,
  });

  @override
  State<ExitToast> createState() => _ExitToastState();
}

class _ExitToastState extends State<ExitToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();

    Future.delayed(widget.displayDuration, () {
      if (!mounted) return;
      _controller.reverse().then((_) {
        if (mounted) widget.onDismissed();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final padding = MediaQuery.of(context).padding;

    return Positioned(
      left: 16,
      right: 16,
      bottom: padding.bottom + 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: theme.colorScheme.inverseSurface,
            borderRadius: BorderRadius.circular(10),
            elevation: 6,
            shadowColor: Colors.black26,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Text(
                widget.message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onInverseSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
