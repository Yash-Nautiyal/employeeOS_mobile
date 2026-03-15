import 'package:employeeos/core/common/components/popup/popup.dart';
import 'package:employeeos/core/common/components/popup/responsive_popup.dart';
import 'package:employeeos/core/common/components/popup/responsive_popup_item.dart';
import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';

class JobPostingCardHeader extends StatefulWidget {
  final ThemeData theme;
  final VoidCallback? onViewTap;
  final VoidCallback? onEditTap;
  final bool canEditAndDelete;

  const JobPostingCardHeader({
    super.key,
    required this.theme,
    this.onViewTap,
    this.onEditTap,
    this.canEditAndDelete = true, //HR only for own jobs, Admin for any.
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
            color: AppPallete.successMain.withOpacity(.2),
          ),
          child: Text(
            'Active',
            style: widget.theme.textTheme.labelLarge?.copyWith(
              color: AppPallete.successMain,
            ),
          ),
        ),
        Transform.scale(
          scale: .65,
          child: Switch(
            value: false,
            onChanged: (value) {},
          ),
        ),
        const Spacer(),
        Popup(
            popupAnchorKey: _popupAnchorKey,
            layerLink: _layerLink,
            popupController: _popupController,
            preferredPosition: PopupPreferredPosition.left,
            arrowOffset: 0.2,
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
                  title: 'Copy Link',
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
