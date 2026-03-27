import 'package:employeeos/core/common/components/custom_bread_crumbs.dart';
import 'package:employeeos/view/recruitment/data/job_application/datasources/job_application_mock_datasource.dart';
import 'package:employeeos/view/recruitment/data/job_application/repositories/job_application_repository_impl.dart';
import 'package:employeeos/view/recruitment/domain/job_application/usecases/get_job_applications.dart';
import 'package:employeeos/view/recruitment/domain/job_application/usecases/reject_job_application.dart';
import 'package:employeeos/view/recruitment/domain/job_application/usecases/shortlist_job_application.dart';
import 'package:employeeos/view/recruitment/presentation/bloc/job_application/job_application_bloc.dart';
import 'package:employeeos/view/recruitment/presentation/widget/index.dart'
    show JobApplicationCard;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class JobApplicationView extends StatefulWidget {
  const JobApplicationView({super.key});

  @override
  State<JobApplicationView> createState() => _JobApplicationViewState();
}

class _JobApplicationViewState extends State<JobApplicationView> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final repository = JobApplicationRepositoryImpl(
      JobApplicationMockDatasource.instance,
    );

    return BlocProvider(
      create: (_) => JobApplicationBloc(
        getJobApplicationsUseCase: GetJobApplicationsUseCase(repository),
        shortlistJobApplicationUseCase:
            ShortlistJobApplicationUseCase(repository),
        rejectJobApplicationUseCase: RejectJobApplicationUseCase(repository),
      )..add(const JobApplicationsLoadRequested()),
      child: BlocBuilder<JobApplicationBloc, JobApplicationState>(
        builder: (context, state) {
          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverPadding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top,
                  bottom: 20,
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomBreadCrumbs(
                        theme: theme,
                        heading: 'Job Applications',
                        routes: const ['Dashboard', 'Job', 'Applications'],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: _buildSliverBody(context, theme, state),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSliverBody(
    BuildContext context,
    ThemeData theme,
    JobApplicationState state,
  ) {
    if (state is JobApplicationLoading || state is JobApplicationInitial) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    if (state is JobApplicationError) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(state.message),
        ),
      );
    }
    if (state is JobApplicationsLoaded) {
      if (state.applications.isEmpty) {
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'No applications yet.',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        );
      }
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final app = state.applications[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 0),
              child: JobApplicationCard(
                theme: theme,
                application: app,
                onShortlist: () => context.read<JobApplicationBloc>().add(
                      JobApplicationShortlistRequested(app.id),
                    ),
                onReject: () => context.read<JobApplicationBloc>().add(
                      JobApplicationRejectRequested(app.id),
                    ),
              ),
            );
          },
          childCount: state.applications.length,
        ),
      );
    }
    return const SliverToBoxAdapter(child: SizedBox.shrink());
  }
}
