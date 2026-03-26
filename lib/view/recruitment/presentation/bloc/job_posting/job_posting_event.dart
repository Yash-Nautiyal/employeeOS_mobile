part of 'job_posting_bloc.dart';

sealed class JobPostingEvent extends Equatable {
  const JobPostingEvent();

  @override
  List<Object> get props => [];
}

class GetJobDepartmentsEvent extends JobPostingEvent {
  final List<String> departments;

  const GetJobDepartmentsEvent(this.departments);

  @override
  List<Object> get props => [departments];
}
