import 'package:employeeos/core/index.dart'
    show AppPallete, CustomDivider, ResponsivePopupController;
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

  final GlobalKey _popupAnchorKey = GlobalKey();
  final LayerLink _layerLink = LayerLink();
  final ResponsivePopupController _popupController =
      ResponsivePopupController();

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
    _popupController.dispose();
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
    return Container(
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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: JobPostingCardHeader(
              theme: widget.theme,
              onSelect: toggleDropdown,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            "Cloud Internship - AWS",
            style: widget.theme.textTheme.displaySmall?.copyWith(fontSize: 20),
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
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
            child: JobPostingCardFooter(theme: widget.theme),
          ),
        ],
      ),
    );
  }
}
