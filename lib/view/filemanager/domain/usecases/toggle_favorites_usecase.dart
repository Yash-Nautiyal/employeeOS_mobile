import '../../index.dart' show  FilemanagerRepository;

class ToggleFavoritesUsecase {
  final FilemanagerRepository repository;

  const ToggleFavoritesUsecase(this.repository);

  Future<void> call(String fileId, bool currentlyFavorited) {
    return repository.toggleFavoriteFile(fileId, currentlyFavorited);
  }
}
