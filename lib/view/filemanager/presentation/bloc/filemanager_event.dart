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
