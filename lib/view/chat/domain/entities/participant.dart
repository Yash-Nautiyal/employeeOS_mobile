import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';

enum ParticipantStatus { online, offline, away, busy }

extension ParticipantStatusExtension on ParticipantStatus {
  String get name {
    switch (this) {
      case ParticipantStatus.online:
        return 'Online';
      case ParticipantStatus.offline:
        return 'Offline';
      case ParticipantStatus.away:
        return 'Away';
      case ParticipantStatus.busy:
        return 'Busy';
    }
  }
}

extension ParticipantBadgeExtension on ParticipantStatus {
  Widget statusBadge(ThemeData theme) {
    switch (this) {
      case ParticipantStatus.online:
        return _circleBadge(theme, color: AppPallete.successMain);
      case ParticipantStatus.offline:
        return _circleBadge(theme, icon: Icons.remove_circle_outline_rounded);
      case ParticipantStatus.away:
        return _circleBadge(theme,
            icon: Icons.query_builder_rounded, iconColor: AppPallete.errorDark);
      case ParticipantStatus.busy:
        return _circleBadge(theme,
            icon: Icons.access_time_filled_rounded,
            iconColor: AppPallete.warningMain);
    }
  }

  Widget _circleBadge(ThemeData theme,
      {Color? color, IconData? icon, Color? iconColor}) {
    return CircleAvatar(
      radius: 7,
      backgroundColor: theme.scaffoldBackgroundColor,
      child: icon != null
          ? Icon(icon, size: 13, color: iconColor ?? theme.dividerColor)
          : CircleAvatar(
              radius: 5,
              backgroundColor: color,
            ),
    );
  }
}

class Participant {
  final String id;
  final String name;
  final String avatarUrl;
  final ParticipantStatus status;

  Participant({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.status,
  });
}
