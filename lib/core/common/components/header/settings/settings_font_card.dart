import 'package:employeeos/core/theme/app_typography.dart' show Fonts;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SettingsFontCard extends StatelessWidget {
  final ThemeData theme;
  final Map<Fonts, String> fonts;
  final Fonts currentFont;
  final Function onChange;

  const SettingsFontCard({
    super.key,
    required this.theme,
    required this.fonts,
    required this.currentFont,
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
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: fonts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final entry = fonts.entries.elementAt(index);
                final fontKey = entry.key;
                final isSelected = fontKey == currentFont;
                return InkWell(
                  onTap: () => onChange(fontKey),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.scaffoldBackgroundColor
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: isSelected
                          ? Border.all(
                              color: theme.dividerColor.withAlpha(100),
                            )
                          : const Border.fromBorderSide(BorderSide.none),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ShaderMask(
                            shaderCallback: (Rect bounds) {
                              return LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  theme.primaryColor,
                                  theme.colorScheme.primaryFixed,
                                ],
                              ).createShader(bounds);
                            },
                            blendMode: BlendMode.srcIn,
                            child: SvgPicture.asset(
                              'assets/icons/setting/ic-font.svg',
                              height: 30,
                              color: isSelected
                                  ? theme.primaryColor
                                  : theme.dividerColor,
                            ),
                          ),
                          Text(
                            entry.value,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: isSelected
                                  ? theme.colorScheme.onSurface
                                  : theme.dividerColor,
                            ),
                          ),
                        ],
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
              color: theme.colorScheme.onSurface,
            ),
            child: Text(
              "Font",
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
