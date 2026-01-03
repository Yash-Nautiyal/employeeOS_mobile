import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';

class CustomDropdown extends StatefulWidget {
  final dynamic value;
  final ThemeData theme;
  final Function onChange;
  final String label;
  final List<DropdownMenuItem> items;
  const CustomDropdown({
    super.key,
    this.value,
    required this.theme,
    required this.onChange,
    required this.label,
    required this.items,
  });

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField2(
      isExpanded: true,
      value: widget.value,
      enableFeedback: true,
      alignment: AlignmentDirectional.centerStart,
      decoration: InputDecoration(
        isDense: true,
        labelText: widget.label,
        labelStyle: widget.theme.textTheme.bodyMedium,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      style: widget.theme.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: widget.theme.colorScheme.tertiary,
      ),
      dropdownStyleData: DropdownStyleData(
        maxHeight: 230,
        elevation: 8,
        useSafeArea: true,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).brightness == Brightness.dark
                  ? const Color.fromARGB(255, 84, 47, 45)
                  : const Color.fromARGB(255, 253, 239, 226),
              Theme.of(context).brightness == Brightness.dark
                  ? const Color.fromARGB(255, 27, 31, 37)
                  : const Color.fromARGB(255, 251, 251, 251),
              Theme.of(context).brightness == Brightness.dark
                  ? const Color.fromARGB(255, 25, 29, 37)
                  : const Color.fromARGB(255, 251, 251, 251),
              Theme.of(context).brightness == Brightness.dark
                  ? const Color.fromARGB(255, 37, 59, 67)
                  : const Color.fromARGB(255, 224, 255, 255),
            ],
            stops: widget.theme.brightness == Brightness.dark
                ? [0.0, .17, .87, .99]
                : [0.05, 0.3, .7, 0.99],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
        ),
      ),
      items: widget.items,
      onChanged: (value) {
        if (value != null) widget.onChange(value);
      },
    );
  }
}
