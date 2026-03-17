import 'package:employeeos/core/index.dart'
    show CustomDropdown, CustomTextfield;
import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';

class AdditionalDetailSection extends StatelessWidget {
  final TextEditingController locationController;
  final TextEditingController positionsController;
  final TextEditingController lastDateController;
  final TextEditingController ctcRangeController;
  final TextEditingController postedByNameController;
  final TextEditingController postedByEmailController;
  final String joiningType;
  final bool isInternship;
  final ThemeData theme;
  final ValueChanged<String> onJoiningTypeChanged;
  final ValueChanged<bool> onIsInternshipChanged;
  const AdditionalDetailSection({
    super.key,
    required this.theme,
    required this.locationController,
    required this.positionsController,
    required this.lastDateController,
    required this.joiningType,
    required this.isInternship,
    required this.ctcRangeController,
    required this.postedByNameController,
    required this.postedByEmailController,
    required this.onJoiningTypeChanged,
    required this.onIsInternshipChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: theme.shadowColor, spreadRadius: 0, blurRadius: 4)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Location',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          CustomTextfield(
            controller: locationController,
            theme: theme,
            hintText: 'Enter location...',
            keyboardType: TextInputType.streetAddress,
            onchange: (_) {},
          ),
          const SizedBox(height: 16),
          Text('Positions',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          CustomTextfield(
            controller: positionsController,
            theme: theme,
            hintText: '1',
            keyboardType: TextInputType.number,
            onchange: (_) {},
          ),
          const SizedBox(height: 16),
          Text('Last Date to Apply',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          CustomTextfield(
            controller: lastDateController,
            theme: theme,
            hintText: 'Tap to select date',
            keyboardType: TextInputType.datetime,
            firstDate: DateTime.now(),
            lastDate: DateTime(2030),
            onchange: (_) {},
          ),
          const SizedBox(height: 16),
          Text('Joining Type',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          CustomDropdown(
            theme: theme,
            label: 'Joining Type',
            value: joiningType,
            items: ['Immediate', 'Notice Period', 'Flexible']
                .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
                .toList(),
            onChange: (v) => onJoiningTypeChanged(v as String),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.scale(
                scale: 0.75,
                child: Switch(
                  value: isInternship,
                  onChanged: (v) => onIsInternshipChanged(v),
                ),
              ),
              const SizedBox(width: 8),
              Text('Is this an internship?',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),
          Text('Expected CTC Range',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          CustomTextfield(
            controller: ctcRangeController,
            theme: theme,
            hintText: 'e.g., ₹5-7 LPA',
            keyboardType: TextInputType.text,
            prefix: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text('₹',
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(color: theme.disabledColor)),
            ),
            onchange: (_) {},
          ),
          const SizedBox(height: 6),
          Text('Format: ₹X-Y per Month',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.disabledColor)),
          const SizedBox(height: 16),
          Text('Posted By',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextFormField(
            controller: postedByNameController,
            readOnly: true,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontSize: 14, color: theme.colorScheme.tertiary),
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
              hintText: 'Posted by',
              hintStyle: theme.textTheme.bodyMedium,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(7)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: const BorderSide(color: AppPallete.grey500),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Email',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextFormField(
            controller: postedByEmailController,
            readOnly: true,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontSize: 14, color: theme.colorScheme.tertiary),
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
              hintText: 'Email',
              hintStyle: theme.textTheme.bodyMedium,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(7)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: const BorderSide(color: AppPallete.grey500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
