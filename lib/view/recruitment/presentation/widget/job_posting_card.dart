import 'package:employeeos/core/index.dart'
    show AppPallete, CustomDivider, CustomDropdownPainter;
import 'package:employeeos/view/recruitment/index.dart'
    show JobPostingCardHeader, JobPostingCardFooter;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class JobPostingCard extends StatefulWidget {
  final ThemeData theme;
  const JobPostingCard({super.key, required this.theme});

  @override
  State<JobPostingCard> createState() => _JobPostingCardState();
}

class _JobPostingCardState extends State<JobPostingCard>
    with SingleTickerProviderStateMixin {
  bool _showDropdown = false;
  bool _closeDropdown = true;

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void toggleDropdown() {
    if (_showDropdown) {
      // Close animation first
      _controller.reverse();
      setState(() {
        _showDropdown = false;
      });
      // Then hide dropdown after animation completes
      Future.delayed(const Duration(milliseconds: 200)).then((_) {
        setState(() {
          _closeDropdown = true;
        });
      });
    } else {
      // First make container visible
      setState(() {
        _closeDropdown = false;
        _showDropdown = false;
      });

      // Then trigger the animation
      Future.microtask(() {
        setState(() {
          _showDropdown = true;
        });
        _controller.forward();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
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
                onSelect: toggleDropdown,
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "Cloud Internship - AWS",
                style:
                    widget.theme.textTheme.displaySmall?.copyWith(fontSize: 20),
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
                style: widget.theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
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
                          width: 5,
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
                          width: 5,
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
                    width: 22,
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
                    width: 22,
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
                padding: const EdgeInsets.only(top: 20.0),
                child: CustomDivider(
                  color: widget.theme.dividerColor,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
                child: JobPostingCardFooter(theme: widget.theme),
              ),
            ],
          ),
        ),
        if (!_closeDropdown)
          Positioned(
            top: 40,
            right: 6,
            child: AnimatedOpacity(
              opacity: _showDropdown ? 1 : 0,
              duration: const Duration(
                milliseconds: 200,
              ),
              child: ScaleTransition(
                scale: _scaleAnimation,
                alignment: Alignment.topRight,
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
    );
  }
}
