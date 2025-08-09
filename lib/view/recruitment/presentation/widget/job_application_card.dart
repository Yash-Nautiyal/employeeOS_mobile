import 'package:employeeos/core/common/components/custom_dropdown_painter.dart';
import 'package:employeeos/core/common/components/custom_textbutton.dart';
import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class JobApplicationCard extends StatefulWidget {
  final ScrollController scrollController;
  final ThemeData theme;
  const JobApplicationCard(
      {super.key, required this.scrollController, required this.theme});

  @override
  State<JobApplicationCard> createState() => _JobApplicationCardState();
}

class _JobApplicationCardState extends State<JobApplicationCard>
    with SingleTickerProviderStateMixin {
  bool _showDropdown = false;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: widget.scrollController,
      itemCount: 3,
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) => Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 13),
            decoration: BoxDecoration(
              color: widget.theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: widget.theme.shadowColor),
              boxShadow: [
                BoxShadow(
                  color: widget.theme.shadowColor,
                  spreadRadius: 1,
                  blurRadius: 3,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "LAKSHMAN REDDY THUMMALA",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: widget.theme.textTheme.displaySmall
                      ?.copyWith(fontSize: 18),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  "ID: APP1545",
                  style: widget.theme.textTheme.bodyMedium
                      ?.copyWith(color: widget.theme.disabledColor),
                ),
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/common/solid/ic-solar_case-minimalistic-bold.svg',
                      color: widget.theme.disabledColor,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      'Cloud Internship - AWS',
                      style: widget.theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: widget.theme.dividerColor,
                      ),
                    )
                  ],
                ),
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/common/solid/ic-solar_phone-bold.svg',
                      color: widget.theme.disabledColor,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      '9381279955',
                      style: widget.theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: widget.theme.dividerColor,
                      ),
                    )
                  ],
                ),
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/common/solid/ic-fluent_mail-24-filled.svg',
                      color: widget.theme.disabledColor,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      'nautiyalyash4@gmail.com',
                      style: widget.theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: widget.theme.dividerColor,
                      ),
                    )
                  ],
                ),
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/ic-calender.svg',
                      color: widget.theme.disabledColor,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      '02 Aug 2025 2:47 pm',
                      style: widget.theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: widget.theme.dividerColor,
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextButton(
                          backgroundColor: widget.theme.colorScheme.tertiary,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(
                                'assets/icons/common/solid/ic-solar_file-text-bold.svg',
                                color: widget.theme.scaffoldBackgroundColor,
                                width: 20,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                'Resume',
                                style: widget.theme.textTheme.labelLarge
                                    ?.copyWith(
                                        color: widget
                                            .theme.scaffoldBackgroundColor),
                              ),
                            ],
                          ),
                          onClick: () {}),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: SvgPicture.asset(
                        'assets/icons/arrow/ic-eva_checkmark-fill.svg',
                        color: AppPallete.successMain,
                      ),
                    ),
                    IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.close_rounded,
                          color: AppPallete.errorMain,
                        )),
                  ],
                )
              ],
            ),
          ),
          Positioned(
            top: _showDropdown ? 10 : 30,
            right: 30,
            child: AnimatedSlide(
              offset: _showDropdown
                  ? const Offset(0.23, .2)
                  : const Offset(0.23, 0),
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              child: AnimatedOpacity(
                opacity: _showDropdown ? 1 : 0,
                duration: const Duration(
                  milliseconds: 250,
                ),
                child: CustomPaint(
                  painter: CustomDropdownPainter(
                    theme: widget.theme,
                    context: context,
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(
                      top: 12,
                    ), // Space for triangle
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: SvgPicture.asset(
                                'assets/icons/common/solid/ic-solar_eye-bold.svg',
                                color: widget.theme.colorScheme.tertiary,
                              ),
                              onPressed: () {
                                setState(
                                  () => _showDropdown = false,
                                );
                                // Call your delete logic here
                              },
                            ),
                            const SizedBox(width: 8),
                            Text("View",
                                style: widget.theme.textTheme.labelLarge),
                            const SizedBox(width: 8),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: SvgPicture.asset(
                                  'assets/icons/common/solid/ic-solar_pen-bold.svg',
                                  color: widget.theme.colorScheme.tertiary),
                              onPressed: () {
                                setState(
                                  () => _showDropdown = false,
                                );
                                // Call your delete logic here
                              },
                            ),
                            const SizedBox(width: 8),
                            Text("Edit",
                                style: widget.theme.textTheme.labelLarge),
                            const SizedBox(width: 8),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: SvgPicture.asset(
                                  'assets/icons/common/solid/ic-mage-bag.svg',
                                  color: AppPallete.warningMain),
                              onPressed: () {
                                setState(
                                  () => _showDropdown = false,
                                );
                                // Call your delete logic here
                              },
                            ),
                            const SizedBox(width: 8),
                            Text("Close Job",
                                style: widget.theme.textTheme.labelLarge
                                    ?.copyWith(color: AppPallete.warningMain)),
                            const SizedBox(width: 8),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: SvgPicture.asset(
                                'assets/icons/common/solid/ic-solar_trash-bin-trash-bold.svg',
                                color: Colors.red,
                              ),
                              onPressed: () {
                                setState(
                                  () => _showDropdown = false,
                                );
                                // Call your delete logic here
                              },
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "Delete",
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
