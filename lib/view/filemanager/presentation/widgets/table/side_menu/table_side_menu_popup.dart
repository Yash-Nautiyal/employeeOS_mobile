import 'package:employeeos/core/common/actions/file_actions.dart';
import 'package:employeeos/core/common/components/custom_divider.dart';
import 'package:employeeos/core/common/components/custom_popup.dart'
    show CustomPopup;
import 'package:employeeos/core/common/components/custom_popup_menu_item.dart';
import 'package:employeeos/view/filemanager/domain/entities/files_models.dart'
    show SharedUser, UserPermission;
import 'package:flutter/material.dart';

class TableSideMenuPopup extends StatelessWidget {
  const TableSideMenuPopup(
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
  Widget build(BuildContext context) {
    return CustomPopup(
      content: Container(
        constraints: const BoxConstraints(
          maxWidth: 160,
          minWidth: 100,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PermissionMenuItem(
              text: 'Can view',
              onTap: () => handlePermissionChange(user, UserPermission.view),
              svgIcon: 'assets/icons/common/solid/ic-solar_eye-bold.svg',
              isSelected: user.permission == UserPermission.view,
            ),
            PermissionMenuItem(
              text: 'Can edit',
              onTap: () => handlePermissionChange(user, UserPermission.edit),
              svgIcon: 'assets/icons/common/solid/ic-solar_pen-bold.svg',
              isSelected: user.permission == UserPermission.edit,
            ),
            CustomDivider(
              color: theme.dividerColor,
            ),
            DestructiveMenuItem(
              text: 'Remove',
              onTap: () => handleRemoveUser(user),
            ),
          ],
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Can ${formatUserPermission(user.permission ?? UserPermission.view).toLowerCase()}',
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
