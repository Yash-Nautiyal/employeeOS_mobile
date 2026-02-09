part of 'filemanager_bloc.dart';

sealed class FilemanagerEvent extends Equatable {
  const FilemanagerEvent();

  @override
  List<Object> get props => [];
}

final class FilemanagerLoadingEvent extends FilemanagerEvent {}

final class ToggleFavoriteEvent extends FilemanagerEvent {
  final String fileId;

  const ToggleFavoriteEvent(this.fileId);

  @override
  List<Object> get props => [fileId];
}

final class DeleteFileEvent extends FilemanagerEvent {
  final String fileId;

  const DeleteFileEvent(this.fileId);

  @override
  List<Object> get props => [fileId];
}

final class UploadFileEvent extends FilemanagerEvent {
  final String filePath;

  const UploadFileEvent(this.filePath);

  @override
  List<Object> get props => [filePath];
}

final class UploadFilesEvent extends FilemanagerEvent {
  final List<PickedFile> pickedFiles;

  const UploadFilesEvent(this.pickedFiles);

  @override
  List<Object> get props => [pickedFiles];
}

final class UpdateTagsEvent extends FilemanagerEvent {
  final String fileId;
  final List<String> tags;

  const UpdateTagsEvent(this.fileId, this.tags);

  @override
  List<Object> get props => [fileId, tags];
}

final class AddShareParticipantEvent extends FilemanagerEvent {
  final String fileId;
  final SharedUser user;

  const AddShareParticipantEvent(this.fileId, this.user);

  @override
  List<Object> get props => [fileId, user];
}

final class UpdateSharePermissionEvent extends FilemanagerEvent {
  final String fileId;
  final String userId;
  final UserPermission permission;

  const UpdateSharePermissionEvent(this.fileId, this.userId, this.permission);

  @override
  List<Object> get props => [fileId, userId, permission];
}

final class RemoveShareParticipantEvent extends FilemanagerEvent {
  final String fileId;
  final String userId;

  const RemoveShareParticipantEvent(this.fileId, this.userId);

  @override
  List<Object> get props => [fileId, userId];
}

final class FetchAvailableUsersEvent extends FilemanagerEvent {}

final class CreateFolderEvent extends FilemanagerEvent {
  final String folderName;
  final List<String>? fileIds;

  const CreateFolderEvent(this.folderName, {this.fileIds});

  @override
  List<Object> get props => [folderName, fileIds ?? <String>[]];
}

final class DeleteFolderEvent extends FilemanagerEvent {
  final String folderId;

  const DeleteFolderEvent(this.folderId);

  @override
  List<Object> get props => [folderId];
}

/// Delete multiple files (owner only) and folders. Emits success/error when done.
final class DeleteSelectedEvent extends FilemanagerEvent {
  final List<String> fileIds;
  final List<String> folderIds;

  const DeleteSelectedEvent({
    required this.fileIds,
    required this.folderIds,
  });

  @override
  List<Object> get props => [fileIds, folderIds];
}

final class ToggleFolderFavoriteEvent extends FilemanagerEvent {
  final String folderId;
  final bool currentlyFavorited;

  const ToggleFolderFavoriteEvent(this.folderId, this.currentlyFavorited);

  @override
  List<Object> get props => [folderId, currentlyFavorited];
}

final class MoveFileToFolderEvent extends FilemanagerEvent {
  final String fileId;
  final String folderId;

  const MoveFileToFolderEvent(this.fileId, this.folderId);

  @override
  List<Object> get props => [fileId, folderId];
}

final class MoveFileToRootEvent extends FilemanagerEvent {
  final String fileId;

  const MoveFileToRootEvent(this.fileId);

  @override
  List<Object> get props => [fileId];
}

final class LogFileActivityEvent extends FilemanagerEvent {
  final String fileId;

  const LogFileActivityEvent(this.fileId);

  @override
  List<Object> get props => [fileId];
}

final class AddTagEvent extends FilemanagerEvent {
  final String fileId;
  final String tagName;
  final bool isPersonal;

  const AddTagEvent(this.fileId, this.tagName, {this.isPersonal = false});

  @override
  List<Object> get props => [fileId, tagName, isPersonal];
}

final class DeleteTagEvent extends FilemanagerEvent {
  final String fileId;
  final String tagName;
  final bool isPersonal;

  const DeleteTagEvent(this.fileId, this.tagName, {this.isPersonal = false});

  @override
  List<Object> get props => [fileId, tagName, isPersonal];
}
