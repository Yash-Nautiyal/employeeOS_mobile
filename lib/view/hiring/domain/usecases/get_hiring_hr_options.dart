import 'package:employeeos/view/hiring/domain/entities/hiring_model.dart';
import 'package:employeeos/view/hiring/domain/repositories/hiring_repository.dart';

class GetHiringHrOptions {
  const GetHiringHrOptions(this.repository);

  final HiringRepository repository;

  Future<List<HrOption>> call() {
    return repository.getHrDropdownOptions();
  }
}
