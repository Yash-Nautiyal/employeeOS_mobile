import 'package:employeeos/view/recruitment/data/job_posting/models/job_posting_model.dart';
import 'package:employeeos/view/recruitment/data/mock/job_posting_mock_data.dart';

/// Mock data source for job postings. Holds mutable in-memory list so edits
/// from [JobEditingPage] are visible in list and [JobViewPage].
/// [description] is Quill Delta JSON string.
class JobPostingMockDatasource {
  JobPostingMockDatasource._() {
    _jobs = jobPostingMockList
        .map((e) => JobPostingModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static final JobPostingMockDatasource instance = JobPostingMockDatasource._();

  late List<JobPostingModel> _jobs;

  Future<JobPostingModel?> getById(String id) async {
    try {
      return _jobs.firstWhere((j) => j.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<JobPostingModel>> getAll() async {
    return List<JobPostingModel>.from(_jobs);
  }

  /// Adds a new job posting so the UI (and department dropdown) updates.
  void add(JobPostingModel job) {
    _jobs.add(job);
  }

  /// Replaces the job with the same id. Used by [JobEditingPage] on save.
  void update(JobPostingModel job) {
    final i = _jobs.indexWhere((j) => j.id == job.id);
    if (i >= 0) _jobs[i] = job;
  }

  Future<List<String>> getJobDepartments() async {
    return _jobs.map((e) => e.department).toSet().toList();
  }

  /// Toggles whether the job is open for applications (mock persistence).
  void setJobActive(String id, bool isActive) {
    final i = _jobs.indexWhere((j) => j.id == id);
    if (i < 0) return;
    _jobs[i] = _jobs[i].copyWith(isActive: isActive);
  }
}
