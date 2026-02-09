import '../../index.dart' show FilemanagerRepository;

class LogFileActivityUsecase {
  final FilemanagerRepository repository;

  const LogFileActivityUsecase(this.repository);

  Future<void> call(String fileId) => repository.logFileActivity(fileId);
}
