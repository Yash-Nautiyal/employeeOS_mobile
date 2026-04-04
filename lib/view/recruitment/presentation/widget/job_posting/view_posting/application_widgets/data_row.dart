import 'package:employeeos/core/index.dart';
import 'package:employeeos/view/recruitment/domain/index.dart'
    show ApplicationStatusActions;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'checkbox.dart';

class CustomDataRow extends StatelessWidget {
  const CustomDataRow({
    super.key,
    required this.theme,
    required this.row,
    required this.selected,
    required this.backgroundColor,
    required this.onToggle,
    required this.onResume,
    required this.widths,
  });

  final ThemeData theme;
  final Map<String, dynamic> row;
  final bool selected;
  final Color backgroundColor;
  final VoidCallback onToggle;
  final VoidCallback onResume;
  final Map<String, double> widths;

  @override
  Widget build(BuildContext context) {
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final name = row['full_name'] as String? ?? '';
    final email = row['email'] as String? ?? '';
    final phone = row['phone'] as String? ?? '';
    final status = row['status'] as String? ?? '';
    final date = formatDate(DateTime.parse(row['applied_on'] as String));
    final canSelect = ApplicationStatusActions.canUpdateStatus(status);

    final bodyStyle = tt.bodyMedium?.copyWith(color: cs.onSurface);

    final mutedStyle = tt.bodyMedium?.copyWith(color: cs.onSurface);

    final rowBody = Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          const SizedBox(width: 10),

          // Checkbox (only rows that can be shortlisted/rejected)
          if (canSelect)
            CustomCheckbox(
              checked: selected,
              onTap: onToggle,
              colorScheme: cs,
            )
          else
            SizedBox(
              width: 40,
              child:
                  Icon(Icons.check_circle, color: theme.colorScheme.secondary),
            ),
          const SizedBox(width: 10),

          // Applicant name — bold
          SizedBox(
            width: widths['applicant'],
            child: Text(
              name,
              style: tt.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 10),

          // Email
          SizedBox(
            width: widths['email'],
            child:
                Text(email, style: mutedStyle, overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 10),

          // Phone
          SizedBox(
            width: widths['phone'],
            child:
                Text(phone, style: mutedStyle, overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 10),

          // Status badge
          SizedBox(
            width: widths['status'],
            child: _StatusBadge(status: status, theme: theme),
          ),
          const SizedBox(width: 10),

          // Applied on date
          SizedBox(
            width: widths['appliedOn'],
            child: Text(date, style: bodyStyle),
          ),
          const SizedBox(width: 10),

          // Resume "View" link
          SizedBox(
            width: widths['resume'],
            child: GestureDetector(
              onTap: onResume,
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/common/solid/ic-solar_file-text-bold.svg',
                    width: 15,
                    colorFilter: ColorFilter.mode(
                      theme.indicatorColor,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'View',
                    style: tt.bodySmall?.copyWith(
                      color: const Color(0xFF38BDF8),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 20),
        ],
      ),
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      color: backgroundColor,
      child: canSelect ? InkWell(onTap: onToggle, child: rowBody) : rowBody,
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.theme});

  final String status;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final norm = status.toLowerCase().trim();
    final darkColor = switch (norm) {
      'shortlisted' => AppPallete.successDark,
      'rejected' => AppPallete.errorDark,
      'interview' => AppPallete.infoDark,
      'hired' => AppPallete.primaryDark,
      _ => AppPallete.warningDark, // pending
    };
    final lightColor = switch (norm) {
      'shortlisted' => AppPallete.successLight,
      'rejected' => AppPallete.errorLight,
      'interview' => AppPallete.infoLight,
      'hired' => AppPallete.primaryLight,
      _ => AppPallete.warningLight, // pending
    };
    final label =
        norm.isEmpty ? 'Pending' : norm[0].toUpperCase() + norm.substring(1);

    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: [
            theme.brightness == Brightness.dark ? darkColor : lightColor,
            theme.brightness == Brightness.dark ? lightColor : darkColor
          ], // Replace with your desired colors
          begin: theme.brightness == Brightness.dark
              ? Alignment.topLeft
              : Alignment.bottomRight,
          end: theme.brightness == Brightness.dark
              ? Alignment.bottomRight
              : Alignment.topLeft,
        ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height));
      },
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
