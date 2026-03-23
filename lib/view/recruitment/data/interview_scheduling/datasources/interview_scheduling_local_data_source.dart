import 'package:employeeos/view/recruitment/data/job_posting/datasources/job_posting_mock_datasource.dart';
import 'package:employeeos/view/recruitment/data/interview_scheduling/models/interview_candidate_model.dart';
import 'package:employeeos/view/recruitment/data/job_posting/models/job_posting_model.dart';
import 'package:employeeos/view/recruitment/domain/interview_scheduling/interview_scheduling_tabs.dart';

class InterviewSchedulingLocalDataSource {
  const InterviewSchedulingLocalDataSource();

  /// Mock candidates for the given job, distributed across scheduling rounds.
  Future<List<InterviewCandidateModel>> fetchCandidates(String jobId) async {
    final jobs = await JobPostingMockDatasource.instance.getAll();
    JobPostingModel? job;
    try {
      job = jobs.firstWhere((j) => j.id == jobId);
    } catch (_) {
      return [];
    }

    final tabs = buildInterviewSchedulingTabs(job);
    if (tabs.isEmpty) return [];

    const names = [
      'Yash Katara',
      'Lakshman Reddy Thummala',
      'Priya Sharma',
      'Rahul Kumar',
      'Anjali Gupta',
      'Vikram Singh',
      'Sneha Patel',
      'Amit Verma',
    ];
    const interviewers = [
      'Alex Chen',
      'Maria Garcia',
      'Sam Lee',
    ];

    final out = <InterviewCandidateModel>[];
    for (var i = 0; i < names.length; i++) {
      final tab = tabs[i % tabs.length];
      final roundId = tab.id;

      String status;
      if (roundId == InterviewSchedulingRoundIds.selected) {
        status = 'Selected';
      } else if (roundId == InterviewSchedulingRoundIds.rejected) {
        status = 'Rejected';
      } else {
        status = i.isEven ? 'Scheduled' : 'Eligible';
      }

      final base = DateTime(2025, 4, 16 - i);
      out.add(
        InterviewCandidateModel(
          id: '${jobId}_c_$i',
          name: names[i],
          jobTitle: job.title,
          applicationDate: base,
          interviewDate: base,
          jobId: jobId,
          interviewer: interviewers[i % interviewers.length],
          status: status,
          roundStageId: roundId,
        ),
      );
    }

    return out;
  }
}
