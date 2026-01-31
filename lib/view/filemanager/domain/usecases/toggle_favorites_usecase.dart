import '../../index.dart' show FilemanagerRepository, FolderFile;

class ToggleFavoritesUsecase {
  final FilemanagerRepository repository;

  const ToggleFavoritesUsecase(this.repository);

  Future<FolderFile> call(String fileId) {
    return repository.toggleFavoriteFile(fileId);
  }
}
