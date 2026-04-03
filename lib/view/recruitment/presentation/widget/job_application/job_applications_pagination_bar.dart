import 'package:flutter/material.dart';

/// Builds slot list: page numbers and `null` for ellipsis.
/// [neighbours] controls how many pages are shown on each side of [currentPage].
List<int?> jobApplicationsPaginationSlots(
  int currentPage,
  int totalPages, {
  int neighbours = 2,
}) {
  if (totalPages <= 0) return const [];

  // Max visible numbers = 1 (first) + 1 (last) + 2*neighbours + 1 (current) = 2N+3.
  // If everything fits without gaps, just show all pages.
  final window = neighbours * 2 + 3;
  if (totalPages <= window) {
    return List<int?>.generate(totalPages, (i) => i + 1);
  }

  final nums = <int>{
    1,
    totalPages,
    currentPage,
    for (var d = 1; d <= neighbours; d++) ...[
      currentPage - d,
      currentPage + d,
    ],
  };
  nums.removeWhere((p) => p < 1 || p > totalPages);
  final sorted = nums.toList()..sort();

  final out = <int?>[];
  for (var i = 0; i < sorted.length; i++) {
    if (i > 0 && sorted[i] - sorted[i - 1] > 1) {
      out.add(null);
    }
    out.add(sorted[i]);
  }
  return out;
}

// Each slot (page button or ellipsis) takes ~44 px; chevron buttons ~40 px each;
// loading spinner ~36 px.  We use these to pick [neighbours].
const double _slotWidth = 44.0;
const double _chevronWidth = 40.0;
const double _spinnerWidth = 36.0;

/// Picks how many neighbour pages to show so that the row fits inside [availableWidth].
int _neighboursForWidth(double availableWidth, bool isLoading) {
  // Space consumed by the two chevrons (and optional spinner).
  final fixed =
      _chevronWidth * 2 + (isLoading ? _spinnerWidth + 16 : 0);
  final remaining = availableWidth - fixed;

  // Minimum: just current + first + last = 3 slots + up to 2 ellipses = 5 slots.
  // Try neighbours from 2 down to 0 and pick the largest that fits.
  for (var n = 2; n >= 0; n--) {
    // Worst-case slots: 1, …, (cur-n…cur+n), …, last => 1+1+(2n+1)+up to 2 ellipses
    final maxSlots = 2 * n + 3 + 2;
    if (remaining >= maxSlots * _slotWidth) return n;
  }
  return 0;
}

class JobApplicationsPaginationBar extends StatelessWidget {
  const JobApplicationsPaginationBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageSelected,
    this.isLoading = false,
  });

  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageSelected;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 0) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final canPrev = currentPage > 1;
    final canNext = currentPage < totalPages;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;

        final neighbours = _neighboursForWidth(availableWidth, isLoading);
        final slots = jobApplicationsPaginationSlots(
          currentPage,
          totalPages,
          neighbours: neighbours,
        );

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              _ChevronButton(
                icon: Icons.chevron_left,
                tooltip: 'Previous',
                enabled: canPrev && !isLoading,
                color: cs.onSurface,
                onTap: () => onPageSelected(currentPage - 1),
              ),
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ...slots.map((slot) {
                if (slot == null) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Text(
                      '...',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }
                final selected = slot == currentPage;
                return _PageButton(
                  page: slot,
                  selected: selected,
                  enabled: !isLoading && !selected,
                  selectedBg: cs.onSurface,
                  selectedFg: cs.surface,
                  unselectedFg: cs.primary,
                  textStyle: theme.textTheme.bodyLarge,
                  onTap: () => onPageSelected(slot),
                );
              }),
              _ChevronButton(
                icon: Icons.chevron_right,
                tooltip: 'Next',
                enabled: canNext && !isLoading,
                color: cs.onSurface,
                onTap: () => onPageSelected(currentPage + 1),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ChevronButton extends StatelessWidget {
  const _ChevronButton({
    required this.icon,
    required this.tooltip,
    required this.enabled,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final bool enabled;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      onPressed: enabled ? onTap : null,
      icon: Icon(
        icon,
        color: enabled ? color : color.withValues(alpha: 0.28),
      ),
      tooltip: tooltip,
    );
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({
    required this.page,
    required this.selected,
    required this.enabled,
    required this.selectedBg,
    required this.selectedFg,
    required this.unselectedFg,
    required this.textStyle,
    required this.onTap,
  });

  final int page;
  final bool selected;
  final bool enabled;
  final Color selectedBg;
  final Color selectedFg;
  final Color unselectedFg;
  final TextStyle? textStyle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: enabled ? onTap : null,
          child: Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? selectedBg : Colors.transparent,
            ),
            child: Text(
              '$page',
              style: textStyle?.copyWith(
                color: selected ? selectedFg : unselectedFg,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
