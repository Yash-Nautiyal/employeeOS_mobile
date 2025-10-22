import 'dart:ui';

import 'package:employeeos/core/common/components/dialog/slide_dialog.dart';
import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:employeeos/view/home/presentation/pages/home_view.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class ProfileDialog extends StatelessWidget {
  final ThemeData theme;

  const ProfileDialog({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return SlideDialog(
      theme: theme,
      title: "Profile",
      child: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 12.7.h,
                      height: 12.7.h,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                          center: Alignment.center,
                          startAngle: 0.0,
                          endAngle: 6.28319,
                          colors: [
                            Colors.blue,
                            Colors.purple,
                            Colors.red,
                            Colors.orange,
                            Colors.yellow,
                            Colors.blue,
                          ],
                          stops: [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
                        ),
                      ),
                    ),
                    CircleAvatar(radius: 6.h),
                  ],
                ),
                SizedBox(height: 1.h),
                Text('Yash Nautiyal',
                    style:
                        theme.textTheme.titleLarge?.copyWith(fontSize: 20.sp)),
                SizedBox(height: .2.h),
                Text(
                  'Software Engineer',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16.sp,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeView()),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppPallete.errorLight.withOpacity(0.8),
              foregroundColor: AppPallete.errorLight,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Logout',
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppPallete.errorDarker,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
