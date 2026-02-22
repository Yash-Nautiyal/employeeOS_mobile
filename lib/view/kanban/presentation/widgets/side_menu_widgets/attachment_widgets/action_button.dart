import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ActionButton extends StatelessWidget {
  final ThemeData theme;
  final VoidCallback? onTap;
  final bool enabled;
  const ActionButton({
    super.key,
    required this.theme,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      radius: 50,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: theme.colorScheme.error.withValues(alpha: 0.15),
            ),
            child: SvgPicture.asset(
              'assets/icons/common/solid/ic-solar_trash-bin-trash-bold.svg',
              colorFilter: ColorFilter.mode(
                enabled ? theme.colorScheme.error : theme.disabledColor,
                BlendMode.srcIn,
              ),
              width: 18,
            ),
          ),
        ),
      ),
    );
  }
}

class AttachmentOwnerAvatar extends StatelessWidget {
  const AttachmentOwnerAvatar({
    super.key,
    required this.theme,
    required this.avatarUrl,
    required this.initials,
  });

  final ThemeData theme;
  final String? avatarUrl;
  final String initials;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 12,
      backgroundImage: avatarUrl != null && avatarUrl!.isNotEmpty
          ? NetworkImage(avatarUrl!)
          : null,
      child: (avatarUrl == null || avatarUrl!.isEmpty)
          ? Text(
              initials,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.tertiary,
              ),
            )
          : null,
    );
  }
}
