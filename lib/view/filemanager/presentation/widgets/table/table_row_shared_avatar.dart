import '../../../index.dart' show SharedUser;
import 'package:flutter/material.dart';
import 'package:super_tooltip/super_tooltip.dart';

class SharedUsersTooltip extends StatefulWidget {
  const SharedUsersTooltip({
    super.key,
    required this.users,
    required this.child,
    this.stackHeight = 40,
    this.avatarSize = 20,
  });

  final List<SharedUser> users; // expects fields: avatarUrl, name, email
  final Widget child; // your AnimatedAvatarStack
  final double stackHeight;
  final double avatarSize;

  @override
  State<SharedUsersTooltip> createState() => _SharedUsersTooltipState();
}

class _SharedUsersTooltipState extends State<SharedUsersTooltip> {
  final _controller = SuperTooltipController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SuperTooltip(
      controller: _controller,
      popupDirection: TooltipDirection.left, // use .up if near screen bottom
      arrowBaseWidth: 14,
      arrowLength: 10,
      arrowTipDistance: 8,
      borderRadius: 30,
      borderWidth: 1,
      showBarrier: true,
      showDropBoxFilter: true,
      toggleOnTap: true,
      sigmaX: 5,
      sigmaY: 5,
      backgroundColor: theme.colorScheme.surface,
      // A visible barrier lets the user tap outside to close:
      barrierColor: Colors.black
          .withOpacity(0.001), // almost invisible, still catches taps
      showCloseButton: false,
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 300),

      constraints:
          const BoxConstraints(minWidth: 200, maxWidth: 250, maxHeight: 280),
      // Optional: also close if the parent scrolls
      // closeOnScroll: true,
      borderColor: theme.dividerColor,
      content:
          _SharedUsersList(users: widget.users, avatarSize: widget.avatarSize),

      // Your existing avatar stack remains unchanged; we just make it the anchor
      child: InkWell(
        onTap: () => _controller.isVisible
            ? _controller.hideTooltip()
            : _controller.showTooltip(),
        borderRadius: BorderRadius.circular(widget.avatarSize),
        child: SizedBox(height: widget.stackHeight, child: widget.child),
      ),
    );
  }
}

class _SharedUsersList extends StatelessWidget {
  const _SharedUsersList({required this.users, required this.avatarSize});
  final List<SharedUser> users;
  final double avatarSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView.separated(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      itemCount: users.length,
      separatorBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(left: 50.0),
        child: Divider(
          height: 1,
          thickness: 0.6,
          color: theme.dividerColor,
        ),
      ),
      itemBuilder: (context, i) {
        final u = users[i];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: [
              _AvatarCircle(size: avatarSize, url: u.avatarUrl, name: u.name),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      u.name,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      u.email,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.disabledColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle(
      {required this.size, required this.url, required this.name});
  final double size;
  final String? url;
  final String name;

  @override
  Widget build(BuildContext context) {
    final initials = _initials(name);
    return ClipOval(
      child: (url != null && url!.isNotEmpty)
          ? CircleAvatar(
              backgroundImage: NetworkImage(url!),
              radius: size,
            )
          : CircleAvatar(
              child: Text(
                initials,
                style: TextStyle(
                  fontSize: size * 0.42,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
    );
  }

  String _initials(String n) {
    final parts = n.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1)
      return parts.first.characters.take(2).toString().toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }
}
