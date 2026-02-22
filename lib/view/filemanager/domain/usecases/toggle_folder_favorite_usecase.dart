import '../index.dart' show FilemanagerRepository;

class ToggleFolderFavoriteUsecase {
  final FilemanagerRepository repository;

  const ToggleFolderFavoriteUsecase(this.repository);

  Future<void> call(String folderId, bool currentlyFavorited) =>
      repository.toggleFavoriteFolder(folderId, currentlyFavorited);
}
