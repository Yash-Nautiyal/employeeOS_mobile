import 'package:employeeos/core/common/components/ui/custom_toast.dart';
import 'package:employeeos/core/routing/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:toastification/toastification.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../domain/index.dart' show JobPosting;
import '../../../bloc/job_posting/job_posting_detail_cubit.dart';
import '../../../utils/quill/quill_description_codec.dart';
import '../../injection/job_posting_injection.dart';
import '../../index.dart' show ApplicationsContent, JobContent;

class JobViewPage extends StatefulWidget {
  final Object? jobId;

  const JobViewPage({super.key, this.jobId});

  @override
  State<JobViewPage> createState() => _JobViewPageState();
}

class _JobViewPageState extends State<JobViewPage> {
  JobPosting? _lastDescriptionJob;
  QuillController? _descriptionController;

  @override
  void dispose() {
    _descriptionController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final jobId = widget.jobId;

    if (jobId == null || jobId is! String || jobId.isEmpty) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBackHeader(theme),
              Expanded(child: _buildPlaceholder(theme)),
            ],
          ),
        ),
      );
    }

    return BlocProvider<JobPostingDetailCubit>(
      create: (_) => JobPostingInjection.createDetailCubit(jobBusinessId: jobId)
        ..loadInitial(),
      child: BlocConsumer<JobPostingDetailCubit, JobPostingDetailState>(
        listenWhen: (previous, current) => previous.job != current.job,
        listener: (context, state) {
          final job = state.job;
          if (job == null || job == _lastDescriptionJob) return;
          _lastDescriptionJob = job;
          _descriptionController?.dispose();
          if (job.description != null && job.description!.trim().isNotEmpty) {
            final doc = QuillDescriptionCodec.decodeToDocument(job.description);
            _descriptionController = QuillController(
              document: doc,
              selection: const TextSelection.collapsed(offset: 0),
              readOnly: true,
            );
          } else {
            _descriptionController = null;
          }
        },
        builder: (context, state) {
          final cubit = context.read<JobPostingDetailCubit>();
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBackHeader(theme),
                  Expanded(
                    child: _buildBodyFromState(
                      context: context,
                      theme: theme,
                      state: state,
                      cubit: cubit,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBackHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: InkWell(
        onTap: () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
            return;
          }
          const AppRecruitmentJobPostingRoute().go(context);
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.arrow_back_rounded,
                size: 24,
                color: theme.iconTheme.color,
              ),
              const SizedBox(width: 8),
              Text(
                'Back to Job Postings',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBodyFromState({
    required BuildContext context,
    required ThemeData theme,
    required JobPostingDetailState state,
    required JobPostingDetailCubit cubit,
  }) {
    if (state.isJobLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: CircularProgressIndicator(color: theme.colorScheme.primary),
        ),
      );
    }
    if (state.jobError != null || state.job == null) {
      return _buildPlaceholder(
        theme,
        message: state.jobError ?? 'Job not found.',
      );
    }

    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Column(
        children: [
          TabBar(
            dividerColor: theme.dividerColor.withAlpha(30),
            tabAlignment: TabAlignment.fill,
            automaticIndicatorColorAdjustment: true,
            overlayColor: const WidgetStatePropertyAll(Colors.transparent),
            labelStyle: theme.textTheme.labelLarge,
            tabs: const [
              Tab(text: 'Job Details'),
              Tab(text: 'Applications'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: JobContent(
                    job: state.job!,
                    descriptionController: _descriptionController,
                    theme: theme,
                    includeDescription: true,
                  ),
                ),
                ApplicationsContent(
                  theme: theme,
                  rows: state.applications,
                  selectedIds: state.selectedApplicationIds,
                  isLoading: state.isApplicationsLoading,
                  error: state.applicationsError,
                  currentPage: state.applicationsPage,
                  totalPages: state.applicationsTotalPages,
                  sortAsc: state.sortAsc,
                  onToggleSelect: cubit.toggleSelectApplication,
                  onToggleSelectAll: cubit.toggleSelectAllApplications,
                  onSortDate: cubit.toggleApplicationsSort,
                  onPrevPage: cubit.goPreviousApplicationsPage,
                  onNextPage: cubit.goNextApplicationsPage,
                  onRetry: cubit.retryApplicationsPage,
                  onResume: _openResume,
                  onDownload: () => _downloadResumes(state),
                  onShortlist: state.hasSelection
                      ? () => _onShortlistSelected(cubit)
                      : null,
                  onReject: state.hasSelection
                      ? () => _onRejectSelected(cubit)
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openResume(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _downloadResumes(JobPostingDetailState state) async {
    final selected = state.applications
        .where((a) => state.selectedApplicationIds.contains(a.id))
        .toList(growable: false);
    final targets = selected.isNotEmpty ? selected : state.applications;
    if (targets.isEmpty) return;

    for (final app in targets) {
      if (app.resumeUrl.trim().isEmpty) continue;
      await FileDownloader.downloadFile(
        url: app.resumeUrl,
        name: '${app.fullName}_${app.id}.pdf',
        notificationType: NotificationType.all,
      );
    }
  }

  Future<void> _onShortlistSelected(JobPostingDetailCubit cubit) async {
    final updated = await cubit.shortlistSelected();
    if (updated == 0 || !mounted) return;
    showCustomToast(
      context: context,
      type: ToastificationType.success,
      title: 'Updated',
      description: '$updated application(s) shortlisted',
    );
  }

  Future<void> _onRejectSelected(JobPostingDetailCubit cubit) async {
    final updated = await cubit.rejectSelected();
    if (updated == 0 || !mounted) return;
    showCustomToast(
      context: context,
      type: ToastificationType.success,
      title: 'Updated',
      description: '$updated application(s) rejected',
    );
  }

  Widget _buildPlaceholder(ThemeData theme, {String? message}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.shadowColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.work_outline_rounded,
              size: 48, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            message ?? 'Job details will go here',
            style: theme.textTheme.titleMedium,
          ),
          if (widget.jobId != null) ...[
            const SizedBox(height: 8),
            Text(
              'Job ID: ${widget.jobId}',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
