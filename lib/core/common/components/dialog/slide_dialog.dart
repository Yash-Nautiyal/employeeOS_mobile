// ignore_for_file: deprecated_member_use

import 'dart:ui';

import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';

class SlideDialog extends StatefulWidget {
  final ThemeData theme;
  final Widget child;
  final String title;
  final VoidCallback? onRefresh;

  const SlideDialog({
    super.key,
    required this.theme,
    required this.child,
    required this.title,
    this.onRefresh,
  });

  @override
  State<SlideDialog> createState() => _SlideDialogState();
}

class _SlideDialogState extends State<SlideDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _closeDialog() async {
    await _animationController.reverse();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final wideScreen = MediaQuery.of(context).size.width > 700;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final isWideScreen = !isPortrait || wideScreen;
    final screenWidth = MediaQuery.of(context).size.width;
    return Material(
      type: MaterialType.transparency,
      child: WillPopScope(
        onWillPop: () async {
          await _closeDialog();
          return false;
        },
        child: Stack(
          children: [
            GestureDetector(
              onTap: _closeDialog,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: Colors.transparent,
              ),
            ),
            Positioned(
              right: 0,
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  width: isWideScreen ? screenWidth * 0.65 : screenWidth * 0.85,
                  height: MediaQuery.of(context).size.height,
                  child: ClipRRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                            gradient:
                                Theme.of(context).brightness == Brightness.dark
                                    ? AppPallete.darkBackgroundGradient
                                    : AppPallete.lightBackgroundGradient),
                        child: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ).copyWith(top: 10, bottom: 10),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      widget.title,
                                      style: widget.theme.textTheme.titleLarge,
                                    ),
                                    const Spacer(),
                                    if (widget.onRefresh != null)
                                      IconButton(
                                        onPressed: widget.onRefresh,
                                        icon: Icon(
                                          Icons.refresh,
                                          color: widget.theme.disabledColor,
                                        ),
                                      ),
                                    IconButton(
                                      onPressed: _closeDialog,
                                      icon: Icon(
                                        Icons.close,
                                        color: widget.theme.disabledColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Expanded(child: widget.child),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
