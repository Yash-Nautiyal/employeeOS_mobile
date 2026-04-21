import 'package:employeeos/view/recruitment/presentation/bloc/job_posting/job_posting_bloc.dart';
import 'package:employeeos/view/recruitment/presentation/widget/injection/job_posting_injection.dart';
import 'package:employeeos/view/recruitment/presentation/widget/job_posting/job_posting_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class JobPostingPage extends StatelessWidget {
  const JobPostingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<JobPostingBloc>(
      create: (_) =>
          JobPostingInjection.createBloc()..add(const LoadJobPostingsEvent()),
      child: const JobPostingView(),
    );
  }
}
