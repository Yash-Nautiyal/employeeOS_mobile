import 'package:employeeos/view/hiring/domain/entities/hiring_model.dart';
import 'package:employeeos/view/hiring/domain/repositories/hiring_repository.dart';

class GetHiringDashboard {
  const GetHiringDashboard(this.repository);

  final HiringRepository repository;

  Future<HiringDashboardModel> call(HiringFilterParams filters) {
    return repository.getDashboard(filters);
  }
}
