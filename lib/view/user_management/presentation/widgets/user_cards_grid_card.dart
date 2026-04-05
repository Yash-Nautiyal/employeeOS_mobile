import 'package:employeeos/core/common/actions/user_actions.dart';
import 'package:employeeos/core/user/user_info_entity.dart';
import 'package:flutter/material.dart';

import '../../../../core/user/user_info_index.dart';

class UserCardsGridCard extends StatelessWidget {
  final ThemeData theme;
  final UserInfoEntity user;

  const UserCardsGridCard({
    super.key,
    required this.user,
    required this.theme,
  });

  String get _initials =>
      getInitials(user.fullName.isNotEmpty ? user.fullName : user.email);

  @override
  Widget build(BuildContext context) {
    final avatarUrl = user.avatarUrl;
    final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        // border: Border.all(color: theme.shadowColor),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
                child: _AvatarBackdrop(theme: theme, avatarUrl: avatarUrl)),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ClipPath(
                clipper: JsonPathClipper(),
                child: Container(
                  color: theme.colorScheme.surface,
                  padding: const EdgeInsets.only(top: 12, bottom: 18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        backgroundImage:
                            hasAvatar ? NetworkImage(avatarUrl) : null,
                        child: !hasAvatar
                            ? Text(
                                _initials.isEmpty ? '?' : _initials,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        user.fullName.isNotEmpty ? user.fullName : user.email,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        UserRole.fromString(user.role).value.toUpperCase(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          user.email,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.disabledColor,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
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

class _AvatarBackdrop extends StatelessWidget {
  const _AvatarBackdrop({
    required this.theme,
    required this.avatarUrl,
  });

  final ThemeData theme;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final url = avatarUrl;
    if (url != null && url.isNotEmpty) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            url,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (_, __, ___) => _FallbackGradient(theme: theme),
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return ColoredBox(
                color: theme.colorScheme.surfaceContainerHighest,
                child: Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
              ),
            ),
          ),
        ],
      );
    }
    return _FallbackGradient(theme: theme);
  }
}

class _FallbackGradient extends StatelessWidget {
  const _FallbackGradient({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: theme.colorScheme.surfaceContainerHighest,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.35),
              theme.colorScheme.tertiary.withValues(alpha: 0.25),
              theme.colorScheme.surfaceContainerHighest,
            ],
          ),
        ),
      ),
    );
  }
}

class JsonPathClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const originalWidth = 588.160009765625;
    const originalHeight = 588.160009765625;

    final scaleX = size.width / originalWidth;
    final scaleY = size.height / originalHeight;

    final path = Path();

    path.moveTo(194.6 * scaleX, 82.1 * scaleY);

    path.cubicTo(
      208.5 * scaleX,
      65.45 * scaleY,
      203.726 * scaleX,
      71.325 * scaleY,
      220.699 * scaleX,
      52.3625 * scaleY,
    );
    path.cubicTo(
      236.785 * scaleX,
      34.081 * scaleY,
      231.5 * scaleX,
      38.2 * scaleY,
      247.6 * scaleX,
      20.4 * scaleY,
    );
    path.cubicTo(
      262.1 * scaleX,
      4 * scaleY,
      289.236 * scaleX,
      0 * scaleY,
      292.48 * scaleX,
      0 * scaleY,
    );
    path.cubicTo(
      321.432 * scaleX,
      0 * scaleY,
      334.136 * scaleX,
      13.007 * scaleY,
      343 * scaleX,
      22.814 * scaleY,
    );
    path.cubicTo(
      351.863 * scaleX,
      32.621 * scaleY,
      357.081 * scaleX,
      44.029 * scaleY,
      364.9 * scaleX,
      53.632 * scaleY,
    );
    path.cubicTo(
      390.004 * scaleX,
      87.644 * scaleY,
      378.563 * scaleX,
      74.188 * scaleY,
      392 * scaleX,
      86.866 * scaleY,
    );
    path.cubicTo(
      403.038 * scaleX,
      98.744 * scaleY,
      417.158 * scaleX,
      110.356 * scaleY,
      468.128 * scaleX,
      117.7 * scaleY,
    );
    path.cubicTo(
      499.314 * scaleX,
      117.7 * scaleY,
      551.36 * scaleX,
      117.248 * scaleY,
      588.16 * scaleX,
      117.7 * scaleY,
    );
    path.cubicTo(
      588.16 * scaleX,
      139.751 * scaleY,
      588.16 * scaleX,
      204.078 * scaleY,
      588.16 * scaleX,
      235.264 * scaleY,
    );
    path.lineTo(588.16 * scaleX, 470.528 * scaleY);
    path.cubicTo(
      588.16 * scaleX,
      501.714 * scaleY,
      588.16 * scaleX,
      588.16 * scaleY,
      588.16 * scaleX,
      588.16 * scaleY,
    );
    path.cubicTo(
      588.16 * scaleX,
      588.16 * scaleY,
      501.714 * scaleX,
      588.16 * scaleY,
      470.528 * scaleX,
      588.16 * scaleY,
    );
    path.lineTo(117.632 * scaleX, 588.16 * scaleY);
    path.cubicTo(
      86.446 * scaleX,
      588.16 * scaleY,
      0 * scaleX,
      588.16 * scaleY,
      0 * scaleX,
      588.16 * scaleY,
    );
    path.cubicTo(
      0 * scaleX,
      588.16 * scaleY,
      0 * scaleX,
      501.714 * scaleY,
      0 * scaleX,
      470.528 * scaleY,
    );
    path.lineTo(0 * scaleX, 235.264 * scaleY);
    path.cubicTo(
      0 * scaleX,
      204.078 * scaleY,
      0 * scaleX,
      139.737 * scaleY,
      0 * scaleX,
      117.686 * scaleY,
    );
    path.cubicTo(
      55.2 * scaleX,
      118.834 * scaleY,
      59 * scaleX,
      119.2 * scaleY,
      120.1 * scaleX,
      117.7 * scaleY,
    );
    path.cubicTo(
      171.3 * scaleX,
      108.1 * scaleY,
      168 * scaleX,
      105.4 * scaleY,
      194.6 * scaleX,
      82.1 * scaleY,
    );

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
