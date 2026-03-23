import 'dart:ui';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';

class ChatMessageReactionsOverlay extends StatefulWidget {
  const ChatMessageReactionsOverlay({
    super.key,
    required this.anchor,
    required this.bubbleWidth,
    required this.isMe,
    required this.bubble,
    required this.onPick,
    required this.onProgress,
    required this.onRequestClose,
  });

  final LayerLink anchor;
  final double bubbleWidth;
  final bool isMe;
  final Widget bubble;
  final void Function(String emoji) onPick;
  final void Function(double v) onProgress; // reports 0..1 progress

  final VoidCallback onRequestClose;

  @override
  State<ChatMessageReactionsOverlay> createState() =>
      _ChatMessageReactionsOverlayState();
}

class _ChatMessageReactionsOverlayState
    extends State<ChatMessageReactionsOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
    reverseDuration: const Duration(milliseconds: 160),
  );
  late final Animation<double> _t = CurvedAnimation(
    parent: _anim,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  )..addListener(() {
      widget.onProgress(_t.value); // drive ghosting outside
    });

  @override
  void initState() {
    super.initState();
    _anim.forward();
  }

  Future<void> _close() async {
    await _anim.reverse(); // fly back
    if (mounted) widget.onRequestClose();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void showEmojiBottomSheet({
    required ThemeData theme,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          height: 310,
          child: EmojiPicker(
            config: Config(
              height: 256,
              checkPlatformCompatibility: true,
              emojiViewConfig: EmojiViewConfig(
                backgroundColor: theme.colorScheme.surface,
                emojiSizeMax: 28 *
                    (foundation.defaultTargetPlatform == TargetPlatform.iOS
                        ? 1.20
                        : 1.0),
              ),
              viewOrderConfig: const ViewOrderConfig(
                top: EmojiPickerItem.searchBar,
                middle: EmojiPickerItem.emojiView,
                bottom: EmojiPickerItem.categoryBar,
              ),
              skinToneConfig: const SkinToneConfig(),
              categoryViewConfig: CategoryViewConfig(
                backgroundColor: theme.colorScheme.surfaceContainer,
                iconColorSelected: AppPallete.primaryMain,
                indicatorColor: AppPallete.primaryMain,
              ),
              bottomActionBarConfig: BottomActionBarConfig(
                backgroundColor: theme.colorScheme.surfaceContainer,
                buttonColor: Colors.transparent,
              ),
              searchViewConfig: const SearchViewConfig(),
            ),
            onEmojiSelected: ((category, emoji) {
              // pop the bottom sheet
              Navigator.pop(context);
              widget.onPick(emoji.emoji);
            }),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMe = widget.isMe;

    final Offset lift = Offset(isMe ? -50 : 10, -5); // gentle outward lift

    return AnimatedBuilder(
      animation: _t,
      builder: (context, _) {
        final v = _t.value;
        return Stack(
          children: [
            // Frosted backdrop
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _close,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5 * v, sigmaY: 5 * v),
                  child: Container(
                    color: Colors.black.withOpacity(0.5 * v),
                  ),
                ),
              ),
            ),

            // Elevated bubble, anchored (hero out/in)
            CompositedTransformFollower(
              link: widget.anchor,
              showWhenUnlinked: false,
              offset: lift * v,
              child: Opacity(
                opacity: v,
                child: Transform.scale(
                  scale: 1 + 0.06 * v,
                  child: widget.bubble,
                ),
              ),
            ),

            // Reactions bar, aligned to absolute RIGHT (me) or LEFT (others)
            CompositedTransformFollower(
              link: widget.anchor,
              showWhenUnlinked: false,
              offset: const Offset(0, -88), // above the bubble
              child: SizedBox(
                width: widget.bubbleWidth, // align within bubble width
                child: Align(
                  alignment: isMe ? Alignment.topRight : Alignment.topLeft,
                  child: Transform.translate(
                    offset: Offset(0, 12 * (1 - v)),
                    child: Transform.scale(
                      scale: 0.9 + 0.1 * v,
                      child: Opacity(
                        opacity: v,
                        child: Material(
                          elevation: 8,
                          borderRadius: BorderRadius.circular(30),
                          color: theme.colorScheme.surface,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 6),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                '👍',
                                '❤️',
                                '😂',
                                '😮',
                                '😢',
                                '😠',
                                '➕',
                              ]
                                  .map((e) => InkWell(
                                        borderRadius: BorderRadius.circular(20),
                                        onTap: () {
                                          if (e == '➕') {
                                            showEmojiBottomSheet(
                                              theme: theme,
                                            );
                                          } else {
                                            widget.onPick(e);
                                          }
                                          _close();
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6),
                                          child: Text(e,
                                              style: const TextStyle(
                                                  fontSize: 22)),
                                        ),
                                      ))
                                  .toList(),
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
        );
      },
    );
  }
}
