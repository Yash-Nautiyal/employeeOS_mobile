import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';

class UserProfileContacts extends StatelessWidget {
  final ThemeData theme;
  final String phoneNumber;
  const UserProfileContacts(
      {super.key, required this.theme, required this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    final countryCode =
        phoneNumber.startsWith('+') ? phoneNumber.substring(0, 3) : '';
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.maxFinite,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.shadowColor),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor,
            spreadRadius: 2,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Contact Information',
            style: theme.textTheme.titleLarge
                ?.copyWith(color: theme.disabledColor),
          ),
          const SizedBox(
            height: 16,
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              const Icon(
                Icons.phone,
                color: AppPallete.successMain,
              ),
              const SizedBox(
                width: 16,
              ),
              Flexible(
                child: Wrap(
                  children: [
                    if (countryCode.isNotEmpty || countryCode != '')
                      Text(
                        countryCode,
                        style: theme.textTheme.bodyLarge
                            ?.copyWith(color: theme.disabledColor),
                      ),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(
                      phoneNumber.substring(countryCode.length),
                      style: theme.textTheme.bodyLarge,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              const Icon(
                Icons.location_on_rounded,
                color: AppPallete.errorMain,
              ),
              const SizedBox(
                width: 16,
              ),
              Flexible(
                child: Text(
                  "India",
                  style: theme.textTheme.bodyLarge,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
