import 'package:employeeos/core/common/components/dialog/slide_dialog.dart';
import 'package:employeeos/core/common/components/header/settings_switch.dart';
import 'package:employeeos/core/theme/bloc/theme_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SlideDialog(
      theme: theme,
      title: 'Settings',
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        children: [
          Column(
            children: [
              SettingsSwitch(
                theme: theme,
                icon: 'assets/icons/common/ic-moon.svg',
                title: 'Dark Mode',
                onSwitch:
                    () => context.read<ThemeBloc>().add(ToggleThemeEvent()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
