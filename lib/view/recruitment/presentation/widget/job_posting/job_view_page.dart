import 'dart:convert';

import 'package:employeeos/view/recruitment/data/datasources/job_posting_mock_datasource.dart';
import 'package:employeeos/view/recruitment/data/models/job_posting_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class JobViewPage extends StatefulWidget {
  final Object? jobId;

  const JobViewPage({super.key, this.jobId});

  @override
  State<JobViewPage> createState() => _JobViewPageState();
}

class _JobViewPageState extends State<JobViewPage> {
  final _datasource = JobPostingMockDatasource.instance;
  Future<JobPostingModel?>? _jobFuture;
  QuillController? _descriptionController;

  @override
  void initState() {
    super.initState();
    final id = widget.jobId;
    if (id is String && id.isNotEmpty) {
      _jobFuture = _datasource.getById(id);
      _jobFuture!.then((job) {
        if (!mounted || job == null) return;
        if (job.description != null && job.description!.trim().isNotEmpty) {
          try {
            final doc = Document.fromJson(
              jsonDecode(job.description!) as List,
            );
            _descriptionController = QuillController(
              document: doc,
              selection: const TextSelection.collapsed(offset: 0),
              readOnly: true,
            );
          } catch (_) {
            // Invalid JSON or empty delta: leave _descriptionController null
          }
        }
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _descriptionController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
          bottom: 20,
          left: 16,
          right: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
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
            ),
            if (widget.jobId == null || (widget.jobId is! String))
              _buildPlaceholder(theme)
            else
              FutureBuilder<JobPostingModel?>(
                future: _jobFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(48),
                        child: CircularProgressIndicator(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    );
                  }
                  final job = snapshot.data;
                  if (snapshot.hasError || job == null) {
                    return _buildPlaceholder(
                      theme,
                      message: snapshot.hasError
                          ? 'Could not load job.'
                          : 'Job not found.',
                    );
                  }
                  return _buildJobContent(theme, job);
                },
              ),
          ],
        ),
      ),
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

  Widget _buildJobContent(ThemeData theme, JobPostingModel job) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
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
                job.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                job.department,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (job.location != null && job.location!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Location: ${job.location}',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
              if (job.positions > 0) ...[
                const SizedBox(height: 4),
                Text(
                  'Positions: ${job.positions}',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
              if (job.lastDateToApply != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Last date to apply: ${_formatDate(job.lastDateToApply!)}',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
              if (job.ctcRange != null && job.ctcRange!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'CTC: ${job.ctcRange}',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 16),
              Text(
                'Posted by ${job.postedByName}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                job.postedByEmail,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (_descriptionController != null) ...[
          const SizedBox(height: 24),
          Text(
            'Description',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.shadowColor),
            ),
            child: QuillEditor.basic(
              controller: _descriptionController!,
              config: QuillEditorConfig(
                padding: EdgeInsets.zero,
                customStyles: DefaultStyles(
                  lists: DefaultListBlockStyle(
                    theme.textTheme.bodyMedium!,
                    HorizontalSpacing.zero,
                    VerticalSpacing.zero,
                    VerticalSpacing.zero,
                    null,
                    null,
                  ),
                  paragraph: DefaultTextBlockStyle(
                    theme.textTheme.titleMedium!.copyWith(
                      color: theme.colorScheme.tertiary,
                    ),
                    HorizontalSpacing.zero,
                    VerticalSpacing.zero,
                    VerticalSpacing.zero,
                    null,
                  ),
                  h1: DefaultTextBlockStyle(
                    theme.textTheme.displayLarge!.copyWith(
                      color: theme.colorScheme.tertiary,
                    ),
                    HorizontalSpacing.zero,
                    VerticalSpacing.zero,
                    VerticalSpacing.zero,
                    null,
                  ),
                  h2: DefaultTextBlockStyle(
                    theme.textTheme.displayMedium!.copyWith(
                      color: theme.colorScheme.tertiary,
                    ),
                    HorizontalSpacing.zero,
                    VerticalSpacing.zero,
                    VerticalSpacing.zero,
                    null,
                  ),
                  h3: DefaultTextBlockStyle(
                    theme.textTheme.displaySmall!.copyWith(
                      color: theme.colorScheme.tertiary,
                    ),
                    HorizontalSpacing.zero,
                    VerticalSpacing.zero,
                    VerticalSpacing.zero,
                    null,
                  ),
                  h4: DefaultTextBlockStyle(
                    theme.textTheme.titleLarge!.copyWith(
                      color: theme.colorScheme.tertiary,
                    ),
                    HorizontalSpacing.zero,
                    VerticalSpacing.zero,
                    VerticalSpacing.zero,
                    null,
                  ),
                  h5: DefaultTextBlockStyle(
                    theme.textTheme.titleMedium!.copyWith(
                      color: theme.colorScheme.tertiary,
                    ),
                    HorizontalSpacing.zero,
                    VerticalSpacing.zero,
                    VerticalSpacing.zero,
                    null,
                  ),
                  h6: DefaultTextBlockStyle(
                    theme.textTheme.titleSmall!.copyWith(
                      color: theme.colorScheme.tertiary,
                    ),
                    HorizontalSpacing.zero,
                    VerticalSpacing.zero,
                    VerticalSpacing.zero,
                    null,
                  ),
                  color: theme.colorScheme.tertiary,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _formatDate(DateTime d) {
    return '${d.day} ${_month(d.month)} ${d.year}';
  }

  String _month(int m) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[m - 1];
  }
}
