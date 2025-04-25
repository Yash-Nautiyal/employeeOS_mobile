import 'package:employeeos/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ChatInput extends StatefulWidget {
  final ThemeData theme;
  final void Function(String text) onSendText;
  final VoidCallback onPickImage;
  final VoidCallback onPickFile;
  const ChatInput(
      {super.key,
      required this.theme,
      required this.onSendText,
      required this.onPickImage,
      required this.onPickFile});

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        color: widget.theme.colorScheme.surfaceContainer,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {},
                constraints: const BoxConstraints(
                  maxWidth: 32,
                  maxHeight: 32,
                ),
                icon: SvgPicture.asset(
                  "assets/icons/common/solid/ic-eva_smiling-face-outline.svg",
                  color: AppPallete.grey600,
                  width: 23,
                  height: 23,
                ),
              ),
              Expanded(
                  child: TextField(
                controller: controller,
                onChanged: (value) {
                  setState(() {
                    controller.text = value;
                  });
                },
                onTapOutside: (event) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                minLines: 1,
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  hintText: "Type a message",
                  hintStyle: widget.theme.textTheme.bodyMedium?.copyWith(
                    color: AppPallete.grey600,
                  ),
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 10,
                  ),
                ),
              )),
              IconButton(
                onPressed: () {
                  final text = controller.text.trim();
                  if (text.isNotEmpty) {
                    widget.onSendText(text);
                    controller.clear();
                    setState(() {});
                  }
                },
                constraints: const BoxConstraints(
                  minWidth: 37,
                  minHeight: 37,
                ),
                icon: SvgPicture.asset(
                  "assets/icons/common/solid/ic-solar-plain-bold.svg",
                  color: AppPallete.grey600,
                  width: 20,
                  height: 20,
                ),
              ),
              IconButton(
                onPressed: widget.onPickImage,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
                icon: SvgPicture.asset(
                  "assets/icons/common/solid/ic-solar_gallery-add-bold.svg",
                  color: AppPallete.grey600,
                  width: 20,
                  height: 20,
                ),
              ),
              IconButton(
                onPressed: widget.onPickFile,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
                icon: SvgPicture.asset(
                  "assets/icons/common/solid/ic-eva_attach-2-fill.svg",
                  color: AppPallete.grey600,
                  width: 20,
                  height: 20,
                ),
              ),
              IconButton(
                onPressed: () {},
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
                icon: SvgPicture.asset(
                  "assets/icons/common/solid/ic-solar_microphone-bold.svg",
                  color: AppPallete.grey600,
                  width: 20,
                  height: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
