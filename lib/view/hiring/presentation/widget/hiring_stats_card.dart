import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sizer/sizer.dart';

class HiringStatsCard extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  const HiringStatsCard({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wideScreen = MediaQuery.of(context).size.width > 700;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 300,
        childAspectRatio: !isPortrait || wideScreen ? 2.3 : 1.5,
      ),
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: data.length,
      itemBuilder: (context, index) {
        final item = data[index];

        return Card(
          elevation: 3,
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
            width: double.infinity,
            height: double.parse(item['height'].toString()),
            child: Stack(
              children: [
                // Card Content
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item['title'],
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 16.sp,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          item['value'],
                          style: theme.textTheme.displayMedium?.copyWith(
                            color: item['valueColor'] ??
                                theme.colorScheme.onSurface,
                            fontSize: 27.sp,
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
                      item['iconPath'],
                      color: item['valueColor']!.withAlpha(10),
                      width: !isPortrait || wideScreen ? 15.w : 30.w,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
