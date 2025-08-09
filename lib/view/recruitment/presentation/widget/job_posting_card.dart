import 'package:employeeos/core/common/components/custom_divider.dart';
import 'package:employeeos/core/common/components/custom_dropdown_painter.dart';
import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:employeeos/view/recruitment/presentation/widget/job_posting_card_footer.dart';
import 'package:employeeos/view/recruitment/presentation/widget/job_posting_card_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class JobPostingCard extends StatefulWidget {
  final ScrollController scrollController;
  final ThemeData theme;
  const JobPostingCard(
      {super.key, required this.scrollController, required this.theme});

  @override
  State<JobPostingCard> createState() => _JobPostingCardState();
}

class _JobPostingCardState extends State<JobPostingCard>
    with SingleTickerProviderStateMixin {
  bool _showDropdown = false;
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: widget.scrollController,
      itemCount: 3,
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        mainAxisSpacing: 20,
        crossAxisCount: 1,
        crossAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) => Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 13),
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
                JobPostingCardHeader(
                  theme: widget.theme,
                  onSelect: () {
                    setState(() {
                      _showDropdown = !_showDropdown;
                    });
                  },
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  "Cloud Internship - AWS",
                  style: widget.theme.textTheme.displaySmall
                      ?.copyWith(fontSize: 22),
                ),
                Text(
                  "Tech",
                  style: widget.theme.textTheme.bodyMedium
                      ?.copyWith(color: widget.theme.disabledColor),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  'Posted date: 23 Jun 2025',
                  style: widget.theme.textTheme.titleMedium,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Wrap(
                    spacing: 20,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'assets/icons/common/solid/ic-solar_users-group-rounded-bold.svg',
                            color: AppPallete.successMain,
                            width: 20,
                          ),
                          const SizedBox(
                            width: 3,
                          ),
                          Text(
                            '1 position',
                            style: widget.theme.textTheme.labelLarge
                                ?.copyWith(color: AppPallete.successMain),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'assets/icons/common/solid/ic-file-bold.svg',
                            color: AppPallete.infoMain,
                            width: 20,
                          ),
                          const SizedBox(
                            width: 3,
                          ),
                          Text(
                            '190 applications',
                            style: widget.theme.textTheme.labelLarge
                                ?.copyWith(color: AppPallete.infoMain),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/common/solid/ic-solar_user-id-bold.svg',
                      color: widget.theme.disabledColor,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      'Posted by: Yash Nautiyal',
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
                Padding(
                  padding: const EdgeInsets.only(top: 20.0, bottom: 13),
                  child: CustomDivider(
                    color: widget.theme.dividerColor,
                  ),
                ),
                Expanded(
                  child: JobPostingCardFooter(theme: widget.theme),
                )
              ],
            ),
          ),
          Positioned(
            top: _showDropdown ? 10 : 30,
            right: 30,
            child: AnimatedSlide(
              offset:
                  _showDropdown ? const Offset(0.1, .2) : const Offset(0.18, 0),
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
                    constraints: const BoxConstraints(maxWidth: 150),
                    margin: const EdgeInsets.only(
                      top: 12,
                    ), // Space for triangle
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: CustomDivider(
                            color: widget.theme.dividerColor,
                          ),
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
