import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../../../data/datasources/job_posting_mock_datasource.dart';
import '../../../data/models/job_posting_model.dart';
import '../index.dart' show ApplicationsContent, JobContent;

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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
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
              Expanded(child: _buildPlaceholder(theme))
            else
              Expanded(
                child: FutureBuilder<JobPostingModel?>(
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
                    return DefaultTabController(
                      length: 2,
                      initialIndex: 0,
                      child: Column(
                        children: [
                          TabBar(
                            dividerColor: theme.dividerColor.withAlpha(30),
                            tabAlignment: TabAlignment.fill,
                            automaticIndicatorColorAdjustment: true,
                            overlayColor: const WidgetStatePropertyAll(
                                Colors.transparent),
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
                                    job: job,
                                    descriptionController:
                                        _descriptionController,
                                    theme: theme,
                                    includeDescription: true,
                                  ),
                                ),
                                ApplicationsContent(
                                  theme: theme,
                                  jobId: job.id,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
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
}
