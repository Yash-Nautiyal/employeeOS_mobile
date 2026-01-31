import 'package:employeeos/core/index.dart' show AppPallete;
import 'package:flutter/material.dart';

import '../../../../index.dart'
    show SharedUser, TableSideMenuPopup, UserPermission;

class TableSideMenuShareSection extends StatelessWidget {
  const TableSideMenuShareSection(
      {super.key,
      required this.theme,
      required this.title,
      required this.child,
      this.onAdd});

  final ThemeData theme;
  final String title;
  final Widget child;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        children: [
          // Header - not clickable, always visible
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (onAdd != null) ...[
                  GestureDetector(
                    onTap: onAdd,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: AppPallete.successMain,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Content - always visible
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: child,
          ),
        ],
      ),
    );
  }
}

class SharePropertyRow extends StatelessWidget {
  const SharePropertyRow({
    super.key,
    required this.theme,
    required this.user,
    required this.handlePermissionChange,
    required this.handleRemoveUser,
  });
  final ThemeData theme;
  final SharedUser user;
  final Function(SharedUser, UserPermission) handlePermissionChange;
  final Function(SharedUser) handleRemoveUser;
  
  @override
  Widget build(BuildContext context) {
    final hasUrl = user.avatarUrl.isNotEmpty;
    final initials = _initialsFromName(user.name);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: theme.dividerColor,
            backgroundImage: hasUrl ? NetworkImage(user.avatarUrl) : null,
            child: !hasUrl
                ? Text(
                    initials,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(color: theme.colorScheme.tertiary),
                ),
                Text(
                  user.email,
                  style: theme.textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TableSideMenuPopup(
              theme: theme,
              user: user,
              handlePermissionChange: handlePermissionChange,
              handleRemoveUser: handleRemoveUser),
        ],
      ),
    );
  }

  String _initialsFromName(String name) {
    final cleaned = name.trim();
    if (cleaned.isEmpty) return '?';

    final parts = cleaned.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      final part = parts.first;
      if (part.isEmpty) return '?';
      return (part.length >= 2 ? part.substring(0, 2) : part.substring(0, 1))
          .toUpperCase();
    }

    final first = parts.first;
    final last = parts.last;
    final firstChar = first.isNotEmpty ? first[0] : '';
    final lastChar = last.isNotEmpty ? last[0] : '';
    final initials = '$firstChar$lastChar'.trim();
    return initials.isEmpty ? '?' : initials.toUpperCase();
  }
}
