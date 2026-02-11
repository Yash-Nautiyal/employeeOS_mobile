import 'package:flutter/material.dart';

import '../custom_textbutton.dart';

/// Reusable alert dialog with a title, content, and two actions (cancel + primary).
/// Use for confirmations (e.g. delete) or simple forms (e.g. new folder).
class CustomAlertDialog extends StatelessWidget {
  const CustomAlertDialog({
    super.key,
    required this.title,
    required this.content,
    this.cancelLabel = 'Cancel',
    required this.primaryLabel,
    this.primaryOnTap,
    this.primaryColor,
    this.loading = false,
    this.onCancel,
    this.barrierDismissible = true,
  });

  final String title;
  final Widget content;
  final String cancelLabel;
  final String primaryLabel;
  final VoidCallback? primaryOnTap;
  final Color? primaryColor;
  final bool loading;
  final VoidCallback? onCancel;
  final bool barrierDismissible;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectivePrimaryColor = loading
        ? theme.disabledColor.withValues(alpha: 0.3)
        : (primaryColor ?? theme.colorScheme.tertiary);

    return AlertDialog(
      titlePadding: const EdgeInsets.symmetric(
        horizontal: 18,
      ).copyWith(top: 20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 0),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      title: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
        ),
      ),
      content: content,
      actions: [
        CustomTextButton(
          padding: 0,
          onClick: onCancel ?? () => Navigator.of(context).pop(),
          child: Text(
            cancelLabel,
            style: theme.textTheme.labelLarge,
          ),
        ),
        CustomTextButton(
          padding: 0,
          backgroundColor: effectivePrimaryColor,
          onClick: () {
            if (loading) return;
            primaryOnTap?.call();
          },
          child: Text(
            primaryLabel,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.scaffoldBackgroundColor,
            ),
          ),
        ),
      ],
    );
  }
}
