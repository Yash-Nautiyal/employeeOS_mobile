import 'package:employeeos/core/index.dart'
    show CustomDivider, fmtDate, fmtTime, formatFileSize, getFileIcon;
import 'package:employeeos/view/filemanager/presentation/widgets/side_menu/share_file_dialog_runner.dart';
import 'package:employeeos/view/filemanager/presentation/widgets/side_menu/side_menu_share_section.dart';
import 'package:employeeos/view/filemanager/presentation/widgets/side_menu/side_menu_tag_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../index.dart'
    show
        AddTagEvent,
        DeleteFileEvent,
        DeleteTagEvent,
        FileEntity,
        FileItem,
        FilemanagerBloc,
        FilemanagerItem,
        FilemanagerLoaded,
        FileRole,
        FolderItem,
        RemoveShareParticipantEvent,
        SharedUser,
        SideMenuBottom,
        SideMenuSections,
        SideMenuShareSection,
        ToggleFavoriteEvent,
        UpdateSharePermissionEvent,
        UserPermission;
import 'favorite_star_button.dart';

class FileManagerSideMenu extends StatefulWidget {
  final FilemanagerItem item;

  const FileManagerSideMenu({super.key, required this.item});

  @override
  _FileManagerSideMenuState createState() => _FileManagerSideMenuState();
}

class _FileManagerSideMenuState extends State<FileManagerSideMenu> {
  bool _isTagsExpanded = true;
  bool _isPropertiesExpanded = true;

  String? get _currentUserId => Supabase.instance.client.auth.currentUser?.id;

  FilemanagerItem _currentItem(FilemanagerBloc bloc) {
    final state = bloc.state;
    if (state is FilemanagerLoaded) {
      try {
        return state.items.firstWhere((i) => i.id == widget.item.id);
      } catch (_) {}
    }
    return widget.item;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<FilemanagerBloc, Object>(
      builder: (context, state) {
        final bloc = context.read<FilemanagerBloc>();
        final current = _currentItem(bloc);
        final isFile = current is FileItem;
        final file = current is FileItem ? current.file : null;
        final folder = current is FolderItem ? current.folder : null;
        final name = current.name;
        final itemId = current.id;
        final isFavorite = file?.isFavorite ?? folder?.isFavorite ?? false;
        final createdAt = current.createdAt;
        final sharedUsers = file?.sharedWith ?? const [];
        final fileRole = file?.role;
        final currentUserId = _currentUserId;

        return Column(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0)
                      .copyWith(top: MediaQuery.of(context).padding.top + 10),
              child: Row(
                children: [
                  Text(
                    'Info',
                    style: theme.textTheme.displaySmall,
                  ),
                  const Spacer(),
                  FavoriteStarButton(
                    isFavorite: isFavorite,
                    onTap: () => bloc.add(ToggleFavoriteEvent(itemId)),
                    size: 24,
                    activeColor: Colors.amber,
                    inactiveColor: theme.disabledColor,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 90),
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
                              SvgPicture.asset(
                                current.isFolder
                                    ? "assets/icons/file/ic-folder.svg"
                                    : getFileIcon(file?.fileType ?? ""),
                                width: 60,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                name,
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
                        SideMenuSections(
                          onToggle: () => setState(
                              () => _isTagsExpanded = !_isTagsExpanded),
                          title: 'Tags',
                          theme: theme,
                          onAdd: null,
                          isExpanded: _isTagsExpanded,
                          child: SideMenuTagSection(
                            theme: theme,
                            fileId: itemId,
                            tags: file?.tags ?? [],
                            role: fileRole,
                            onAddTag: (tagName, isPersonal) => bloc.add(
                                AddTagEvent(itemId, tagName,
                                    isPersonal: isPersonal)),
                            onRemoveTag: (tagName, isPersonal) => bloc.add(
                                DeleteTagEvent(itemId, tagName,
                                    isPersonal: isPersonal)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20)
                              .copyWith(top: 25, bottom: 10),
                          child: CustomDivider(
                            color: theme.dividerColor.withAlpha(100),
                          ),
                        ),
                        SideMenuSections(
                          onToggle: () => setState(() =>
                              _isPropertiesExpanded = !_isPropertiesExpanded),
                          title: 'Properties',
                          theme: theme,
                          onAdd: null,
                          isExpanded: _isPropertiesExpanded,
                          child: Column(
                            children: [
                              _buildPropertyRow(
                                  theme,
                                  'Size',
                                  isFile
                                      ? formatFileSize(file?.size ?? 0)
                                      : '${folder?.fileCount ?? 0} items'),
                              const SizedBox(height: 12),
                              _buildPropertyRow(theme, 'Modified',
                                  '${fmtDate(createdAt)} ${fmtTime(createdAt)}'),
                              const SizedBox(height: 12),
                              _buildPropertyRow(theme, 'Type',
                                  (file?.fileType?.toUpperCase() ?? 'Unknown')),
                              if (file?.role != FileRole.owner) ...[
                                const SizedBox(height: 12),
                                _buildOwnerRow(theme, file!),
                              ],
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
                        _ShareSection(
                          theme: theme,
                          title: 'Share with',
                          fileId: itemId,
                          fileRole: fileRole,
                          sharedUsers: sharedUsers,
                          currentUserId: currentUserId,
                          onAdd: () => _openShareDialog(bloc, sharedUsers),
                          onPermissionChange: (u, p) => bloc
                              .add(UpdateSharePermissionEvent(itemId, u.id, p)),
                          onRemoveUser: (u) => bloc
                              .add(RemoveShareParticipantEvent(itemId, u.id)),
                        ),
                      ],
                    ),
                  ),
                  if (_canDeleteItem(isFile, file, folder))
                    SideMenuBottom(
                      theme: theme,
                      onDelete: () {
                        bloc.add(DeleteFileEvent(itemId));
                        if (context.mounted) Navigator.of(context).pop();
                      },
                    ),
                ],
              ),
            ),
          ],
        );
      },
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

  Widget _buildOwnerRow(ThemeData theme, FileEntity file) {
    final name = file.ownerName ?? 'Owner';
    final avatarUrl = file.ownerAvatarUrl;
    final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;
    final initials = name.isNotEmpty
        ? (name.length >= 2
            ? name.substring(0, 2).toUpperCase()
            : name.substring(0, 1).toUpperCase())
        : '?';
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            'Shared by:',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
          ),
        ),
        Expanded(
          child: Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: theme.dividerColor,
                backgroundImage: hasAvatar ? NetworkImage(avatarUrl) : null,
                child: hasAvatar
                    ? null
                    : Text(
                        initials,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  name,
                  style: theme.textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Only owner can delete a file; folders are deletable by the user who owns them (list only shows own folders).
  bool _canDeleteItem(bool isFile, FileEntity? file, dynamic folder) {
    if (isFile) return file?.role == FileRole.owner;
    return folder != null;
  }

  void _openShareDialog(FilemanagerBloc bloc, List<SharedUser> sharedUsers) {
    ShareFileDialogRunner.show(
      context,
      bloc: bloc,
      sharedUsers: sharedUsers,
      fileId: widget.item.id,
    );
  }
}

/// Share section: viewer sees only their own row (Can view); owner/editor see full list; editor cannot edit own permission.
class _ShareSection extends StatelessWidget {
  const _ShareSection({
    required this.theme,
    required this.title,
    required this.fileId,
    required this.fileRole,
    required this.sharedUsers,
    required this.currentUserId,
    required this.onAdd,
    required this.onPermissionChange,
    required this.onRemoveUser,
  });

  final ThemeData theme;
  final String title;
  final String fileId;
  final FileRole? fileRole;
  final List<SharedUser> sharedUsers;
  final String? currentUserId;
  final VoidCallback onAdd;
  final void Function(SharedUser, UserPermission) onPermissionChange;
  final void Function(SharedUser) onRemoveUser;

  @override
  Widget build(BuildContext context) {
    final isViewer = fileRole == FileRole.viewer;
    final usersToShow = isViewer && currentUserId != null
        ? (sharedUsers.isNotEmpty ? sharedUsers : [_viewerSelfEntry()])
        : sharedUsers;
    return SideMenuShareSection(
      theme: theme,
      title: title,
      onAdd: isViewer ? null : onAdd,
      child: Column(
        children: [
          if (usersToShow.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'Not shared yet',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.disabledColor,
                ),
              ),
            )
          else
            ...usersToShow.map((user) => SharePropertyRow(
                  theme: theme,
                  user: user,
                  canChangePermission: isViewer
                      ? false
                      : (fileRole == FileRole.editor &&
                              currentUserId != null &&
                              user.id == currentUserId
                          ? false
                          : true),
                  handlePermissionChange: onPermissionChange,
                  handleRemoveUser: onRemoveUser,
                )),
        ],
      ),
    );
  }

  SharedUser _viewerSelfEntry() {
    final currentUser = Supabase.instance.client.auth.currentUser;
    final metadata = currentUser?.userMetadata;
    final name = (metadata?['full_name'] ?? metadata?['name'])?.toString() ??
        currentUser?.email ??
        'You';
    return SharedUser(
      id: currentUserId!,
      name: name,
      permission: UserPermission.view,
    );
  }
}
