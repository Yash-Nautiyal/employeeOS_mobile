import 'package:employeeos/core/common/components/dialog/slide_dialog.dart';
import 'package:employeeos/core/routing/app_routes.dart';
import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:employeeos/core/auth/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileDialog extends StatelessWidget {
  final ThemeData theme;

  const ProfileDialog({super.key, required this.theme});

  static String _roleDisplay(String? roleValue) {
    if (roleValue == null || roleValue.isEmpty) return '—';
    switch (roleValue.toLowerCase()) {
      case 'hr':
        return 'HR';
      case 'admin':
        return 'Admin';
      case 'employee':
      default:
        return roleValue.length > 1
            ? '${roleValue[0].toUpperCase()}${roleValue.substring(1)}'
            : roleValue.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<AuthBloc>().state.currentProfile;
    final name = profile?.fullName ?? profile?.email ?? 'Unknown';
    final avatarUrl = profile?.avatarUrl;
    final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;
    final initials = name.length >= 2
        ? name.substring(0, 2).toUpperCase()
        : name.substring(0, 1).toUpperCase();
    return SlideDialog(
      theme: theme,
      title: "Profile",
      child: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                          center: Alignment.center,
                          startAngle: 0.0,
                          endAngle: 6.28319,
                          colors: [
                            Colors.blue,
                            Colors.purple,
                            Colors.red,
                            Colors.orange,
                            Colors.yellow,
                            Colors.blue,
                          ],
                          stops: [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
                        ),
                      ),
                    ),
                    CircleAvatar(
                      radius: 30,
                      backgroundImage:
                          hasAvatar ? NetworkImage(avatarUrl) : null,
                      child: !hasAvatar
                          ? Text(
                              initials,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            )
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  profile?.fullName ?? profile?.email ?? '—',
                  style: theme.textTheme.titleLarge?.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 10),
                Text(
                  _roleDisplay(profile?.role.value),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AuthBloc>().add(AuthSignOutRequested());
              Navigator.of(context).pop(); // close profile dialog
              const HomeRoute().go(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPallete.errorLight.withOpacity(0.8),
              foregroundColor: AppPallete.errorLight,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Logout',
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppPallete.errorDarker,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
