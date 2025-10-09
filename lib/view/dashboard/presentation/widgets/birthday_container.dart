import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sizer/sizer.dart';

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
                        fontSize: 24.sp,
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
                        CircleAvatar(
                          radius: isWideScreen ? 3.w : 6.w,
                        ),
                        SizedBox(
                          width: isWideScreen ? 1.5.w : 3.w,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Alex Balding',
                              style: theme.textTheme.labelLarge?.copyWith(
                                  color: AppPallete.white, fontSize: 18.sp),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/ic-calender.svg',
                                  color: AppPallete.grey200,
                                  width: isWideScreen ? 2.5.w : 5.w,
                                ),
                                SizedBox(
                                  width: 1.w,
                                ),
                                Text(
                                  '${DateTime.now().add(const Duration(days: 10)).day}/${DateTime.now().add(const Duration(days: 10)).month}/${DateTime.now().add(const Duration(days: 10)).year}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: 15.sp,
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
