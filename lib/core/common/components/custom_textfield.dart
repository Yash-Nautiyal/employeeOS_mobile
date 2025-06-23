import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomTextfield extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ThemeData theme;
  final Function onchange;
  final TextInputType keyboardType;
  final String? labelText;
  final bool? isPasswordVisible;
  final Function? onClickPasswordVisisble;
  final int? maxLines;
  final Widget? suffixIcon;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const CustomTextfield({
    super.key,
    required this.controller,
    required this.keyboardType,
    required this.theme,
    required this.onchange,
    required this.hintText,
    this.onClickPasswordVisisble,
    this.labelText,
    this.isPasswordVisible,
    this.maxLines = 1,
    this.suffixIcon,
    this.firstDate,
    this.lastDate,
  });

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: firstDate ?? DateTime(2020),
      lastDate: lastDate ?? DateTime(2030),
    );

    if (picked != null) {
      controller.text = "${picked.day}/${picked.month}/${picked.year}";
      onchange(controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if this is a datetime field
    bool isDateTimeField = keyboardType == TextInputType.datetime;

    return TextField(
      keyboardType: keyboardType,
      controller: controller,
      obscureText: isPasswordVisible != null ? !(isPasswordVisible!) : false,
      onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
      onChanged: (value) => onchange(value),
      onTap: isDateTimeField ? () => _selectDate(context) : null,
      readOnly: isDateTimeField,
      maxLines: maxLines,
      minLines: 1,
      decoration: InputDecoration(
        labelText: labelText?.isNotEmpty == true ? labelText : null,
        hintText: hintText,
        hintStyle: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
        labelStyle: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
        suffixIcon: _buildSuffixIcon(isDateTimeField, context),
      ),
    );
  }

  Widget? _buildSuffixIcon(bool isDateTimeField, BuildContext context) {
    if (isPasswordVisible != null) {
      // Password visibility toggle
      return IconButton(
        icon: Icon(
          (isPasswordVisible ?? false)
              ? Icons.visibility
              : Icons.visibility_off,
        ),
        onPressed: () {
          if (onClickPasswordVisisble != null) {
            onClickPasswordVisisble!();
          }
        },
      );
    } else if (keyboardType == TextInputType.datetime) {
      return IconButton(
        onPressed: () => _selectDate(context),
        icon: SvgPicture.asset(
          'assets/icons/common/solid/ic-solar-calendar-mark-bold-duotone.svg',
          color: theme.disabledColor,
          height: 20,
          width: 20,
        ),
      );
    } else if (suffixIcon != null) {
      // Custom suffix icon
      return suffixIcon;
    }

    return null;
  }
}
