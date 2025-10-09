import 'package:employeeos/core/common/components/dialog/slide_dialog.dart'
    show SlideDialog;
import 'package:employeeos/core/common/components/header/settings/settings_font_card.dart';
import 'package:employeeos/core/common/components/header/settings/settings_preset_card.dart';
import 'package:employeeos/core/common/components/header/settings/settings_switch.dart';
import 'package:employeeos/core/theme/app_pallete.dart' show AppPallete;
import 'package:employeeos/core/theme/app_typography.dart' show AppTypography;
import 'package:employeeos/core/theme/bloc/theme_bloc.dart'
    show ChangeFontEvent, ChangePresetEvent, ThemeBloc, ToggleBrightnessEvent;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final presets = AppPallete.primaryPresets;
    final fonts = AppTypography.fontMap;
    final currentPreset = context.watch<ThemeBloc>().state.preset;
    final currentFont = context.watch<ThemeBloc>().state.font;
    final scrollController = ScrollController();
    return SlideDialog(
      theme: theme,
      title: 'Settings',
      child: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SettingsSwitch(
              theme: theme,
              icon: 'assets/icons/setting/ic-moon.svg',
              title: 'Dark Mode',
              onSwitch: () =>
                  context.read<ThemeBloc>().add(ToggleBrightnessEvent()),
            ),
            const SizedBox(height: 20),
            SettingsPresetCard(
              theme: theme,
              presets: presets,
              currentPreset: currentPreset,
              onChange: (presetKey) => context.read<ThemeBloc>().add(
                    ChangePresetEvent(presetKey),
                  ),
            ),
            const SizedBox(height: 20),
            SettingsFontCard(
              theme: theme,
              fonts: fonts,
              currentFont: currentFont,
              onChange: (fontKey) =>
                  context.read<ThemeBloc>().add(ChangeFontEvent(fontKey)),
            ),
          ],
        ),
      ),
    );
  }
}
