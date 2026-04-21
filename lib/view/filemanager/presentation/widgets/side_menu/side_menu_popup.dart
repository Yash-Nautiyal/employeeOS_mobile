import 'package:employeeos/core/common/actions/file_actions.dart';
import 'package:employeeos/core/common/components/ui/custom_divider.dart';
import 'package:employeeos/core/common/components/custom_popup.dart'
    show CustomPopup;
import 'package:employeeos/core/common/components/custom_popup_menu_item.dart';
import 'package:employeeos/view/filemanager/domain/entities/files_models.dart'
    show SharedUser, UserPermission;
import 'package:flutter/material.dart';

class SideMenuPopup extends StatefulWidget {
  const SideMenuPopup(
      {super.key,
      required this.theme,
      required this.user,
      required this.handlePermissionChange,
      required this.handleRemoveUser});
  final ThemeData theme;
  final SharedUser user;
  final Function(SharedUser, UserPermission) handlePermissionChange;
  final Function(SharedUser) handleRemoveUser;

  @override
  State<SideMenuPopup> createState() => _SideMenuPopupState();
}

class _SideMenuPopupState extends State<SideMenuPopup> {
  /// Local permission used to update UI immediately on tap before bloc emits.
  UserPermission? _localPermission;

  UserPermission get _effectivePermission =>
      _localPermission ?? widget.user.permission ?? UserPermission.view;

  @override
  void didUpdateWidget(SideMenuPopup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.user.permission != oldWidget.user.permission) {
      _localPermission = null;
    }
  }

  void _onPermissionTap(BuildContext context, UserPermission permission) {
    setState(() => _localPermission = permission);
    widget.handlePermissionChange(widget.user, permission);
    if (mounted && context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final user = widget.user;
    final effective = _effectivePermission;

    return CustomPopup(
      content: Container(
        constraints: const BoxConstraints(
          maxWidth: 140,
          minWidth: 100,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PermissionMenuItem(
              text: 'Can view',
              onTap: () => _onPermissionTap(context, UserPermission.view),
              svgIcon: 'assets/icons/common/solid/ic-solar_eye-bold.svg',
              isSelected: effective == UserPermission.view,
            ),
            PermissionMenuItem(
              text: 'Can edit',
              onTap: () => _onPermissionTap(context, UserPermission.edit),
              svgIcon: 'assets/icons/common/solid/ic-solar_pen-bold.svg',
              isSelected: effective == UserPermission.edit,
            ),
            CustomDivider(
              color: theme.dividerColor,
            ),
            DestructiveMenuItem(
                text: 'Remove',
                onTap: () {
                  widget.handleRemoveUser(user);
                  if (mounted && context.mounted) Navigator.of(context).pop();
                }),
          ],
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Can ${formatUserPermission(effective).toLowerCase()}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.tertiary,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.keyboard_arrow_down,
            size: 16,
            color: theme.textTheme.bodySmall?.color,
          ),
        ],
      ),
    );
  }
}
