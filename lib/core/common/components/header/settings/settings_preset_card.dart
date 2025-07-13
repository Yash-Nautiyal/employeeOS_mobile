import 'package:employeeos/core/theme/app_pallete.dart' show Presets;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SettingsPresetCard extends StatelessWidget {
  final ThemeData theme;
  final Map<Presets, dynamic> presets;
  final Presets currentPreset;
  final Function onChange;
  const SettingsPresetCard({
    super.key,
    required this.theme,
    required this.presets,
    required this.currentPreset,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          child: Container(
            padding: const EdgeInsets.all(10).copyWith(top: 20),
            margin: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.disabledColor.withAlpha(100)),
            ),
            child: GridView.builder(
              shrinkWrap: true,
              itemCount: presets.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final entry = presets.entries.elementAt(index);
                final presetKey = entry.key;
                final colors = entry.value;
                final isSelected = presetKey == currentPreset;
                return InkWell(
                  onTap: () => onChange(presetKey),
                  child: Container(
                    width: 40,
                    height: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      // ignore: deprecated_member_use
                      color: (colors["Light"] as Color).withOpacity(
                        isSelected
                            ? theme.brightness == Brightness.dark
                                ? 0.1
                                : 0.2
                            : 0,
                      ),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/icons/setting/ic-siderbar-duotone.svg',
                        height: 30,
                        color: colors["Main"],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 15,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: theme.colorScheme.tertiary,
            ),
            child: Text(
              "Presets",
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.scaffoldBackgroundColor,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
