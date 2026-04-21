import 'package:flutter/material.dart';

/// A reusable type-ahead "select existing or add new" field.
///
/// If [allowAddNewDepartment] is `true` and user types a value that doesn't
/// match any entry in [options], it shows an `Add "<typed>"` row.
class DepartmentSearchAddField extends StatefulWidget {
  final ThemeData theme;
  final List<String> options;
  final String? selectedValue;
  final bool allowAddNewDepartment;
  final ValueChanged<String?>? onChanged;

  const DepartmentSearchAddField({
    super.key,
    required this.theme,
    required this.options,
    required this.selectedValue,
    required this.allowAddNewDepartment,
    required this.onChanged,
  });

  @override
  State<DepartmentSearchAddField> createState() =>
      _DepartmentSearchAddFieldState();
}

class _DepartmentSearchAddFieldState extends State<DepartmentSearchAddField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  List<String> _filtered = const [];
  bool get _showSuggestions =>
      _focusNode.hasFocus && _controller.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.selectedValue ?? '');
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_showSuggestions) return;
      _recomputeFiltered();
      setState(() {});
    });
    _recomputeFiltered();
  }

  @override
  void didUpdateWidget(covariant DepartmentSearchAddField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Avoid overwriting user typing while focused.
    if (widget.selectedValue != oldWidget.selectedValue &&
        !_focusNode.hasFocus) {
      _controller.text = widget.selectedValue ?? '';
      _recomputeFiltered();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _recomputeFiltered() {
    final q = _controller.text.trim();
    final qLower = q.toLowerCase();

    if (qLower.isEmpty) {
      // Only show suggestions after user starts typing.
      _filtered = const [];
      return;
    }

    final matches = widget.options
        .where((o) => o.toLowerCase().contains(qLower))
        .toList(growable: false);
    _filtered = matches;
  }

  void _choose(String value) {
    _controller.text = value;
    widget.onChanged?.call(value);
    _focusNode.unfocus(); // close dropdown
    setState(() {
      _recomputeFiltered();
    });
  }

  @override
  Widget build(BuildContext context) {
    final q = _controller.text.trim();
    final showAddRow =
        widget.allowAddNewDepartment && q.isNotEmpty && _filtered.isEmpty;
    const maxSuggestions = 8;
    final visibleSuggestions = _filtered.take(maxSuggestions).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            isDense: true,
            hintText: 'Enter department...',
            hintStyle: widget.theme.textTheme.bodyMedium,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          style: widget.theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: widget.theme.colorScheme.tertiary,
          ),
          validator: (v) {
            final value = v?.trim() ?? '';
            if (value.isEmpty) return 'Department is required';
            if (!widget.allowAddNewDepartment) {
              final exists = widget.options
                  .any((o) => o.toLowerCase() == value.toLowerCase());
              if (!exists) return 'Please select a valid department';
            }
            return null;
          },
          onChanged: (value) {
            final trimmed = value.trim();
            widget.onChanged?.call(trimmed.isEmpty ? null : trimmed);
            _recomputeFiltered();
            setState(() {});
          },
          onFieldSubmitted: (_) {
            // If nothing matches, treat the typed value as a new department.
            if (widget.allowAddNewDepartment &&
                q.isNotEmpty &&
                widget.options
                    .every((o) => o.toLowerCase() != q.toLowerCase())) {
              _choose(q);
              return;
            }
            // If it matches an existing option, choose it exactly as stored.
            final exact = widget.options.firstWhere(
              (o) => o.toLowerCase() == q.toLowerCase(),
              orElse: () => q,
            );
            _choose(exact);
          },
        ),
        if (_showSuggestions)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 120),
            child: (visibleSuggestions.isEmpty && !showAddRow)
                ? const SizedBox.shrink()
                : Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: widget.theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                            widget.theme.brightness == Brightness.dark
                                ? 0.4
                                : 0.15,
                          ),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 220),
                      child: ListView(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        children: [
                          ...visibleSuggestions.map(
                            (v) => ListTile(
                              title: Text(v),
                              dense: true,
                              onTap: () => _choose(v),
                            ),
                          ),
                          if (showAddRow)
                            ListTile(
                              title: Text('Add \"$q\"'),
                              dense: true,
                              onTap: () => _choose(q),
                            ),
                        ],
                      ),
                    ),
                  ),
          ),
      ],
    );
  }
}
