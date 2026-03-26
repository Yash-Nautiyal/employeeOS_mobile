part of 'job_posting_bloc.dart';

sealed class JobPostingState extends Equatable {
  const JobPostingState();
  
  @override
  List<Object> get props => [];
}

final class JobPostingInitial extends JobPostingState {}

final class JobPostingDepartmentsLoaded extends JobPostingState {
  final List<String> departments;

  const JobPostingDepartmentsLoaded(this.departments);

  @override
  List<Object> get props => [departments];
}

final class JobPostingDepartmentsError extends JobPostingState {
  final String message;

  const JobPostingDepartmentsError(this.message);

  @override
  List<Object> get props => [message];
}