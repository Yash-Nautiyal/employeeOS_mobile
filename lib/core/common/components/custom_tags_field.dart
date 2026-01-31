import 'package:flutter/material.dart';
import 'package:textfield_tags/textfield_tags.dart';

import '../../index.dart' show AppPallete;

class CustomTagsField extends StatelessWidget {
  final ThemeData theme;
  final StringTagController stringTagController;
  final List<String> initialTags;
  final String? hintText;
  final String? labelText;
  final Function(String)? onTagsChanged;
  final Function(String)? onSubmitted;
  final FloatingLabelBehavior? floatingLabelBehavior;

  const CustomTagsField({
    super.key,
    required this.theme,
    required this.stringTagController,
    required this.initialTags,
    this.hintText,
    this.labelText,
    this.onTagsChanged,
    this.onSubmitted,
    this.floatingLabelBehavior,
  });

  @override
  Widget build(BuildContext context) {
    return TextFieldTags<String>(
      textfieldTagsController: stringTagController,
      textSeparators: const [' ', ','],
      initialTags: initialTags,
      inputFieldBuilder: (context, inputFieldValues) {
        return TextField(
          onTap: () {
            stringTagController.getFocusNode?.requestFocus();
          },
          onTapOutside: (event) => FocusScope.of(context).parent!.unfocus(),
          controller: inputFieldValues.textEditingController,
          focusNode: inputFieldValues.focusNode,
          decoration: InputDecoration(
            isDense: true,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: theme.dividerColor),
              borderRadius: const BorderRadius.all(Radius.circular(12.0)),
            ),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
            ),
            labelText: labelText != null ? 'Tags' : null,
            labelStyle: theme.textTheme.bodyMedium,
            floatingLabelBehavior:
                floatingLabelBehavior ?? FloatingLabelBehavior.auto,
            hintText: inputFieldValues.tags.isNotEmpty
                ? hintText ?? ''
                : hintText ?? 'Enter tag...',
            errorText: inputFieldValues.error,
            hintStyle: theme.textTheme.bodyMedium,
            prefixIcon: inputFieldValues.tags.isNotEmpty
                ? SingleChildScrollView(
                    controller: inputFieldValues.tagScrollController,
                    scrollDirection: Axis.vertical,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 8,
                        bottom: 8,
                        left: 8,
                      ),
                      child: Wrap(
                        runSpacing: 10.0,
                        spacing: 0,
                        children: inputFieldValues.tags.map((String tag) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                              color: theme.primaryColor,
                            ),
                            margin: const EdgeInsets.symmetric(
                              horizontal: 5.0,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                              vertical: 5.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  child: Text(
                                    tag,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: AppPallete.white,
                                    ),
                                  ),
                                  onTap: () {
                                    //print("$tag selected");
                                  },
                                ),
                                const SizedBox(width: 4.0),
                                InkWell(
                                  child: const Icon(
                                    Icons.cancel,
                                    size: 14.0,
                                    color: AppPallete.white,
                                  ),
                                  onTap: () {
                                    inputFieldValues.onTagRemoved(tag);
                                  },
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  )
                : null,
          ),
          onChanged: onTagsChanged ?? inputFieldValues.onTagChanged,
          onSubmitted: onSubmitted ?? inputFieldValues.onTagSubmitted,
        );
      },
    );
  }
}
