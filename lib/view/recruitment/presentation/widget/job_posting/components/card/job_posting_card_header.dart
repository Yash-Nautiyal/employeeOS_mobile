import 'package:employeeos/core/common/components/popup/popup.dart';
import 'package:employeeos/core/index.dart'
    show
        AppPallete,
        CustomAlertDialog,
        CustomAlertDialogStyle,
        EditPopupItem,
        ViewPopupItem,
        ResponsivePopupItem,
        DestructivePopupItem,
        PopupPreferredPosition,
        ResponsivePopupController;
import 'package:flutter/material.dart';

class JobPostingCardHeader extends StatefulWidget {
  final ThemeData theme;
  final VoidCallback? onViewTap;
  final VoidCallback? onEditTap;
  final bool canEditAndDelete;
  final bool isActive;
  final ValueChanged<bool>? onActiveChanged;
  final VoidCallback? onCloseTap;
  final VoidCallback? onDeleteTap;

  const JobPostingCardHeader({
    super.key,
    required this.theme,
    this.onViewTap,
    this.onEditTap,
    this.canEditAndDelete = true, //HR only for own jobs, Admin for any.
    this.isActive = true,
    this.onActiveChanged,
    this.onCloseTap,
    this.onDeleteTap,
  });

  @override
  State<JobPostingCardHeader> createState() => _JobPostingCardHeaderState();
}

class _JobPostingCardHeaderState extends State<JobPostingCardHeader> {
  /// Primary action color for “close posting” confirmation (coral).
  static const Color _closePostingConfirmColor = Color(0xFFFF5733);

  final GlobalKey _popupAnchorKey = GlobalKey();
  final LayerLink _layerLink = LayerLink();
  final ResponsivePopupController _popupController =
      ResponsivePopupController();

  void _showCloseJobConfirmation() {
    if (widget.onCloseTap == null) return;
    final theme = Theme.of(context);
    showDialog<void>(
      context: context,
      builder: (ctx) => CustomAlertDialog(
        title: 'Close Job Posting?',
        content: Text(
          'Are you sure you want to close this job posting? This will make it '
          'inactive and no longer visible to applicants.',
          style: theme.textTheme.bodyMedium,
        ),
        cancelLabel: 'Cancel',
        primaryLabel: 'Yes, Close Posting',
        primaryColor: _closePostingConfirmColor,
        onCancel: () => Navigator.of(ctx).pop(),
        primaryOnTap: () {
          Navigator.of(ctx).pop();
          widget.onCloseTap?.call();
        },
      ),
    );
  }

  void _showDeleteJobConfirmation() {
    if (widget.onDeleteTap == null) return;
    final theme = Theme.of(context);
    showDialog<void>(
      context: context,
      builder: (ctx) => CustomAlertDialog(
        style: CustomAlertDialogStyle.danger,
        title: 'Delete Job Posting?',
        content: Text(
          'Are you sure you want to delete this job posting? This action cannot '
          'be undone.',
          style: theme.textTheme.bodyMedium,
        ),
        cancelLabel: 'Cancel',
        primaryLabel: 'Yes, Delete Posting',
        primaryColor: theme.colorScheme.error,
        onCancel: () => Navigator.of(ctx).pop(),
        primaryOnTap: () {
          Navigator.of(ctx).pop();
          widget.onDeleteTap?.call();
        },
      ),
    );
  }

  @override
  void dispose() {
    _popupController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = widget.theme.brightness;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 7,
            vertical: 3,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: widget.isActive
                ? AppPallete.successMain.withValues(alpha: .2)
                : widget.theme.colorScheme.errorContainer.withValues(
                    alpha: brightness == Brightness.dark ? .15 : .3),
          ),
          child: Text(
            widget.isActive ? 'Active' : 'Closed',
            style: widget.theme.textTheme.labelLarge?.copyWith(
              color: widget.isActive
                  ? AppPallete.successMain
                  : brightness == Brightness.dark
                      ? AppPallete.errorMain
                      : AppPallete.errorDarker,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Transform.scale(
          scale: .65,
          child: Switch(
            value: widget.isActive,
            onChanged: widget.canEditAndDelete && widget.onActiveChanged != null
                ? widget.onActiveChanged
                : null,
            activeTrackColor: widget.theme.colorScheme.onSurface,
          ),
        ),
        const Spacer(),
        Popup(
            popupAnchorKey: _popupAnchorKey,
            layerLink: _layerLink,
            popupController: _popupController,
            preferredPosition: PopupPreferredPosition.left,
            arrowOffset: widget.canEditAndDelete
                ? widget.isActive
                    ? 0.2
                    : 0.3
                : 0.5,
            manualOffset: const Offset(10, 0),
            arrowColor: widget.theme.brightness == Brightness.dark
                ? AppPallete.darkBackgroundGradient.colors[1]
                : AppPallete.lightBackgroundGradient.colors[1],
            icon: const Icon(Icons.more_vert_rounded),
            items: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: ViewPopupItem(onTap: () {
                  _popupController.hide();
                  widget.onViewTap?.call();
                }),
              ),
              if (widget.canEditAndDelete)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0)
                      .copyWith(top: 10),
                  child: EditPopupItem(
                    onTap: () {
                      _popupController.hide();
                      widget.onEditTap?.call();
                    },
                  ),
                ),
              if (widget.isActive)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0)
                      .copyWith(top: 10),
                  child: ResponsivePopupItem(
                    title: 'Close Job',
                    svgIcon: 'assets/icons/common/solid/ic-solar-lock-bold.svg',
                    onTap: () {
                      _popupController.hide();
                      _showCloseJobConfirmation();
                    },
                    color: AppPallete.warningMain,
                  ),
                ),
              if (widget.canEditAndDelete)
                DestructivePopupItem(onTap: () {
                  _popupController.hide();
                  _showDeleteJobConfirmation();
                }),
            ])
      ],
    );
  }
}
