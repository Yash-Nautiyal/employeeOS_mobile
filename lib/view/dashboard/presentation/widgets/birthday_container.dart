import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class _BirthdayEntry {
  final String name;
  final DateTime birthday;

  const _BirthdayEntry({
    required this.name,
    required this.birthday,
  });
}

class BirthdayContainer extends StatelessWidget {
  final ThemeData theme;
  final double maxHeight;
  const BirthdayContainer(
      {super.key, required this.theme, required this.maxHeight});

  @override
  Widget build(BuildContext context) {
    final wideScreen = MediaQuery.of(context).size.width > 700;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final isWideScreen = !isPortrait || wideScreen;
    final birthdays = <_BirthdayEntry>[
      _BirthdayEntry(
        name: 'Priya Sharma',
        birthday: DateTime(2026, 4, 24),
      ),
      _BirthdayEntry(
        name: 'Neha Verma',
        birthday: DateTime(2026, 4, 29),
      ),
      _BirthdayEntry(
        name: 'Rohan Kapoor',
        birthday: DateTime(2026, 5, 2),
      ),
      _BirthdayEntry(
        name: 'Aisha Khan',
        birthday: DateTime(2026, 5, 5),
      ),
    ];

    return Card(
      elevation: 10,
      shadowColor: theme.shadowColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        child: Container(
          decoration: BoxDecoration(
            color: AppPallete.primaryMain,
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [
                AppPallete.primaryMain,
                AppPallete.primaryDark,
              ],
              stops: [.1, .8],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.only(right: 0, left: 20),
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Flexible(
                    flex: 4,
                    child: Text(
                      'Upcoming Birthdays',
                      style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppPallete.white,
                          fontSize: !isWideScreen ? 25 : 35),
                    ),
                  ),
                  Flexible(
                    flex: 3,
                    child: Image.asset('assets/illustrations/birthday.png'),
                  )
                ],
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: birthdays.length,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    final entry = birthdays[index];
                    final initials = entry.name
                        .split(' ')
                        .where((part) => part.isNotEmpty)
                        .take(2)
                        .map((part) => part[0])
                        .join()
                        .toUpperCase();
                    final birthdayDate =
                        '${entry.birthday.day}/${entry.birthday.month}/${entry.birthday.year}';

                    return Container(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: isWideScreen ? 25 : 22,
                            backgroundColor: AppPallete.white.withOpacity(.2),
                            child: Text(
                              initials,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: AppPallete.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.name,
                                style: theme.textTheme.labelLarge
                                    ?.copyWith(color: AppPallete.white),
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/ic-calender.svg',
                                    color: AppPallete.grey200,
                                    width: isWideScreen ? 15 : 20,
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    birthdayDate,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                        fontSize: 15, color: AppPallete.white),
                                  ),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
