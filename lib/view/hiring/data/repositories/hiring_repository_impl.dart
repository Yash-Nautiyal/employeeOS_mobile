import 'package:employeeos/view/hiring/data/datasources/hiring_remote_datasource.dart';
import 'package:employeeos/view/hiring/data/models/hiring_dashboard_model.dart';
import 'package:employeeos/view/hiring/domain/entities/hiring_model.dart';
import 'package:employeeos/view/hiring/domain/repositories/hiring_repository.dart';

class HiringRepositoryImpl implements HiringRepository {
  HiringRepositoryImpl(this._datasource);

  final HiringRemoteDatasource _datasource;

  @override
  Future<HiringDashboardModel> getDashboard(HiringFilterParams filters) async {
    final raw = await _datasource.fetchDashboard(filters);
    return HiringDashboardDto.fromJson(raw).toEntity();
  }

  @override
  Future<List<JobOption>> getJobDropdownOptions() async {
    final rows = await _datasource.fetchJobDropdownOptions();
    return rows
        .map((row) => JobOptionDto.fromJson(row).toEntity())
        .where((row) => row.id.isNotEmpty)
        .toList();
  }

  @override
  Future<List<HrOption>> getHrDropdownOptions() async {
    final rows = await _datasource.fetchHrDropdownOptions();
    return rows
        .map((row) => HrOptionDto.fromJson(row).toEntity())
        .where((row) => row.id.isNotEmpty)
        .toList();
  }
}
