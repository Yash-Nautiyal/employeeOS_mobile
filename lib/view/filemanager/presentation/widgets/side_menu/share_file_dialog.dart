import 'package:employeeos/core/common/actions/file_actions.dart'
    show formatUserPermission;
import 'package:employeeos/core/common/components/ui/custom_textbutton.dart';
import 'package:employeeos/core/index.dart' show CustomDropdown;
import 'package:employeeos/view/filemanager/domain/entities/files_models.dart';
import 'package:flutter/material.dart';

class ShareFileDialog extends StatelessWidget {
  final BuildContext context;
  final ThemeData theme;
  final SharedUser? selectedUser;
  final UserPermission selectedPermission;
  final List<SharedUser> available;
  final Function(SharedUser) setSelectedUser;
  final Function(UserPermission) setSelectedPermission;
  final Function() onShare;

  /// Title shown at top of dialog. Defaults to 'Share File'.
  final String title;

  const ShareFileDialog(
      {super.key,
      required this.context,
      required this.theme,
      this.selectedUser,
      required this.selectedPermission,
      required this.available,
      required this.setSelectedUser,
      required this.setSelectedPermission,
      required this.onShare,
      this.title = 'Share File'});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            CustomDropdown(
              value: selectedUser?.name,
              theme: theme,
              label: 'Search user by name',
              isSearchable: true,
              onChange: (value) => setSelectedUser(
                available.firstWhere(
                  (user) =>
                      user.name.toLowerCase() == value.toString().toLowerCase(),
                ),
              ),
              selectedItemBuilder: (context) => available
                  .map(
                    (user) => Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        user.email,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.tertiary,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              items: available
                  .map(
                    (user) => DropdownMenuItem(
                      value: user.name,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundImage: user.avatarUrl.isNotEmpty
                                ? NetworkImage(user.avatarUrl)
                                : null,
                            child: user.avatarUrl.isEmpty
                                ? Text(
                                    user.name.isNotEmpty
                                        ? user.name
                                            .substring(0, 1)
                                            .toUpperCase()
                                        : '?',
                                    style: theme.textTheme.labelLarge,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.tertiary,
                                  ),
                                ),
                                Text(
                                  user.email,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall
                                      ?.copyWith(color: theme.disabledColor),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            CustomDropdown(
              value: selectedPermission,
              theme: theme,
              label: 'Permission',
              onChange: (value) =>
                  setSelectedPermission(value as UserPermission),
              items: UserPermission.values
                  .map(
                    (permission) => DropdownMenuItem(
                      value: permission,
                      child: Text(
                        formatUserPermission(permission),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomTextButton(
                  padding: 0,
                  onClick: () => Navigator.of(context).pop(),
                  child: Text('Close', style: theme.textTheme.labelLarge),
                ),
                const SizedBox(width: 8),
                CustomTextButton(
                  padding: 0,
                  backgroundColor: theme.colorScheme.tertiary,
                  onClick: () => selectedUser == null ? null : onShare(),
                  child: Text('Share',
                      style: theme.textTheme.labelLarge
                          ?.copyWith(color: theme.scaffoldBackgroundColor)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
