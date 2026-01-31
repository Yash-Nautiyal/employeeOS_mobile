import 'dart:async';

import 'package:bloc/bloc.dart';
import '../../index.dart'
    show
        AddShareParticipantUsecase,
        DeleteFileUsecase,
        FetchFilesUsecase,
        FolderFile,
        PickedFile,
        RemoveShareParticipantUsecase,
        SharedUser,
        ToggleFavoritesUsecase,
        UpdateSharePermissionUsecase,
        UpdateTagsUsecase,
        UploadFilesUsecase,
        UserPermission;
import 'package:equatable/equatable.dart';

part 'filemanager_event.dart';
part 'filemanager_state.dart';

class FilemanagerBloc extends Bloc<FilemanagerEvent, FilemanagerState> {
  final FetchFilesUsecase fetchFileUsecase;
  final ToggleFavoritesUsecase toggleFavoritesUsecase;
  final UploadFilesUsecase uploadFilesUsecase;
  final DeleteFileUsecase deleteFileUsecase;
  final UpdateTagsUsecase updateTagsUsecase;
  final AddShareParticipantUsecase addShareParticipantUsecase;
  final UpdateSharePermissionUsecase updateSharePermissionUsecase;
  final RemoveShareParticipantUsecase removeShareParticipantUsecase;

  FilemanagerBloc({
    required this.fetchFileUsecase,
    required this.toggleFavoritesUsecase,
    required this.uploadFilesUsecase,
    required this.deleteFileUsecase,
    required this.updateTagsUsecase,
    required this.addShareParticipantUsecase,
    required this.updateSharePermissionUsecase,
    required this.removeShareParticipantUsecase,
  }) : super(FilemanagerInitial()) {
    on<FilemanagerLoadingEvent>(_filemanagerLoadingEvent);
    on<ToggleFavoriteEvent>(_toggleFavoriteEvent);
    on<UploadFilesEvent>(_uploadFilesEvent);
    on<DeleteFileEvent>(_deleteFileEvent);
    on<UpdateTagsEvent>(_updateTagsEvent);
    on<AddShareParticipantEvent>(_addShareParticipantEvent);
    on<UpdateSharePermissionEvent>(_updateSharePermissionEvent);
    on<RemoveShareParticipantEvent>(_removeShareParticipantEvent);
  }

  FutureOr<void> _filemanagerLoadingEvent(
      FilemanagerLoadingEvent event, Emitter<FilemanagerState> emit) async {
    emit(FilemanagerLoading());
    try {
      final files = await fetchFileUsecase.fetchFoldersFiles();
      emit(FilemanagerLoaded(files));
    } catch (e) {
      emit(FilemanagerError(e.toString()));
    }
  }

  FutureOr<void> _toggleFavoriteEvent(
      ToggleFavoriteEvent event, Emitter<FilemanagerState> emit) async {
    try {
      if (state is FilemanagerLoaded) {
        final updatedFile = await toggleFavoritesUsecase.call(event.fileId);
        final currentState = state as FilemanagerLoaded;
        emit(currentState.copyWith(
            files: currentState.files.map((file) {
          if (file.id == event.fileId) {
            return updatedFile;
          }
          return file;
        }).toList()));
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  FutureOr<void> _uploadFilesEvent(
      UploadFilesEvent event, Emitter<FilemanagerState> emit) async {
    if (event.pickedFiles.isEmpty) return;
    try {
      final newFiles = await uploadFilesUsecase.call(event.pickedFiles);
      if (state is FilemanagerLoaded) {
        final currentState = state as FilemanagerLoaded;
        emit(currentState.copyWith(
          files: [...currentState.files, ...newFiles],
        ));
      }
    } catch (e) {
      emit(FilemanagerErrorActionState(e.toString()));
    }
  }

  FutureOr<void> _deleteFileEvent(
      DeleteFileEvent event, Emitter<FilemanagerState> emit) async {
    try {
      await deleteFileUsecase.call(event.fileId);
      if (state is FilemanagerLoaded) {
        final currentState = state as FilemanagerLoaded;
        emit(currentState.copyWith(
          files: currentState.files.where((f) => f.id != event.fileId).toList(),
        ));
      }
    } catch (e) {
      emit(FilemanagerErrorActionState(e.toString()));
    }
  }

  FutureOr<void> _updateTagsEvent(
      UpdateTagsEvent event, Emitter<FilemanagerState> emit) async {
    try {
      if (state is! FilemanagerLoaded) return;
      final updated = await updateTagsUsecase.call(event.fileId, event.tags);
      final currentState = state as FilemanagerLoaded;
      emit(currentState.copyWith(
        files: currentState.files
            .map((f) => f.id == event.fileId ? updated : f)
            .toList(),
      ));
    } catch (e) {
      emit(FilemanagerErrorActionState(e.toString()));
    }
  }

  FutureOr<void> _addShareParticipantEvent(
      AddShareParticipantEvent event, Emitter<FilemanagerState> emit) async {
    try {
      if (state is! FilemanagerLoaded) return;
      final updated =
          await addShareParticipantUsecase.call(event.fileId, event.user);
      final currentState = state as FilemanagerLoaded;
      emit(currentState.copyWith(
        files: currentState.files
            .map((f) => f.id == event.fileId ? updated : f)
            .toList(),
      ));
    } catch (e) {
      emit(FilemanagerErrorActionState(e.toString()));
    }
  }

  FutureOr<void> _updateSharePermissionEvent(
      UpdateSharePermissionEvent event, Emitter<FilemanagerState> emit) async {
    try {
      if (state is! FilemanagerLoaded) return;
      final updated = await updateSharePermissionUsecase.call(
          event.fileId, event.userId, event.permission);
      final currentState = state as FilemanagerLoaded;
      emit(currentState.copyWith(
        files: currentState.files
            .map((f) => f.id == event.fileId ? updated : f)
            .toList(),
      ));
    } catch (e) {
      emit(FilemanagerErrorActionState(e.toString()));
    }
  }

  FutureOr<void> _removeShareParticipantEvent(
      RemoveShareParticipantEvent event, Emitter<FilemanagerState> emit) async {
    try {
      if (state is! FilemanagerLoaded) return;
      final updated =
          await removeShareParticipantUsecase.call(event.fileId, event.userId);
      final currentState = state as FilemanagerLoaded;
      emit(currentState.copyWith(
        files: currentState.files
            .map((f) => f.id == event.fileId ? updated : f)
            .toList(),
      ));
    } catch (e) {
      emit(FilemanagerErrorActionState(e.toString()));
    }
  }
}
