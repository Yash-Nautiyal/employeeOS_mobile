import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/index.dart';

part 'filemanager_event.dart';
part 'filemanager_state.dart';

class FilemanagerBloc extends Bloc<FilemanagerEvent, FilemanagerState> {
  final FetchFilesUsecase fetchFileUsecase;
  final GetRecentFileIdsUsecase getRecentFileIdsUsecase;
  final FetchUsersUsecase fetchUsersUsecase;
  final ToggleFavoritesUsecase toggleFavoritesUsecase;
  final ToggleFolderFavoriteUsecase toggleFolderFavoriteUsecase;
  final UploadFilesUsecase uploadFilesUsecase;
  final DeleteFileUsecase deleteFileUsecase;
  final DeleteFolderUsecase deleteFolderUsecase;
  final CreateFolderUsecase createFolderUsecase;
  final MoveFileToFolderUsecase moveFileToFolderUsecase;
  final MoveFileToRootUsecase moveFileToRootUsecase;
  final LogFileActivityUsecase logFileActivityUsecase;
  // final UpdateTagsUsecase updateTagsUsecase;
  final AddTagUsecase addTagUsecase;
  final DeleteTagUsecase deleteTagUsecase;
  final AddShareParticipantUsecase addShareParticipantUsecase;
  final UpdateSharePermissionUsecase updateSharePermissionUsecase;
  final RemoveShareParticipantUsecase removeShareParticipantUsecase;

  FilemanagerBloc({
    required this.fetchFileUsecase,
    required this.getRecentFileIdsUsecase,
    required this.fetchUsersUsecase,
    required this.toggleFavoritesUsecase,
    required this.toggleFolderFavoriteUsecase,
    required this.uploadFilesUsecase,
    required this.deleteFileUsecase,
    required this.deleteFolderUsecase,
    required this.createFolderUsecase,
    required this.moveFileToFolderUsecase,
    required this.moveFileToRootUsecase,
    required this.logFileActivityUsecase,
    // required this.updateTagsUsecase,
    required this.addTagUsecase,
    required this.deleteTagUsecase,
    required this.addShareParticipantUsecase,
    required this.updateSharePermissionUsecase,
    required this.removeShareParticipantUsecase,
  }) : super(FilemanagerInitial()) {
    on<FilemanagerLoadingEvent>(_filemanagerLoadingEvent);
    on<FetchAvailableUsersEvent>(_fetchAvailableUsersEvent);
    on<ToggleFavoriteEvent>(_toggleFavoriteEvent);
    on<ToggleFolderFavoriteEvent>(_toggleFolderFavoriteEvent);
    on<UploadFilesEvent>(_uploadFilesEvent);
    on<DeleteFileEvent>(_deleteFileEvent);
    on<DeleteFolderEvent>(_deleteFolderEvent);
    on<DeleteSelectedEvent>(_deleteSelectedEvent);
    on<CreateFolderEvent>(_createFolderEvent);
    on<MoveFileToFolderEvent>(_moveFileToFolderEvent);
    on<MoveFileToRootEvent>(_moveFileToRootEvent);
    on<LogFileActivityEvent>(_logFileActivityEvent);
    // on<UpdateTagsEvent>(_updateTagsEvent);
    on<AddTagEvent>(_addTagEvent);
    on<DeleteTagEvent>(_deleteTagEvent);
    on<AddShareParticipantEvent>(_addShareParticipantEvent);
    on<UpdateSharePermissionEvent>(_updateSharePermissionEvent);
    on<RemoveShareParticipantEvent>(_removeShareParticipantEvent);
  }

  FutureOr<void> _fetchAvailableUsersEvent(
      FetchAvailableUsersEvent event, Emitter<FilemanagerState> emit) async {
    if (state is! FilemanagerLoaded) return;
    final currentState = state as FilemanagerLoaded;
    try {
      final users = await fetchUsersUsecase.call();
      emit(currentState.copyWith(availableUsers: users));
    } catch (e) {
      emit(FilemanagerErrorActionState(e.toString()));
      emit(currentState.copyWith(availableUsers: []));
    }
  }

  FutureOr<void> _filemanagerLoadingEvent(
      FilemanagerLoadingEvent event, Emitter<FilemanagerState> emit) async {
    emit(FilemanagerLoading());
    try {
      final items = await fetchFileUsecase.fetchFoldersFiles();
      List<String> recentIds = [];
      try {
        recentIds = await getRecentFileIdsUsecase.call();
      } catch (_) {}
      emit(FilemanagerLoaded(items, recentFileIds: recentIds));
    } catch (e) {
      emit(FilemanagerErrorActionState(e.toString()));
      emit(FilemanagerError(e.toString()));
    }
  }

  FutureOr<void> _toggleFavoriteEvent(
      ToggleFavoriteEvent event, Emitter<FilemanagerState> emit) async {
    if (state is! FilemanagerLoaded) return;
    final currentState = state as FilemanagerLoaded;
    final previousItems = currentState.items;
    final targetFileItem =
        previousItems.whereType<FileItem>().cast<FileItem?>().firstWhere(
              (item) => item!.file.id == event.fileId,
              orElse: () => null,
            );
    if (targetFileItem == null) return;
    final wasFavorite = targetFileItem.file.isFavorite;

    final optimisticItems = previousItems.map((item) {
      if (item is FileItem && item.file.id == event.fileId) {
        return FileItem(item.file.copyWith(isFavorite: !item.file.isFavorite));
      }
      return item;
    }).toList();
    emit(currentState.copyWith(items: optimisticItems));
    try {
      await toggleFavoritesUsecase.call(event.fileId, wasFavorite);
    } catch (e) {
      emit(FilemanagerErrorActionState(e.toString()));
      emit(currentState.copyWith(items: previousItems));
    }
  }

  FutureOr<void> _uploadFilesEvent(
      UploadFilesEvent event, Emitter<FilemanagerState> emit) async {
    if (event.pickedFiles.isEmpty) return;
    if (state is! FilemanagerLoaded) return;
    final currentState = state as FilemanagerLoaded;
    final previousItems = currentState.items;
    try {
      final newFiles = await uploadFilesUsecase.call(event.pickedFiles);
      final newItems = newFiles.map((f) => FileItem(f)).toList();
      emit(currentState.copyWith(
        items: [...currentState.items, ...newItems],
      ));
    } catch (e) {
      emit(FilemanagerErrorActionState(e.toString()));
      emit(currentState.copyWith(items: previousItems));
    }
  }

  FutureOr<void> _deleteFileEvent(
      DeleteFileEvent event, Emitter<FilemanagerState> emit) async {
    if (state is! FilemanagerLoaded) return;
    final currentState = state as FilemanagerLoaded;
    final previousItems = currentState.items;
    try {
      await deleteFileUsecase.call(event.fileId);
      emit(currentState.copyWith(
        items: currentState.items
            .where((item) => item.id != event.fileId)
            .toList(),
      ));
    } catch (e) {
      emit(FilemanagerErrorActionState(e.toString()));
      emit(currentState.copyWith(items: previousItems));
    }
  }

  // FutureOr<void> _updateTagsEvent(
  //     UpdateTagsEvent event, Emitter<FilemanagerState> emit) async {
  //   if (state is! FilemanagerLoaded) return;
  //   final currentState = state as FilemanagerLoaded;
  //   final previousItems = currentState.items;
  //   try {
  //     await updateTagsUsecase.call(event.fileId, event.tags);
  //     final newTags = event.tags
  //         .map((s) => FileTag(tagName: s, isPersonal: false))
  //         .toList();
  //     final newItems = currentState.items.map((item) {
  //       if (item is FileItem && item.file.id == event.fileId) {
  //         return FileItem(item.file.copyWith(tags: newTags));
  //       }
  //       return item;
  //     }).toList();
  //     emit(currentState.copyWith(items: newItems));
  //   } catch (e) {
  //     emit(FilemanagerErrorActionState(e.toString()));
  //     emit(currentState.copyWith(items: previousItems));
  //   }
  // }

  FutureOr<void> _addShareParticipantEvent(
      AddShareParticipantEvent event, Emitter<FilemanagerState> emit) async {
    if (state is! FilemanagerLoaded) return;
    final currentState = state as FilemanagerLoaded;
    final previousItems = currentState.items;
    final optimisticItems = currentState.items.map((item) {
      if (item is FileItem && item.file.id == event.fileId) {
        final existing = item.file.sharedWith ?? [];
        if (existing.any((u) => u.id == event.user.id)) return item;
        return FileItem(
            item.file.copyWith(sharedWith: [...existing, event.user]));
      }
      return item;
    }).toList();
    emit(currentState.copyWith(items: optimisticItems));
    try {
      await addShareParticipantUsecase.call(event.fileId, event.user);
    } catch (e) {
      emit(FilemanagerErrorActionState(e.toString()));
      emit(currentState.copyWith(items: previousItems));
    }
  }

  FutureOr<void> _updateSharePermissionEvent(
      UpdateSharePermissionEvent event, Emitter<FilemanagerState> emit) async {
    if (state is! FilemanagerLoaded) return;
    final currentState = state as FilemanagerLoaded;
    final previousItems = currentState.items;
    final optimisticItems = currentState.items.map((item) {
      if (item is FileItem && item.file.id == event.fileId) {
        final sharedWith = item.file.sharedWith ?? [];
        final updated = sharedWith.map((u) {
          if (u.id == event.userId) {
            return u.copyWith(permission: event.permission);
          }
          return u;
        }).toList();
        return FileItem(item.file.copyWith(sharedWith: updated));
      }
      return item;
    }).toList();
    emit(currentState.copyWith(items: optimisticItems));
    try {
      await updateSharePermissionUsecase.call(
          event.fileId, event.userId, event.permission);
    } catch (e) {
      emit(FilemanagerErrorActionState(e.toString()));
      emit(currentState.copyWith(items: previousItems));
    }
  }

  FutureOr<void> _removeShareParticipantEvent(
      RemoveShareParticipantEvent event, Emitter<FilemanagerState> emit) async {
    if (state is! FilemanagerLoaded) return;
    final currentState = state as FilemanagerLoaded;
    final previousItems = currentState.items;
    final optimisticItems = currentState.items.map((item) {
      if (item is FileItem && item.file.id == event.fileId) {
        final sharedWith = item.file.sharedWith ?? [];
        final updated = sharedWith.where((u) => u.id != event.userId).toList();
        return FileItem(
            item.file.copyWith(sharedWith: updated.isEmpty ? null : updated));
      }
      return item;
    }).toList();
    emit(currentState.copyWith(items: optimisticItems));
    try {
      await removeShareParticipantUsecase.call(event.fileId, event.userId);
    } catch (e) {
      emit(FilemanagerErrorActionState(e.toString()));
      emit(currentState.copyWith(items: previousItems));
    }
  }

  FutureOr<void> _toggleFolderFavoriteEvent(
      ToggleFolderFavoriteEvent event, Emitter<FilemanagerState> emit) async {
    if (state is! FilemanagerLoaded) return;
    final currentState = state as FilemanagerLoaded;
    final previousItems = currentState.items;
    final optimisticItems = currentState.items.map((item) {
      if (item is FolderItem && item.folder.id == event.folderId) {
        return FolderItem(
            item.folder.copyWith(isFavorite: !item.folder.isFavorite));
      }
      return item;
    }).toList();
    emit(currentState.copyWith(items: optimisticItems));
    try {
      await toggleFolderFavoriteUsecase.call(
          event.folderId, event.currentlyFavorited);
    } catch (e) {
      emit(FilemanagerErrorActionState(e.toString()));
      emit(currentState.copyWith(items: previousItems));
    }
  }

  FutureOr<void> _deleteFolderEvent(
      DeleteFolderEvent event, Emitter<FilemanagerState> emit) async {
    if (state is! FilemanagerLoaded) return;
    final currentState = state as FilemanagerLoaded;
    final previousItems = currentState.items;
    try {
      await deleteFolderUsecase.call(event.folderId);
      final newItems = currentState.items
          .where((item) => item.id != event.folderId)
          .toList();
      emit(currentState.copyWith(items: newItems));
    } catch (e) {
      emit(FilemanagerErrorActionState(e.toString()));
      emit(currentState.copyWith(items: previousItems));
    }
  }

  FutureOr<void> _deleteSelectedEvent(
      DeleteSelectedEvent event, Emitter<FilemanagerState> emit) async {
    if (state is! FilemanagerLoaded) return;
    final currentState = state as FilemanagerLoaded;
    final previousItems = currentState.items;
    final fileIds = event.fileIds.toSet();
    final folderIds = event.folderIds.toSet();
    // Files that are inside a folder we're deleting: don't call deleteFile (folder delete handles them).
    final fileIdsInDeletedFolders = currentState.items
        .whereType<FileItem>()
        .where((f) =>
            f.file.folderId != null && folderIds.contains(f.file.folderId!))
        .map((f) => f.file.id)
        .toSet();
    final fileIdsToDelete =
        fileIds.where((id) => !fileIdsInDeletedFolders.contains(id)).toList();
    try {
      for (final id in fileIdsToDelete) {
        await deleteFileUsecase.call(id);
      }
      for (final id in folderIds) {
        await deleteFolderUsecase.call(id);
      }
      final newItems = currentState.items.where((item) {
        if (item is FileItem) {
          if (fileIds.contains(item.file.id)) return false;
          if (item.file.folderId != null &&
              folderIds.contains(item.file.folderId!)) {
            return false;
          }
        }
        if (item is FolderItem && folderIds.contains(item.folder.id)) {
          return false;
        }
        return true;
      }).toList();
      String message = 'Deleted ';
      if (fileIdsToDelete.isNotEmpty) {
        message +=
            '${fileIdsToDelete.length > 1 ? fileIdsToDelete.length : ''} file${(fileIdsToDelete.length > 1 ? '(s)' : '')}';
      }
      if (fileIdsToDelete.isNotEmpty && folderIds.isNotEmpty) {
        message += ' and ';
      }
      if (folderIds.isNotEmpty) {
        message +=
            '${folderIds.length > 1 ? folderIds.length : ''} folder${(folderIds.length > 1 ? '(s)' : '')}';
      }
      emit(FilemanagerSuccessActionState(message));
      emit(currentState.copyWith(items: newItems));
    } catch (e) {
      emit(FilemanagerErrorActionState(e.toString()));
      emit(currentState.copyWith(items: previousItems));
    }
  }

  FutureOr<void> _createFolderEvent(
      CreateFolderEvent event, Emitter<FilemanagerState> emit) async {
    if (state is! FilemanagerLoaded) return;
    final currentState = state as FilemanagerLoaded;
    final previousItems = currentState.items;
    try {
      final folder = await createFolderUsecase.call(event.folderName,
          fileIds: event.fileIds);
      final newItem = FolderItem(folder);
      final fileIds = event.fileIds?.toSet() ?? <String>{};
      // Move files into the new folder in state so they disappear from root and show inside the folder.
      final updatedItems = currentState.items.map<FilemanagerItem>((item) {
        if (item is FileItem && fileIds.contains(item.file.id)) {
          return FileItem(item.file.copyWith(folderId: folder.id));
        }
        return item;
      }).toList();
      emit(FilemanagerSuccessActionState('Folder created'));
      emit(currentState.copyWith(
        items: [...updatedItems, newItem],
      ));
    } catch (e) {
      emit(FilemanagerErrorActionState(e.toString()));
      emit(currentState.copyWith(items: previousItems));
    }
  }

  FutureOr<void> _moveFileToFolderEvent(
      MoveFileToFolderEvent event, Emitter<FilemanagerState> emit) async {
    if (state is! FilemanagerLoaded) return;
    final currentState = state as FilemanagerLoaded;
    final previousItems = currentState.items;
    final fileIdsSet = event.fileIds.toSet();
    final optimisticItems = currentState.items.map<FilemanagerItem>((item) {
      if (item is FileItem && fileIdsSet.contains(item.file.id)) {
        return FileItem(item.file.copyWith(folderId: event.folderId));
      }
      return item;
    }).toList();
    try {
      for (final fileId in event.fileIds) {
        await moveFileToFolderUsecase.call(fileId, event.folderId);
      }
      final message = event.fileIds.length == 1
          ? 'File added to folder'
          : 'Files added to folder';
      emit(FilemanagerSuccessActionState(message));
      emit(currentState.copyWith(items: optimisticItems));
    } catch (e) {
      emit(FilemanagerErrorActionState(e.toString()));
      emit(currentState.copyWith(items: previousItems));
    }
  }

  FutureOr<void> _moveFileToRootEvent(
      MoveFileToRootEvent event, Emitter<FilemanagerState> emit) async {
    if (state is! FilemanagerLoaded) return;
    final currentState = state as FilemanagerLoaded;
    final previousItems = currentState.items;
    final optimisticItems = currentState.items.map((item) {
      if (item is FileItem && item.file.id == event.fileId) {
        return FileItem(item.file.copyWith(folderId: null));
      }
      return item;
    }).toList();
    emit(currentState.copyWith(items: optimisticItems));
    try {
      await moveFileToRootUsecase.call(event.fileId);
    } catch (e) {
      emit(FilemanagerErrorActionState(e.toString()));
      emit(currentState.copyWith(items: previousItems));
    }
  }

  FutureOr<void> _logFileActivityEvent(
      LogFileActivityEvent event, Emitter<FilemanagerState> emit) async {
    try {
      await logFileActivityUsecase.call(event.fileId);
    } catch (e) {
      if (state is FilemanagerLoaded) {
        emit(FilemanagerErrorActionState(e.toString()));
      }
    }
  }

  FutureOr<void> _addTagEvent(
      AddTagEvent event, Emitter<FilemanagerState> emit) async {
    if (state is! FilemanagerLoaded) return;
    final currentState = state as FilemanagerLoaded;
    final previousItems = currentState.items;
    try {
      await addTagUsecase.call(event.fileId, event.tagName,
          isPersonal: event.isPersonal);
      final newTag =
          FileTag(tagName: event.tagName, isPersonal: event.isPersonal);
      final newItems = currentState.items.map((item) {
        if (item is FileItem && item.file.id == event.fileId) {
          final tags = item.file.tags ?? [];
          if (tags.any((t) =>
              t.tagName == event.tagName && t.isPersonal == event.isPersonal)) {
            return item;
          }
          return FileItem(item.file.copyWith(tags: [...tags, newTag]));
        }
        return item;
      }).toList();
      emit(currentState.copyWith(items: newItems));
    } catch (e) {
      emit(FilemanagerErrorActionState(e.toString()));
      emit(currentState.copyWith(items: previousItems));
    }
  }

  FutureOr<void> _deleteTagEvent(
      DeleteTagEvent event, Emitter<FilemanagerState> emit) async {
    if (state is! FilemanagerLoaded) return;
    final currentState = state as FilemanagerLoaded;
    final previousItems = currentState.items;
    final newItems = currentState.items.map((item) {
      if (item is FileItem && item.file.id == event.fileId) {
        final tags = item.file.tags ?? [];
        final updated = tags
            .where((t) => !(t.tagName == event.tagName &&
                t.isPersonal == event.isPersonal))
            .toList();
        return FileItem(item.file.copyWith(tags: updated));
      }
      return item;
    }).toList();
    emit(currentState.copyWith(items: newItems));
    try {
      await deleteTagUsecase.call(event.fileId, event.tagName,
          isPersonal: event.isPersonal);
    } catch (e) {
      emit(FilemanagerErrorActionState(e.toString()));
      emit(currentState.copyWith(items: previousItems));
    }
  }
}
