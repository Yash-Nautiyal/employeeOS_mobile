// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class AvatarStackItem {
  const AvatarStackItem({
    required this.name,
    this.imageUrl,
    this.isCurrentUser = false,
    this.headerInitials = 'Y',
  });

  final String name;
  final String? imageUrl;
  final bool isCurrentUser;
  final String headerInitials;
}

class CustomAvatarStack extends StatelessWidget {
  const CustomAvatarStack({
    super.key,
    required this.items,
    this.size = 32,
    this.overlap = 20,
    this.maxVisible = 3,
  });

  final List<AvatarStackItem> items;
  final double size;
  final double overlap;
  final int maxVisible;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visible = items.take(maxVisible).toList();
    final hasOverflow = items.length > maxVisible;
    final int baseCount = hasOverflow ? maxVisible : visible.length;
    final double width = baseCount <= 1
        ? size
        : size + overlap * (baseCount - 1) + (hasOverflow ? overlap : 0);

    return SizedBox(
      height: size,
      width: width,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (final entry in visible.asMap().entries)
            Positioned(
              left: entry.key * overlap,
              child: _AvatarCircle(
                item: entry.value,
                size: size,
                theme: theme,
                isCurrentUser: entry.value.isCurrentUser,
              ),
            ),
          if (hasOverflow)
            Positioned(
              left: overlap * maxVisible,
              child: _SurplusCircle(
                count: items.length - maxVisible,
                size: size,
                theme: theme,
              ),
            ),
        ],
      ),
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({
    required this.item,
    required this.size,
    required this.theme,
    required this.isCurrentUser,
  });

  final AvatarStackItem item;
  final double size;
  final ThemeData theme;
  final bool isCurrentUser;
  @override
  Widget build(BuildContext context) {
    final initials = _initialsFromName(item.name);
    final hasUrl = (item.imageUrl ?? '').isNotEmpty;
    final initialsAvatar = _buildInitialsAvatar(theme, initials, size);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isCurrentUser
                  ? item.headerInitials == 'V'
                      ? theme.colorScheme.secondary
                      : theme.primaryColor
                  : theme.scaffoldBackgroundColor,
              width: isCurrentUser ? 2.5 : 1.5,
            ),
          ),
          child: ClipOval(
            child: hasUrl
                ? Image.network(
                    item.imageUrl!,
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return initialsAvatar;
                    },
                    errorBuilder: (context, error, stackTrace) =>
                        initialsAvatar,
                  )
                : initialsAvatar,
          ),
        ),
        if (isCurrentUser)
          Positioned(
            top: -7,
            right: 0,
            left: 0,
            child: Container(
              width: size * 0.41,
              height: size * 0.41,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: item.headerInitials == 'V'
                    ? theme.colorScheme.secondary
                    : theme.primaryColor,
                border: Border.all(
                  color: theme.scaffoldBackgroundColor,
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  item.headerInitials,
                  style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: 7.5,
                      color: Colors.white),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _SurplusCircle extends StatelessWidget {
  const _SurplusCircle({
    required this.count,
    required this.size,
    required this.theme,
  });

  final int count;
  final double size;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.primaryColor.withOpacity(0.8),
        border: Border.all(
          color: theme.scaffoldBackgroundColor,
          width: 2,
        ),
      ),
      child: Text(
        '+$count',
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: theme.primaryColorLight,
        ),
      ),
    );
  }
}

Widget _buildInitialsAvatar(ThemeData theme, String initials, double size) {
  return Container(
    width: size,
    height: size,
    color: theme.primaryColor.withOpacity(0.12),
    alignment: Alignment.center,
    child: Text(
      initials,
      style: theme.textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: theme.colorScheme.primary,
      ),
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
