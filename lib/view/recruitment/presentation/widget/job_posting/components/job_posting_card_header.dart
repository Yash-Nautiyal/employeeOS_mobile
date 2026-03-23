import 'package:employeeos/core/index.dart'
    show
        Popup,
        AppPallete,
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

  const JobPostingCardHeader({
    super.key,
    required this.theme,
    this.onViewTap,
    this.onEditTap,
    this.canEditAndDelete = true, //HR only for own jobs, Admin for any.
    this.isActive = true,
    this.onActiveChanged,
  });

  @override
  State<JobPostingCardHeader> createState() => _JobPostingCardHeaderState();
}

class _JobPostingCardHeaderState extends State<JobPostingCardHeader> {
  final GlobalKey _popupAnchorKey = GlobalKey();
  final LayerLink _layerLink = LayerLink();
  final ResponsivePopupController _popupController =
      ResponsivePopupController();

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
            widget.isActive ? 'Active' : 'InActive',
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
            arrowOffset: widget.canEditAndDelete ? 0.2 : 0.5,
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0)
                    .copyWith(top: 10),
                child: ResponsivePopupItem(
                  title: 'Close Job',
                  svgIcon: 'assets/icons/common/solid/ic-solar-lock-bold.svg',
                  onTap: () {},
                  color: AppPallete.warningMain,
                ),
              ),
              if (widget.canEditAndDelete) DestructivePopupItem(onTap: () {}),
            ])
      ],
    );
  }
}
