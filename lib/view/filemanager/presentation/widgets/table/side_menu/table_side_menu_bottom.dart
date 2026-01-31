import 'dart:ui';

import 'package:employeeos/core/index.dart' show AppPallete, CustomTextButton;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class TableSideMenuBottom extends StatelessWidget {
  final ThemeData theme;
  final VoidCallback onDelete;
  const TableSideMenuBottom(
      {super.key, required this.theme, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: AppPallete.errorLighter,
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomTextButton(
                onClick: onDelete,
                backgroundColor: AppPallete.errorLighter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/common/solid/ic-solar_trash-bin-trash-bold.svg',
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Delete',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
