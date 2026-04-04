import '../../mock/job_application_mock_data.dart';
import '../models/job_application_model.dart';

/// In-memory applications. Replace this class with a remote datasource later;
/// [JobApplicationRepositoryImpl] stays the same.
class JobApplicationMockDatasource {
  JobApplicationMockDatasource._() {
    _applications = jobApplicationMockList
        .map((e) => JobApplicationModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static final JobApplicationMockDatasource instance =
      JobApplicationMockDatasource._();

  late List<JobApplicationModel> _applications;

  Future<List<JobApplicationModel>> getApplications({String? jobId}) async {
    final list = List<JobApplicationModel>.from(_applications);
    if (jobId == null || jobId.isEmpty) return list;
    return list.where((a) => a.jobId == jobId).toList();
  }

  Future<JobApplicationModel?> shortlist(String id) async {
    final i = _applications.indexWhere((a) => a.id == id);
    if (i < 0) return null;
    final current = _applications[i];
    if (current.status != 'Applied') return current;
    final updated = current.copyWith(status: 'Shortlisted');
    _applications[i] = updated;
    return updated;
  }

  Future<JobApplicationModel?> reject(String id) async {
    final i = _applications.indexWhere((a) => a.id == id);
    if (i < 0) return null;
    final current = _applications[i];
    if (current.status == 'Rejected') return current;
    final updated = current.copyWith(status: 'Rejected');
    _applications[i] = updated;
    return updated;
  }
}
