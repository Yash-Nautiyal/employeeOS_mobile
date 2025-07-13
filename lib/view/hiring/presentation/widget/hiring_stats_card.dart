import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class HiringStatsCard extends StatelessWidget {
  final String title;
  final String value;
  final Color? valueColor;
  final double? width;
  final double? height;
  final bool? ishorizontal;
  final String iconPath;

  const HiringStatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.iconPath,
    this.valueColor,
    this.width,
    this.height,
    this.ishorizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      color: theme.scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.dividerColor
              .withAlpha(theme.brightness == Brightness.dark ? 40 : 20),
        ),
      ),
      clipBehavior: Clip.antiAlias, // Ensures SVG is clipped
      child: SizedBox(
        width: width ?? double.infinity,
        height: height ?? 100,
        child: Stack(
          children: [
            // Card Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: ishorizontal!
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            value,
                            style: theme.textTheme.displayMedium?.copyWith(
                              color: valueColor ?? theme.colorScheme.onSurface,
                              fontSize: 40,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Flexible(
                          child: Text(
                            value,
                            style: theme.textTheme.displayMedium?.copyWith(
                              color: valueColor ?? theme.colorScheme.onSurface,
                              fontSize: 40,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
            // Decorative SVG in the corner, clipped
            Positioned(
              bottom: -23,
              right: -25,
              child: Transform.rotate(
                angle: -0.4,
                child: SvgPicture.asset(
                  iconPath,
                  color: valueColor != null
                      ? valueColor!.withAlpha(25)
                      : theme.dividerColor.withAlpha(35),
                  height: 100,
                  width: 50,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
