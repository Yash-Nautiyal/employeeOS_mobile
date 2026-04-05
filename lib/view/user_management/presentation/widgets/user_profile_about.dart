import 'dart:math' show pi;

import 'package:employeeos/core/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class UserProfileAbout extends StatelessWidget {
  final ThemeData theme;
  final String dateOfBirth;
  const UserProfileAbout(
      {super.key, required this.theme, required this.dateOfBirth});

  @override
  Widget build(BuildContext context) {
    final dob = tryParseDobString(dateOfBirth);
    final month = dob != null ? getMonthName(dob.month) : '—';
    final year = dob?.year ?? '—';
    final day = dob?.day ?? '—';
    final age = dob != null ? ageInYears(dob) : null;
    final ageLabel = age != null ? '$age years' : '—';

    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.all(16),
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
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            "About",
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            width: double.maxFinite,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor,
                  spreadRadius: 2,
                  blurRadius: 5,
                )
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.center,
                    width: double.maxFinite,
                    color: AppPallete.successDark,
                    child: Text(
                      month,
                      style: theme.textTheme.titleLarge
                          ?.copyWith(color: Colors.white),
                    ),
                  ),
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                        width: double.maxFinite,
                        color: theme.cardColor,
                        child: Column(
                          children: [
                            Text(
                              '$day',
                              style: theme.textTheme.displayLarge,
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              '$year',
                              style: theme.textTheme.displaySmall
                                  ?.copyWith(color: theme.disabledColor),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: -30,
                        right: -40,
                        child: Transform.rotate(
                          angle: pi / 6,
                          child: SvgPicture.asset(
                            'assets/icons/ic-calender.svg',
                            color: theme.dividerColor.withOpacity(.12),
                            width: 130,
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            ageLabel,
            style: theme.textTheme.bodyMedium,
          )
        ],
      ),
    );
  }
}
