import 'dart:ui';

import 'package:employeeos/core/common/actions/date_time_actions.dart';
import 'package:employeeos/core/common/actions/file_actions.dart';
import 'package:employeeos/core/common/components/custom_divider.dart';
import 'package:employeeos/core/common/components/custom_textbutton.dart';
import 'package:employeeos/core/common/components/custom_textfield.dart';
import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:employeeos/view/filemanager/domain/entities/filemanager_models.dart';
import 'package:employeeos/view/filemanager/presentation/widgets/table/table_side_menu_popup.dart';
import 'package:employeeos/view/filemanager/presentation/widgets/table/table_side_menu_sections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class FileManagerSideMenu extends StatefulWidget {
  final FolderFile file;

  const FileManagerSideMenu({super.key, required this.file});

  @override
  _FileManagerSideMenuState createState() => _FileManagerSideMenuState();
}

class _FileManagerSideMenuState extends State<FileManagerSideMenu> {
  late TextEditingController _tagsController;

  // Track expanded state for each section
  bool _isTagsExpanded = true;
  bool _isPropertiesExpanded = true;

  @override
  void initState() {
    super.initState();
    _tagsController = TextEditingController();
  }

  @override
  void dispose() {
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        // Fixed Header with Info title and star icon
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Row(
            children: [
              Text(
                'Info',
                style: theme.textTheme.displaySmall,
              ),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: SvgPicture.asset(
                  widget.file.isFavorite
                      ? 'assets/icons/common/solid/ic-eva_star-fill.svg'
                      : 'assets/icons/common/solid/ic-eva_star-outline.svg',
                  color: widget.file.isFavorite
                      ? Colors.amber
                      : theme.disabledColor,
                ),
              ),
            ],
          ),
        ),

        // Scrollable content area
        Expanded(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(
                    bottom: 90), // Space for delete button
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0)
                          .copyWith(top: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Large file icon
                          SvgPicture.asset(
                            getFileIcon(widget.file.fileType ?? ""),
                            width: 60,
                          ),
                          const SizedBox(height: 16),
                          // File name
                          Text(
                            widget.file.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20)
                          .copyWith(top: 25, bottom: 10),
                      child: CustomDivider(
                        color: theme.dividerColor.withAlpha(100),
                      ),
                    ),

                    // Tags section
                    TableSideMenuSections(
                      onToggle: () =>
                          setState(() => _isTagsExpanded = !_isTagsExpanded),
                      title: 'Tags',
                      theme: theme,
                      onAdd: null,
                      isExpanded: _isTagsExpanded,
                      child: CustomTextfield(
                        controller: _tagsController,
                        theme: theme,
                        hintText: '#Add a tags',
                        keyboardType: TextInputType.text,
                        onchange: (value) {},
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20)
                          .copyWith(top: 25, bottom: 10),
                      child: CustomDivider(
                        color: theme.dividerColor.withAlpha(100),
                      ),
                    ),
                    // Properties section
                    TableSideMenuSections(
                      onToggle: () => setState(
                          () => _isPropertiesExpanded = !_isPropertiesExpanded),
                      title: 'Properties',
                      theme: theme,
                      onAdd: null,
                      isExpanded: _isPropertiesExpanded,
                      child: Column(
                        children: [
                          _buildPropertyRow(theme, 'Size',
                              formatFileSize(widget.file.size ?? 0)),
                          const SizedBox(height: 12),
                          _buildPropertyRow(theme, 'Modified',
                              '${fmtDate(widget.file.createdAt)} ${fmtTime(widget.file.createdAt)}'),
                          const SizedBox(height: 12),
                          _buildPropertyRow(
                              theme,
                              'Type',
                              widget.file.isFolder
                                  ? 'Folder'
                                  : (widget.file.fileType?.toUpperCase() ??
                                      'Unknown')),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20)
                          .copyWith(top: 25, bottom: 10),
                      child: CustomDivider(
                        color: theme.dividerColor.withAlpha(100),
                      ),
                    ),
                    // Share with section - permanently visible
                    _buildPermanentSection(
                      theme: theme,
                      title: 'Share with',
                      onAdd: () {},
                      child: Column(
                        children: [
                          // Display shared users
                          if (widget.file.sharedWith != null &&
                              widget.file.sharedWith!.isNotEmpty)
                            ...widget.file.sharedWith!
                                .map((user) => _buildSharedUserRow(theme, user))
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Fixed Delete button at bottom
              Align(
                alignment: Alignment.bottomCenter,
                child: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Container(
                        width: double.infinity,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppPallete.errorLighter,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CustomTextButton(
                          onClick: () {
                            // Handle delete logic
                            Navigator.of(context).pop();
                          },
                          backgroundColor: AppPallete.errorLighter,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/icons/common/solid/ic-solar_trash-bin-trash-bold.svg',
                                color: theme.colorScheme.error,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Delete',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: theme.colorScheme.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPermanentSection({
    required ThemeData theme,
    required String title,
    required Widget child,
    VoidCallback? onAdd,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        children: [
          // Header - not clickable, always visible
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (onAdd != null) ...[
                  GestureDetector(
                    onTap: onAdd,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: AppPallete.successMain,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Content - always visible
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyRow(ThemeData theme, String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildSharedUserRow(ThemeData theme, SharedUser user) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: theme.dividerColor,
            backgroundImage: NetworkImage(user.avatarUrl),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(color: theme.colorScheme.tertiary),
                ),
                Text(
                  user.email,
                  style: theme.textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TableSideMenuPopup(
              theme: theme,
              user: user,
              handlePermissionChange: _handlePermissionChange,
              handleRemoveUser: _handleRemoveUser),
        ],
      ),
    );
  }

  void _handlePermissionChange(SharedUser user, UserPermission newPermission) {}

  void _handleRemoveUser(SharedUser user) {}
}
