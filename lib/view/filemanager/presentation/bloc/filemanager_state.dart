part of 'filemanager_bloc.dart';

sealed class FilemanagerState extends Equatable {
  const FilemanagerState();

  @override
  List<Object> get props => [];
}

sealed class FilemanagerActionState extends FilemanagerState {}

final class FilemanagerInitial extends FilemanagerState {}

final class FilemanagerLoading extends FilemanagerState {}

final class FilemanagerLoaded extends FilemanagerState {
  final List<FolderFile> files; // Example property

  const FilemanagerLoaded(this.files);

  @override
  List<Object> get props => [files];

  FilemanagerLoaded copyWith({List<FolderFile>? files}) {
    return FilemanagerLoaded(
      files ?? this.files,
    );
  }
}

final class FilemanagerError extends FilemanagerState {
  final String message;

  const FilemanagerError(this.message);

  @override
  List<Object> get props => [message];
}

final class FilemanagerErrorActionState extends FilemanagerActionState {
  final String message;

  FilemanagerErrorActionState(this.message);

  @override
  List<Object> get props => [message];
}

final class FilemanagerSuccessActionState extends FilemanagerActionState {
  final String message;

  FilemanagerSuccessActionState(this.message);

  @override
  List<Object> get props => [message];
}