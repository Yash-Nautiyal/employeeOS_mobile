import 'package:employeeos/core/common/components/custom_tags_field.dart';
import 'package:employeeos/core/index.dart'
    show CustomDivider, fmtDate, fmtTime, formatFileSize, getFileIcon;
import 'package:employeeos/view/filemanager/presentation/widgets/table/side_menu/table_side_menu_share_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:textfield_tags/textfield_tags.dart';

import '../../../index.dart'
    show
        AddShareParticipantEvent,
        DeleteFileEvent,
        FilemanagerBloc,
        FilemanagerLoaded,
        FolderFile,
        RemoveShareParticipantEvent,
        ShareFileDialog,
        SharedUser,
        TableSideMenuBottom,
        TableSideMenuSections,
        TableSideMenuShareSection,
        ToggleFavoriteEvent,
        UpdateSharePermissionEvent,
        UpdateTagsEvent,
        UserPermission,
        mockShareUsers;

class FileManagerSideMenu extends StatefulWidget {
  final FolderFile file;

  const FileManagerSideMenu({super.key, required this.file});

  @override
  _FileManagerSideMenuState createState() => _FileManagerSideMenuState();
}

class _FileManagerSideMenuState extends State<FileManagerSideMenu> {
  static final List<SharedUser> _availableUsers = mockShareUsers();
  final _tagsController = StringTagController();

  bool _isTagsExpanded = true;
  bool _isPropertiesExpanded = true;

  @override
  void initState() {
    super.initState();
    widget.file.tags?.forEach((tag) => _tagsController.addTag(tag));
    _tagsController.addListener(_syncTagsToBloc);
  }

  @override
  void dispose() {
    _tagsController.removeListener(_syncTagsToBloc);
    _tagsController.dispose();
    super.dispose();
  }

  void _syncTagsToBloc() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final tags =
          (_tagsController.getTags?.map((e) => e.toString()).toList()) ?? [];
      context
          .read<FilemanagerBloc>()
          .add(UpdateTagsEvent(widget.file.id, tags));
    });
  }

  FolderFile _currentFile(FilemanagerBloc bloc) {
    final state = bloc.state;
    if (state is FilemanagerLoaded) {
      try {
        return state.files.firstWhere((f) => f.id == widget.file.id);
      } catch (_) {}
    }
    return widget.file;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<FilemanagerBloc, Object>(
      builder: (context, state) {
        final bloc = context.read<FilemanagerBloc>();
        final file = _currentFile(bloc);
        final sharedUsers = file.sharedWith ?? const [];

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
                  IconButton(
                    onPressed: () => bloc.add(
                      ToggleFavoriteEvent(file.id),
                    ),
                    icon: SvgPicture.asset(
                      file.isFavorite
                          ? 'assets/icons/common/solid/ic-eva_star-fill.svg'
                          : 'assets/icons/common/solid/ic-eva_star-outline.svg',
                      color:
                          file.isFavorite ? Colors.amber : theme.disabledColor,
                    ),
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
                                getFileIcon(file.fileType ?? ""),
                                width: 60,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                file.name,
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
                        TableSideMenuSections(
                          onToggle: () => setState(
                              () => _isTagsExpanded = !_isTagsExpanded),
                          title: 'Tags',
                          theme: theme,
                          onAdd: null,
                          isExpanded: _isTagsExpanded,
                          child: CustomTagsField(
                            stringTagController: _tagsController,
                            theme: theme,
                            initialTags: file.tags ?? [],
                            hintText: '#Add a tags',
                            labelText: null,
                            floatingLabelBehavior: FloatingLabelBehavior.auto,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20)
                              .copyWith(top: 25, bottom: 10),
                          child: CustomDivider(
                            color: theme.dividerColor.withAlpha(100),
                          ),
                        ),
                        TableSideMenuSections(
                          onToggle: () => setState(() =>
                              _isPropertiesExpanded = !_isPropertiesExpanded),
                          title: 'Properties',
                          theme: theme,
                          onAdd: null,
                          isExpanded: _isPropertiesExpanded,
                          child: Column(
                            children: [
                              _buildPropertyRow(theme, 'Size',
                                  formatFileSize(file.size ?? 0)),
                              const SizedBox(height: 12),
                              _buildPropertyRow(theme, 'Modified',
                                  '${fmtDate(file.createdAt)} ${fmtTime(file.createdAt)}'),
                              const SizedBox(height: 12),
                              _buildPropertyRow(
                                  theme,
                                  'Type',
                                  file.isFolder
                                      ? 'Folder'
                                      : (file.fileType?.toUpperCase() ??
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
                        TableSideMenuShareSection(
                          theme: theme,
                          title: 'Share with',
                          onAdd: () => _openShareDialog(bloc, sharedUsers),
                          child: Column(
                            children: [
                              if (sharedUsers.isNotEmpty)
                                ...sharedUsers.map((user) => SharePropertyRow(
                                      theme: theme,
                                      user: user,
                                      handlePermissionChange: (u, p) =>
                                          bloc.add(UpdateSharePermissionEvent(
                                              file.id, u.id, p)),
                                      handleRemoveUser: (u) => bloc.add(
                                          RemoveShareParticipantEvent(
                                              file.id, u.id)),
                                    )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  TableSideMenuBottom(
                    theme: theme,
                    onDelete: () {
                      bloc.add(DeleteFileEvent(file.id));
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

  void _openShareDialog(FilemanagerBloc bloc, List<SharedUser> sharedUsers) {
    final theme = Theme.of(context);
    final available = _availableUsers
        .where((u) => !sharedUsers.any((s) => s.email == u.email))
        .toList();

    showDialog<_ShareDialogResult>(
      context: context,
      builder: (dialogContext) {
        SharedUser? selectedUser;
        UserPermission selectedPermission = UserPermission.view;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return ShareFileDialog(
              context: dialogContext,
              theme: theme,
              selectedUser: selectedUser,
              selectedPermission: selectedPermission,
              available: available,
              setSelectedUser: (value) {
                setDialogState(() {
                  selectedUser = value;
                });
              },
              setSelectedPermission: (value) {
                setDialogState(() {
                  selectedPermission = value;
                });
              },
              onShare: () {
                Navigator.of(context).pop(
                  _ShareDialogResult(
                    user: selectedUser!,
                    permission: selectedPermission,
                  ),
                );
              },
            );
          },
        );
      },
    ).then((result) {
      if (result == null) return;
      final userWithPermission = SharedUser(
        id: result.user.id,
        name: result.user.name,
        email: result.user.email,
        avatarUrl: result.user.avatarUrl,
        permission: result.permission,
      );
      bloc.add(AddShareParticipantEvent(widget.file.id, userWithPermission));
    });
  }
}

class _ShareDialogResult {
  const _ShareDialogResult({
    required this.user,
    required this.permission,
  });

  final SharedUser user;
  final UserPermission permission;
}
