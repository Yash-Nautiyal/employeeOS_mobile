import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AnalyticsContainer extends StatelessWidget {
  final ThemeData theme;
  final Color color;
  final Color titleColor;
  final Color valueColor;
  final String icon;
  final String title;
  final String value;
  const AnalyticsContainer(
      {super.key,
      required this.theme,
      required this.color,
      required this.titleColor,
      required this.valueColor,
      required this.icon,
      required this.title,
      required this.value});

  @override
  Widget build(BuildContext context) {
    final wideScreen = MediaQuery.of(context).size.width > 700;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    final isWideScreen = !isPortrait || wideScreen;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: color,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(1),
            color.withOpacity(0.5),
          ],
        ),
        boxShadow: AppShadows.card(theme.brightness),
        image: const DecorationImage(
          alignment: Alignment.centerLeft,
          opacity: .1,
          fit: BoxFit.cover,
          image: AssetImage('assets/images/texture/Style=3.png'),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(width: isWideScreen ? 60 : 40, icon),
          const SizedBox(
            height: 15,
          ),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelLarge
                ?.copyWith(color: titleColor, fontSize: 15, height: 1),
          ),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleLarge?.copyWith(
                color: valueColor, fontWeight: FontWeight.w700, fontSize: 20),
          )
        ],
      ),
    );
  }
}
