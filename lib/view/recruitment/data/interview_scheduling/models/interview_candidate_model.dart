import '../../../domain/index.dart' show InterviewCandidate, InterviewRound;

class InterviewCandidateModel extends InterviewCandidate {
  const InterviewCandidateModel({
    required super.id,
    required super.name,
    required super.email,
    required super.jobTitle,
    required super.applicationDate,
    required super.interviewDate,
    required super.jobId,
    required super.interviewer,
    required super.status,
    required super.pipelineRound,
    super.rejectedFromRound,
  });

  factory InterviewCandidateModel.fromMap(Map<String, dynamic> map) {
    return InterviewCandidateModel(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      jobTitle: map['jobTitle'] as String,
      applicationDate: map['applicationDate'] as DateTime,
      interviewDate: map['interviewDate'] as DateTime,
      jobId: map['jobId'] as String,
      interviewer: map['interviewer'] as String,
      status: map['status'] as String,
      pipelineRound: map['pipelineRound'] as InterviewRound,
      rejectedFromRound: map['rejectedFromRound'] as InterviewRound?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'jobTitle': jobTitle,
      'applicationDate': applicationDate,
      'interviewDate': interviewDate,
      'jobId': jobId,
      'interviewer': interviewer,
      'status': status,
      'pipelineRound': pipelineRound,
      'rejectedFromRound': rejectedFromRound,
    };
  }

  InterviewCandidateModel copyWith({
    String? id,
    String? name,
    String? email,
    String? jobTitle,
    DateTime? applicationDate,
    DateTime? interviewDate,
    String? jobId,
    String? interviewer,
    String? status,
    InterviewRound? pipelineRound,
    InterviewRound? rejectedFromRound,
    bool clearRejectedFromRound = false,
  }) {
    return InterviewCandidateModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      jobTitle: jobTitle ?? this.jobTitle,
      applicationDate: applicationDate ?? this.applicationDate,
      interviewDate: interviewDate ?? this.interviewDate,
      jobId: jobId ?? this.jobId,
      interviewer: interviewer ?? this.interviewer,
      status: status ?? this.status,
      pipelineRound: pipelineRound ?? this.pipelineRound,
      rejectedFromRound: clearRejectedFromRound
          ? null
          : (rejectedFromRound ?? this.rejectedFromRound),
    );
  }
}
