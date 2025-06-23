import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:employeeos/view/kanban/presentation/widgets/kanban_group.dart';
import 'package:employeeos/view/kanban/presentation/widgets/kanban_side_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class KanbanGroupCard extends StatelessWidget {
  const KanbanGroupCard({
    super.key,
    required this.title,
    required this.date,
    required this.theme,
    required this.task,
  });
  final ThemeData theme;
  final String title;
  final String date;
  final KanbanGroupItem task;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showRightSideTaskDetails(context, title, date, task),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 300),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(15),
        child: IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge),
                  ),
                  SvgPicture.asset(
                    'assets/icons/arrow/ic-solar_double-alt-arrow-down-bold-duotone.svg',
                    color: AppPallete.infoMain,
                  )
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/ic-calender.svg',
                    color: AppPallete.grey600,
                  ),
                  const SizedBox(width: 5),
                  Text(date,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const Spacer(),
                  const CircleAvatar(
                    radius: 15,
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> showRightSideTaskDetails(
      BuildContext context, String title, String date, KanbanGroupItem task) {
    return showGeneralDialog(
      context: context,
      // Tapping outside the dialog will dismiss it
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      // A semi-transparent background
      barrierColor: Colors.black54,
      pageBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        // The actual widget for your side sheet
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: Colors.transparent,
            // Material gives it a “surface” so it can have its own background color, elevation, etc.
            child: SizedBox(
              width: 350,
              height: double.infinity,
              child: KanbanSideMenu(
                task: task,
              ),
            ),
          ),
        );
      },
      // Optional: animate it in from the right side
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(1.0, 0.0), // Start just off the right edge
          end: Offset.zero,
        ).animate(animation);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }
}
