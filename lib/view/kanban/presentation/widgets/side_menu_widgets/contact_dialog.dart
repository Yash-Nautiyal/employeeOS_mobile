import 'package:employeeos/core/common/components/custom_textbutton.dart';
import 'package:employeeos/core/index.dart' show CustomTextfield;
import 'package:employeeos/view/kanban/domain/index.dart' show KanbanAssignee;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ContactDialog extends StatelessWidget {
  final ThemeData theme;
  final BuildContext ctx;

  /// Selected user ids (for showing checkmark / assigned state).
  final Set<String> selected;
  final List<KanbanAssignee> kSampleAssignees;
  final List<KanbanAssignee> filtered;
  final TextEditingController controller;
  final VoidCallback onSearch;
  final Function(KanbanAssignee) onAssign;
  final Function(bool isSelected, KanbanAssignee user) onTap;
  const ContactDialog(
      {super.key,
      required this.theme,
      required this.ctx,
      required this.kSampleAssignees,
      required this.controller,
      required this.onSearch,
      required this.filtered,
      required this.selected,
      required this.onAssign,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(ctx).orientation == Orientation.portrait;
    final screenHeight = MediaQuery.of(ctx).size.height;
    final wideScreen = MediaQuery.of(ctx).size.width > 700;
    final isWideScreen = !isPortrait || wideScreen;
    final maxHeight = isWideScreen ? screenHeight * 0.85 : screenHeight * 0.7;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: maxHeight,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Contacts (${kSampleAssignees.length})',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: CustomTextfield(
                controller: controller,
                keyboardType: TextInputType.text,
                theme: theme,
                hintText: 'Search...',
                onchange: (_) => onSearch(),
                isSearchField: true,
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final user = filtered[index];
                  final isSelected = selected.contains(user.userId);
                  return ListTile(
                    horizontalTitleGap: 10,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.surfaceDim,
                      backgroundImage:
                          user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                              ? NetworkImage(user.avatarUrl!)
                              : null,
                      child: user.avatarUrl == null || user.avatarUrl!.isEmpty
                          ? Text(
                              user.initials,
                              style: theme.textTheme.labelMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            )
                          : null,
                    ),
                    title: Text(user.name,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    subtitle:
                        Text(user.email, style: theme.textTheme.bodySmall),
                    trailing: isSelected
                        ? Icon(Icons.check_circle_rounded,
                            color: theme.colorScheme.tertiary, size: 24)
                        : CustomTextButton(
                            padding: 0,
                            onClick: () => onAssign(user),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/common/solid/ic-mingcute_add-line.svg',
                                  color: theme.colorScheme.tertiary,
                                  width: 13,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  'Assign',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.tertiary,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                    onTap: () => onTap(isSelected, user),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
