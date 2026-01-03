import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';

class CandidatesList extends StatefulWidget {
  final ThemeData theme;
  final List<Map<String, String>> candidates;
  final ValueChanged<int>? onSelectionChanged;

  const CandidatesList({
    super.key,
    required this.theme,
    required this.candidates,
    this.onSelectionChanged,
  });

  @override
  State<CandidatesList> createState() => _CandidatesListState();
}

class _CandidatesListState extends State<CandidatesList> {
  late List<bool> _selectedCandidates;

  @override
  void initState() {
    super.initState();
    _selectedCandidates = List.filled(widget.candidates.length, false);
    widget.onSelectionChanged?.call(0);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.candidates.length,
      itemBuilder: (context, index) {
        final candidate = widget.candidates[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.theme.brightness == Brightness.dark
                ? AppPallete.grey800.withOpacity(0.5)
                : AppPallete.grey100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.theme.brightness == Brightness.dark
                  ? AppPallete.grey700
                  : AppPallete.grey300,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: _selectedCandidates[index],
                    onChanged: (value) {
                      setState(() {
                        _selectedCandidates[index] = value ?? false;
                        final count =
                            _selectedCandidates.where((e) => e).length;
                        widget.onSelectionChanged?.call(count);
                      });
                    },
                  ),
                  Expanded(
                    child: Text(
                      candidate['name']!,
                      style: widget.theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  PopupMenuButton(
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: Text('View Details'),
                      ),
                      const PopupMenuItem(
                        value: 'schedule',
                        child: Text('Schedule Interview'),
                      ),
                      const PopupMenuItem(
                        value: 'reject',
                        child: Text('Reject'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                  widget.theme, 'Job Title', candidate['jobTitle']!),
              const SizedBox(height: 8),
              _buildInfoRow(widget.theme, 'Application Date',
                  candidate['applicationDate']!),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text('Resume'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    side: BorderSide(color: widget.theme.dividerColor),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(ThemeData theme, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.disabledColor,
            ),
          ),
        ),
        const Text(': '),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

