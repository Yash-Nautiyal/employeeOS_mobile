import 'package:employeeos/view/recruitment/domain/interview_scheduling/entities/interview_candidate.dart';

class InterviewCandidateModel extends InterviewCandidate {
  const InterviewCandidateModel({
    required super.id,
    required super.name,
    required super.jobTitle,
    required super.applicationDate,
    required super.interviewDate,
    required super.jobId,
    required super.interviewer,
    required super.status,
    required super.roundStageId,
  });

  factory InterviewCandidateModel.fromMap(Map<String, dynamic> map) {
    return InterviewCandidateModel(
      id: map['id'] as String,
      name: map['name'] as String,
      jobTitle: map['jobTitle'] as String,
      applicationDate: map['applicationDate'] as DateTime,
      interviewDate: map['interviewDate'] as DateTime,
      jobId: map['jobId'] as String,
      interviewer: map['interviewer'] as String,
      status: map['status'] as String,
      roundStageId: map['roundStageId'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'jobTitle': jobTitle,
      'applicationDate': applicationDate,
      'interviewDate': interviewDate,
      'jobId': jobId,
      'interviewer': interviewer,
      'status': status,
      'roundStageId': roundStageId,
    };
  }
}
