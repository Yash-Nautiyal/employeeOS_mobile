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
  final List<FilemanagerItem> items;
  final List<SharedUser>? availableUsers;
  final List<String>? recentFileIds;

  const FilemanagerLoaded(this.items,
      {this.availableUsers, this.recentFileIds});

  @override
  List<Object> get props =>
      [items, availableUsers ?? <SharedUser>[], recentFileIds ?? <String>[]];

  FilemanagerLoaded copyWith({
    List<FilemanagerItem>? items,
    List<SharedUser>? availableUsers,
    List<String>? recentFileIds,
  }) {
    return FilemanagerLoaded(
      items ?? this.items,
      availableUsers: availableUsers ?? this.availableUsers,
      recentFileIds: recentFileIds ?? this.recentFileIds,
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
