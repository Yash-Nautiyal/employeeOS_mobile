import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:employeeos/view/recruitment/domain/job_posting/usecases/get_job_department.dart';
import 'package:equatable/equatable.dart';

part 'job_posting_event.dart';
part 'job_posting_state.dart';

class JobPostingBloc extends Bloc<JobPostingEvent, JobPostingState> {
  final GetJobDepartmentUseCase getJobDepartmentUseCase;
  JobPostingBloc({
    required this.getJobDepartmentUseCase,
  }) : super(JobPostingInitial()) {
    on<GetJobDepartmentsEvent>(_getJobDepartmentsEvent);
  }

  FutureOr<void> _getJobDepartmentsEvent(
      GetJobDepartmentsEvent event, Emitter<JobPostingState> emit) async {
    try {
      final departments = await getJobDepartmentUseCase.call();
      emit(JobPostingDepartmentsLoaded(departments));
    } catch (e) {
      emit(JobPostingDepartmentsError(e.toString()));
    }
  }
}
