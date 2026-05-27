import 'package:employeeos/core/index.dart' show CustomDropdown;
import 'package:flutter/material.dart';

import '../../../domain/entities/participant.dart';

class AppBarSeachField extends StatelessWidget {
  final bool isLoadingUsers;
  final List<Participant> availableUsers;
  final int loadingDotCount;
  final Participant? selectedUser;
  final void Function(Participant) onChageValue;
  final ThemeData theme;

  const AppBarSeachField({
    super.key,
    required this.isLoadingUsers,
    required this.availableUsers,
    required this.loadingDotCount,
    required this.selectedUser,
    required this.onChageValue,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        constraints: const BoxConstraints(minWidth: 200),
        child: isLoadingUsers
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Loading users${'.' * loadingDotCount}",
                  style: theme.textTheme.bodyMedium,
                ),
              )
            : CustomDropdown(
                value: selectedUser,
                theme: theme,
                label: 'Search user by name',
                isSearchable: true,
                onChange: (value) => onChageValue(value),
                selectedItemBuilder: (context) => availableUsers
                    .map(
                      (user) => Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          user.name,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.tertiary,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                items: availableUsers
                    .map(
                      (user) => DropdownMenuItem(
                        value: user, // The value used for matching
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundImage: user.avatarUrl.isNotEmpty
                                  ? NetworkImage(user.avatarUrl)
                                  : null,
                              child: user.avatarUrl.isEmpty
                                  ? Text(
                                      user.name.isNotEmpty
                                          ? user.name
                                              .substring(0, 1)
                                              .toUpperCase()
                                          : '?',
                                      style: theme.textTheme.labelLarge,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    user.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.tertiary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
      ),
    );
  }
}
