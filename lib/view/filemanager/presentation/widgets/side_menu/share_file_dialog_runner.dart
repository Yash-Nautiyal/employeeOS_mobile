import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../index.dart'
    show
        AddShareParticipantEvent,
        FetchAvailableUsersEvent,
        FilemanagerBloc,
        FilemanagerErrorActionState,
        FilemanagerLoaded,
        FilemanagerState,
        SharedUser,
        UserPermission;
import 'share_file_dialog.dart';

/// Result returned when the user confirms sharing in [ShareFileDialogRunner].
class ShareDialogResult {
  const ShareDialogResult({
    required this.user,
    required this.permission,
  });

  final SharedUser user;
  final UserPermission permission;
}

/// Widget that builds the share-file dialog content (loading or [ShareFileDialog]).
/// Use [show] for a single file or [showMultiple] for multiple files.
class ShareFileDialogRunner extends StatefulWidget {
  const ShareFileDialogRunner({
    super.key,
    required this.bloc,
    required this.sharedUsers,
    required this.fileIds,
    this.ownerIdsToExclude = const [],
  });

  final FilemanagerBloc bloc;
  final List<SharedUser> sharedUsers;

  /// File IDs to share with the selected user. One for single-file, multiple for bulk.
  final List<String> fileIds;

  /// User IDs to exclude from the list (e.g. file owner — cannot share with owner).
  final List<String> ownerIdsToExclude;

  /// Shows the share dialog for a single file.
  static Future<void> show(
    BuildContext context, {
    required FilemanagerBloc bloc,
    required List<SharedUser> sharedUsers,
    required String fileId,
    String? ownerId,
  }) async {
    await showMultiple(
      context,
      bloc: bloc,
      fileIds: [fileId],
      existingSharedUsers: sharedUsers,
      ownerIdsToExclude: ownerId != null ? [ownerId] : null,
    );
  }

  /// Shows the share dialog for multiple files. Title: "Share these N files with".
  /// On confirm, dispatches [AddShareParticipantEvent] for each file.
  static Future<void> showMultiple(
    BuildContext context, {
    required FilemanagerBloc bloc,
    required List<String> fileIds,
    List<SharedUser> existingSharedUsers = const [],
    List<String>? ownerIdsToExclude,
  }) async {
    if (fileIds.isEmpty) return;
    bloc.add(FetchAvailableUsersEvent());
    final result = await showDialog<ShareDialogResult>(
      context: context,
      builder: (dialogContext) {
        return BlocProvider<FilemanagerBloc>.value(
          value: bloc,
          child: ShareFileDialogRunner(
            bloc: bloc,
            sharedUsers: existingSharedUsers,
            fileIds: fileIds,
            ownerIdsToExclude: ownerIdsToExclude ?? const [],
          ),
        );
      },
    );
    if (result == null) return;
    final userWithPermission = SharedUser(
      id: result.user.id,
      name: result.user.name,
      email: result.user.email,
      avatarUrl: result.user.avatarUrl,
      permission: result.permission,
    );
    for (final fileId in fileIds) {
      bloc.add(AddShareParticipantEvent(fileId, userWithPermission));
    }
  }

  @override
  State<ShareFileDialogRunner> createState() => _ShareFileDialogRunnerState();
}

class _ShareFileDialogRunnerState extends State<ShareFileDialogRunner> {
  SharedUser? _selectedUser;
  UserPermission _selectedPermission = UserPermission.view;

  static List<SharedUser> _availableUsersForShare(
    FilemanagerState state,
    List<SharedUser> sharedUsers,
    List<String> ownerIdsToExclude,
  ) {
    final list = <SharedUser>[];
    if (state is FilemanagerLoaded && state.availableUsers != null) {
      list.addAll(state.availableUsers!);
    }
    final excludeIds = {...ownerIdsToExclude};
    return list
        .where((u) =>
            !sharedUsers.any((s) => s.id == u.id) && !excludeIds.contains(u.id))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<FilemanagerBloc, FilemanagerState>(
      buildWhen: (previous, current) =>
          current is FilemanagerLoaded ||
          current is FilemanagerErrorActionState,
      builder: (context, state) {
        final available = _availableUsersForShare(
          state,
          widget.sharedUsers,
          widget.ownerIdsToExclude,
        );
        final isLoading =
            state is FilemanagerLoaded && state.availableUsers == null;

        if (isLoading) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Loading users…',
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          );
        }

        final title = widget.fileIds.length == 1
            ? 'Share File'
            : 'Share ${widget.fileIds.length} files with';
        return ShareFileDialog(
          context: context,
          theme: theme,
          title: title,
          selectedUser: _selectedUser,
          selectedPermission: _selectedPermission,
          available: available,
          setSelectedUser: (value) {
            setState(() => _selectedUser = value);
          },
          setSelectedPermission: (value) {
            setState(() => _selectedPermission = value);
          },
          onShare: () {
            Navigator.of(context).pop(
              ShareDialogResult(
                user: _selectedUser!,
                permission: _selectedPermission,
              ),
            );
          },
        );
      },
    );
  }
}
