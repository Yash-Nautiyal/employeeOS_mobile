import 'package:employeeos/view/recruitment/data/interview_scheduling/datasources/interview_scheduling_remote_datasource.dart';
import 'package:employeeos/view/recruitment/data/interview_scheduling/repositories/interview_scheduling_repository_impl.dart';
import 'package:employeeos/view/recruitment/domain/index.dart'
    show GetInterviewCandidatesUseCase;

import '../../bloc/interview_scheduling/interview_scheduling_bloc.dart';

/// Wires interview scheduling data layer (Supabase) for the presentation tree.
class InterviewSchedulingInjection {
  InterviewSchedulingInjection._();

  static InterviewSchedulingBloc createBloc() {
    final remote = InterviewSchedulingRemoteDatasource();
    final repository = InterviewSchedulingRepositoryImpl(remote);
    return InterviewSchedulingBloc(
      getInterviewCandidatesUseCase: GetInterviewCandidatesUseCase(repository),
      repository: repository,
    );
  }
}
