import 'package:employeeos/view/hiring/domain/entities/hiring_model.dart';
import 'package:employeeos/view/hiring/domain/repositories/hiring_repository.dart';

class GetHiringJobOptions {
  const GetHiringJobOptions(this.repository);

  final HiringRepository repository;

  Future<List<JobOption>> call() {
    return repository.getJobDropdownOptions();
  }
}
