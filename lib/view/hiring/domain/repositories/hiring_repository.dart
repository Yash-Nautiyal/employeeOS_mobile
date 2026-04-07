import 'package:employeeos/view/hiring/domain/entities/hiring_model.dart';

abstract class HiringRepository {
  Future<HiringDashboardModel> getDashboard(HiringFilterParams filters);
  Future<List<JobOption>> getJobDropdownOptions();
  Future<List<HrOption>> getHrDropdownOptions();
}
