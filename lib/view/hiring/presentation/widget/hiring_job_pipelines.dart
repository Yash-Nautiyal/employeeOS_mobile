import 'package:employeeos/view/hiring/domain/entities/hiring_model.dart';
import 'package:employeeos/view/hiring/presentation/widget/hiring_pipeline_container.dart';
import 'package:flutter/material.dart';

PipelineOverview _overviewForJob(JobPipelineData job) {
  return PipelineOverview(
    applicationProgress: ApplicationProgress(
      shortlisted: job.shortlisted,
      pending: job.pending,
      rejected: job.rejected,
      total: job.totalApplications,
    ),
    interviewProgress: InterviewProgress(
      telephonic: StageProgress(
        active: job.telephonicActive,
        eligible: job.telephonicEligible,
      ),
      technical: StageProgress(
        active: job.technicalActive,
        eligible: job.technicalEligible,
      ),
      onboarding: StageProgress(
        active: job.onboardingActive,
        eligible: job.onboardingEligible,
      ),
    ),
  );
}

class HiringJobPipelines extends StatefulWidget {
  final ThemeData theme;
  final ScrollController scrollController;
  final List<JobPipelineData> data;

  const HiringJobPipelines({
    super.key,
    required this.theme,
    required this.scrollController,
    required this.data,
  });

  @override
  State<HiringJobPipelines> createState() => _HiringJobPipelinesState();
}

class _HiringJobPipelinesState extends State<HiringJobPipelines>
    with TickerProviderStateMixin {
  List<bool> expandedStates = [];

  @override
  void initState() {
    super.initState();
    _syncExpandedLength();
  }

  @override
  void didUpdateWidget(HiringJobPipelines oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data.length != widget.data.length) {
      _syncExpandedLength();
    }
  }

  void _syncExpandedLength() {
    expandedStates = List.generate(
      widget.data.length,
      (index) => index == 0 && widget.data.isNotEmpty,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    final shouldUseGridLayout = !isPortrait || screenWidth > 600;

    if (widget.data.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'No job pipeline data for the current filters.',
            style: widget.theme.textTheme.bodyMedium?.copyWith(
              color: widget.theme.disabledColor,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return shouldUseGridLayout
        ? GridView.builder(
            controller: widget.scrollController,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: widget.data.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: .85,
            ),
            itemBuilder: (context, index) {
              return _buildJobPipelineCard(index, isGridLayout: true);
            },
          )
        : Column(
            children: List.generate(
              widget.data.length,
              (index) => _buildJobPipelineCard(index, isGridLayout: false),
            ),
          );
  }

  Widget _buildJobPipelineCard(int index, {required bool isGridLayout}) {
    final job = widget.data[index];
    final overview = _overviewForJob(job);

    return Container(
      margin: EdgeInsets.only(top: isGridLayout ? 0 : 12),
      decoration: BoxDecoration(
        color: widget.theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: widget.theme.brightness == Brightness.dark ? 0.3 : 0.2,
            ),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: isGridLayout
                ? null
                : () {
                    setState(() {
                      for (int i = 0; i < expandedStates.length; i++) {
                        expandedStates[i] =
                            i == index ? !expandedStates[i] : false;
                      }
                    });
                  },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.jobTitle,
                          style: widget.theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                          maxLines: isGridLayout ? 2 : 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "(${job.totalApplications} Applications)",
                          style: widget.theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      ],
                    ),
                  ),
                  if (!isGridLayout)
                    Icon(
                      expandedStates[index]
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: widget.theme.dividerColor,
                    ),
                ],
              ),
            ),
          ),
          if (!isGridLayout)
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: expandedStates[index]
                  ? AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 350),
                        child: HiringPipelineContainer(
                          theme: widget.theme,
                          big: false,
                          data: overview,
                          key: ValueKey('expanded-$index'),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            )
          else
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 250),
                child: HiringPipelineContainer(
                  theme: widget.theme,
                  big: false,
                  data: overview,
                  key: ValueKey('grid-expanded-$index'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
