import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

/// Read-only job description tab content (Quill).
class DescriptionContent extends StatelessWidget {
  const DescriptionContent({
    super.key,
    required this.controller,
    required this.theme,
  });

  final QuillController? controller;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    if (controller == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No description',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor,
              spreadRadius: 1,
              blurRadius: 3,
            ),
          ],
        ),
        child: QuillEditor.basic(
          controller: controller!,
          config: QuillEditorConfig(
            padding: EdgeInsets.zero,
            customStyles: DefaultStyles(
              lists: DefaultListBlockStyle(
                tt.bodyMedium!.copyWith(color: cs.tertiary),
                HorizontalSpacing.zero,
                VerticalSpacing.zero,
                VerticalSpacing.zero,
                null,
                null,
              ),
              paragraph: DefaultTextBlockStyle(
                tt.bodyMedium!.copyWith(color: cs.tertiary),
                HorizontalSpacing.zero,
                VerticalSpacing.zero,
                VerticalSpacing.zero,
                null,
              ),
              h1: DefaultTextBlockStyle(
                tt.titleLarge!.copyWith(
                  color: cs.tertiary,
                  fontWeight: FontWeight.w900,
                ),
                HorizontalSpacing.zero,
                VerticalSpacing.zero,
                VerticalSpacing.zero,
                null,
              ),
              h2: DefaultTextBlockStyle(
                tt.titleMedium!.copyWith(
                  fontWeight: FontWeight.w900,
                  color: cs.tertiary,
                ),
                HorizontalSpacing.zero,
                VerticalSpacing.zero,
                VerticalSpacing.zero,
                null,
              ),
              h3: DefaultTextBlockStyle(
                tt.titleSmall!.copyWith(
                  color: cs.tertiary,
                  fontWeight: FontWeight.w900,
                ),
                HorizontalSpacing.zero,
                VerticalSpacing.zero,
                VerticalSpacing.zero,
                null,
              ),
              color: cs.tertiary,
            ),
          ),
        ),
      ),
    );
  }
}
