import 'package:employeeos/core/index.dart' show AppPallete, CustomTextButton;
import 'package:employeeos/view/recruitment/domain/job_application/application_db_values.dart';
import 'package:employeeos/view/recruitment/domain/job_application/entities/job_application.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class JobApplicationCard extends StatelessWidget {
  final ThemeData theme;
  final JobApplication application;
  final VoidCallback onShortlist;
  final VoidCallback onReject;

  const JobApplicationCard({
    super.key,
    required this.theme,
    required this.application,
    required this.onShortlist,
    required this.onReject,
  });

  static final _dateFmt = DateFormat('dd MMM yyyy, h:mm a');

  static String _statusLabel(String raw) {
    final n = ApplicationStatusActions.normalize(raw);
    if (n.isEmpty) return 'Pending';
    return n
        .split('_')
        .map((part) =>
            part.isEmpty ? '' : '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  Future<void> _openResume(BuildContext context) async {
    final uri = Uri.tryParse(application.resumeUrl);
    if (uri == null) return;
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open resume link')),
      );
    }
  }

  (Color bg, Color fg) _statusColors() {
    switch (ApplicationStatusActions.normalize(application.status)) {
      case ApplicationDbStatus.shortlisted:
        return (
          AppPallete.successMain.withAlpha(50),
          AppPallete.successMain,
        );
      case ApplicationDbStatus.rejected:
        return (
          AppPallete.errorMain.withAlpha(50),
          AppPallete.errorMain,
        );
      case ApplicationDbStatus.pending:
        return (
          AppPallete.warningMain.withAlpha(50),
          AppPallete.warningMain,
        );
      default:
        return (
          theme.dividerColor.withAlpha(40),
          theme.disabledColor,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final showActions =
        ApplicationStatusActions.canUpdateStatus(application.status);
    final statusColors = _statusColors();

    return Container(
      constraints: const BoxConstraints(
        maxHeight: 270,
        minHeight: 250,
      ),
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.shadowColor),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor,
            spreadRadius: 1,
            blurRadius: 3,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  application.fullName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.displaySmall?.copyWith(fontSize: 17),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColors.$1,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _statusLabel(application.status),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: statusColors.$2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'ID: ${application.id.toUpperCase()}',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.disabledColor),
          ),
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/common/solid/ic-solar_case-minimalistic-bold.svg',
                colorFilter:
                    ColorFilter.mode(theme.disabledColor, BlendMode.srcIn),
                width: 20,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  application.jobTitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.dividerColor,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/common/solid/ic-solar_phone-bold.svg',
                colorFilter:
                    ColorFilter.mode(theme.disabledColor, BlendMode.srcIn),
                width: 20,
              ),
              const SizedBox(width: 5),
              Text(
                application.phone,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.dividerColor,
                ),
              ),
            ],
          ),
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/common/solid/ic-fluent_mail-24-filled.svg',
                colorFilter:
                    ColorFilter.mode(theme.disabledColor, BlendMode.srcIn),
                width: 20,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  application.email,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.dividerColor,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/ic-calender.svg',
                colorFilter:
                    ColorFilter.mode(theme.disabledColor, BlendMode.srcIn),
                width: 20,
              ),
              const SizedBox(width: 5),
              Text(
                _dateFmt.format(application.appliedOn.toLocal()),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.dividerColor,
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: CustomTextButton(
                  backgroundColor: theme.colorScheme.tertiary,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/common/solid/ic-solar_file-text-bold.svg',
                        colorFilter: ColorFilter.mode(
                          theme.scaffoldBackgroundColor,
                          BlendMode.srcIn,
                        ),
                        width: 20,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Resume',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.scaffoldBackgroundColor,
                        ),
                      ),
                    ],
                  ),
                  onClick: () => _openResume(context),
                ),
              ),
              if (showActions) ...[
                const SizedBox(width: 10),
                IconButton(
                    onPressed: onShortlist,
                    icon: const Icon(
                      Icons.check_circle_rounded,
                      color: AppPallete.successMain,
                    )),
                IconButton(
                  onPressed: onReject,
                  icon: const Icon(
                    Icons.close,
                    color: AppPallete.errorMain,
                  ),
                ),
              ]
            ],
          ),
        ],
      ),
    );
  }
}
