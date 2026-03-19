import 'package:employeeos/core/index.dart' show CustomTextButton;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ActionBtn extends StatelessWidget {
  const ActionBtn({
    super.key,
    required this.label,
    required this.color,
    required this.onTap,
    required this.theme,
  });
  final String label;
  final Color color;
  final VoidCallback onTap;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: color.withValues(alpha: 0.30)),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class DownloadBtn extends StatelessWidget {
  const DownloadBtn({
    super.key,
    required this.theme,
    required this.onTap,
    required this.selectedCount,
  });
  final ThemeData theme;
  final VoidCallback onTap;
  final int selectedCount;
  @override
  Widget build(BuildContext context) {
    return CustomTextButton(
      onClick: onTap,
      backgroundColor: theme.colorScheme.tertiary,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/icons/common/solid/ic-mingcute-download-line.svg',
            width: 15,
            colorFilter: ColorFilter.mode(
              theme.scaffoldBackgroundColor,
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'Download ${selectedCount > 0 ? '($selectedCount selected) ${selectedCount > 1 ? 'Resumes' : 'Resume'}' : 'All Resumes'}',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.scaffoldBackgroundColor,
            ),
          ),
        ],
      ),
    );
  }
}
