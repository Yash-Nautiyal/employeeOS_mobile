import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BirthdayContainer extends StatelessWidget {
  final ThemeData theme;
  final double maxHeight;
  const BirthdayContainer(
      {super.key, required this.theme, required this.maxHeight});

  @override
  Widget build(BuildContext context) {
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
            children: [
              Row(
                children: [
                  Flexible(
                    flex: 4,
                    child: Text(
                      'Upcoming Birthdays',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 30,
                        color: AppPallete.white,
                      ),
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
                  itemCount: 5,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) => Container(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const CircleAvatar(
                          radius: 22,
                        ),
                        const SizedBox(
                          width: 16,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Alex Balding',
                              style: theme.textTheme.labelLarge?.copyWith(
                                  color: AppPallete.white, fontSize: 18),
                            ),
                            const SizedBox(
                              height: 3,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/ic-calender.svg',
                                  color: AppPallete.grey200,
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  '${DateTime.now().add(const Duration(days: 10)).day}/${DateTime.now().add(const Duration(days: 10)).month}/${DateTime.now().add(const Duration(days: 10)).year}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                      color: AppPallete.white,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
