import 'package:appflowy_board/appflowy_board.dart'
    show AppFlowyBoardController, AppFlowyGroupData;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class KanbanHeader extends StatelessWidget {
  const KanbanHeader({
    super.key,
    required this.theme,
    required this.columnData,
    required this.controller,
  });
  final ThemeData theme;
  final AppFlowyGroupData<dynamic> columnData;
  final AppFlowyBoardController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20, left: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: theme.colorScheme.surfaceDim, shape: BoxShape.circle),
            child: Text(
              '0',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Flexible(
            child: TextField(
              onTapOutside: (event) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              decoration: const InputDecoration(
                enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
              ),
              controller: TextEditingController()
                ..text = columnData.headerData.groupName,
              keyboardType: TextInputType.text,
              onChanged: (val) {
                controller
                    .getGroupController(columnData.headerData.groupId)!
                    .updateGroupName(val);
              },
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: SvgPicture.asset(
              'assets/icons/common/solid/ic-solar_add-circle-bold.svg',
              color: theme.colorScheme.tertiary,
            ),
          )
        ],
      ),
    );
  }
}
