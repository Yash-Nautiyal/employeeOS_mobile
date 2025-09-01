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
  final double? fontSize;
  final Widget? helper;
  final Widget? prefix;
  final bool? alwaysFloatingLabel;
  final bool? close;
  final Function? onClose;
  final String? Function(String?)? validator;

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
    this.fontSize,
    this.helper,
    this.prefix,
    this.alwaysFloatingLabel = false,
    this.close = false,
    this.onClose,
    this.validator,
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

    return TextFormField(
      validator: validator,
      keyboardType: keyboardType,
      controller: controller,
      obscureText: isPasswordVisible != null ? !(isPasswordVisible!) : false,
      onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
      onChanged: (value) => onchange(value),
      onTap: isDateTimeField ? () => _selectDate(context) : null,
      readOnly: isDateTimeField,
      maxLines: maxLines,
      minLines: 1,
      style: theme.textTheme.bodyMedium?.copyWith(
          fontSize: fontSize ?? 15, color: theme.colorScheme.tertiary),
      decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          prefixIconConstraints: BoxConstraints.loose(const Size(40, 40)),
          prefixIcon: prefix,
          helper: helper,
          labelText: labelText?.isNotEmpty == true ? labelText : null,
          hintText: hintText,
          hintStyle: theme.textTheme.bodyMedium?.copyWith(fontSize: 15),
          labelStyle: theme.textTheme.bodyMedium
              ?.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
          suffixIcon: _buildSuffixIcon(isDateTimeField, context),
          floatingLabelBehavior: alwaysFloatingLabel ?? false
              ? FloatingLabelBehavior.always
              : null),
    );
  }

  Widget? _buildSuffixIcon(bool isDateTimeField, BuildContext context) {
    if (isPasswordVisible != null) {
      // Password visibility toggle
      return IconButton(
        icon: SvgPicture.asset(
          (isPasswordVisible ?? false)
              ? 'assets/icons/common/solid/ic-solar_eye-bold.svg'
              : 'assets/icons/common/solid/ic-solar_eye-closed-bold.svg',
          color: theme.colorScheme.tertiary,
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
    } else if (close!) {
      return IconButton(
        icon: Icon(Icons.close, color: theme.disabledColor, size: 18),
        onPressed: () => onClose!(),
      );
    } else if (suffixIcon != null) {
      // Custom suffix icon
      return suffixIcon;
    }

    return null;
  }
}
