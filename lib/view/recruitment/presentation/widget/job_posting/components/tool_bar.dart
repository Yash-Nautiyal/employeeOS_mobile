import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class ToolBar extends StatelessWidget {
  final QuillController controller;
  final ThemeData theme;
  final VoidCallback openDescriptionFullScreen;
  final bool isFullScreen;
  const ToolBar({
    super.key,
    required this.controller,
    required this.theme,
    required this.openDescriptionFullScreen,
    required this.isFullScreen,
  });

  @override
  Widget build(BuildContext context) {
    return QuillSimpleToolbar(
      controller: controller,
      config: QuillSimpleToolbarConfig(
        toolbarIconCrossAlignment: WrapCrossAlignment.center,
        toolbarIconAlignment: WrapAlignment.start,
        dialogTheme: QuillDialogTheme(
          shape: BeveledRectangleBorder(
            side: BorderSide(color: theme.dividerColor),
          ),
          isWrappable: true,
        ),
        iconTheme: QuillIconTheme(
          iconButtonUnselectedData: IconButtonData(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            color: theme.iconTheme.color ??
                theme.textTheme.bodyLarge?.color ??
                theme.colorScheme.onSurface,
            style: ButtonStyle(
              shape: WidgetStateProperty.all(const CircleBorder()),
            ),
          ),
          iconButtonSelectedData: IconButtonData(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            color: theme.primaryColor,
            style: ButtonStyle(
              shape: WidgetStateProperty.all(const CircleBorder()),
            ),
          ),
        ),
        buttonOptions: QuillSimpleToolbarButtonOptions(
          selectHeaderStyleButtons: QuillToolbarSelectHeaderStyleButtonsOptions(
            iconTheme: QuillIconTheme(
              iconButtonUnselectedData: IconButtonData(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                color: theme.iconTheme.color ??
                    theme.textTheme.bodyLarge?.color ??
                    theme.scaffoldBackgroundColor,
                style: ButtonStyle(
                  shape: WidgetStateProperty.all(const CircleBorder()),
                ),
              ),
              iconButtonSelectedData: IconButtonData(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                color: theme.colorScheme.onSurface,
                style: ButtonStyle(
                  shape: WidgetStateProperty.all(const CircleBorder()),
                ),
              ),
            ),
          ),
        ),
        customButtons: [
          QuillToolbarCustomButtonOptions(
            icon: isFullScreen
                ? const Icon(Icons.fullscreen_exit_rounded)
                : const Icon(Icons.fullscreen_rounded),
            tooltip: isFullScreen ? 'Exit full screen' : 'Full screen',
            onPressed: openDescriptionFullScreen,
          ),
        ],
        showHeaderStyle: true,
        linkStyleType: LinkStyleType.original,
        headerStyleType: HeaderStyleType.buttons,
        showAlignmentButtons: true,
        showColorButton: false,
        showBackgroundColorButton: false,
        showFontFamily: false,
        showCodeBlock: false,
        showInlineCode: false,
        showFontSize: false,
        showUndo: false,
        showRedo: false,
        showSearchButton: false,
        showSuperscript: false,
        showSubscript: false,
        showClearFormat: true,
        showListCheck: false,
        showQuote: false,
        showClipboardPaste: false,
        sectionDividerColor: theme.dividerColor,
      ),
    );
  }
}
