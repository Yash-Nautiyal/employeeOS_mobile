import 'package:employeeos/view/user_management/presentation/widgets/user_cards_grid_card.dart';
import 'package:employeeos/view/user_management/presentation/widgets/user_heading.dart';
import 'package:flutter/material.dart';

class UserCards extends StatefulWidget {
  const UserCards({super.key});

  @override
  State<UserCards> createState() => _UserCardsState();
}

class _UserCardsState extends State<UserCards> {
  final scrollController = ScrollController();
  late bool isGridView;
  final List<UserCard> userCards = [
    UserCard(
      name: 'Jayvion Simon',
      title: 'CEO',
      followers: '12.2k',
      following: '62.3k',
      totalPosts: '31.1k',
      backgroundImage: 'assets/images/background/card1.jpg',
      avatar: 'assets/images/avatar1.jpg',
    ),
    UserCard(
      name: 'Jayvion Simon',
      title: 'CEO',
      followers: '47.9k',
      following: '73.9k',
      totalPosts: '72.1k',
      backgroundImage: 'assets/images/background/card2.jpg',
      avatar: 'assets/images/avatar2.jpg',
    ),
    UserCard(
      name: 'Jayvion Simon',
      title: 'CEO',
      followers: '89.4k',
      following: '50.1k',
      totalPosts: '73.9k',
      backgroundImage: 'assets/images/background/card3.jpg',
      avatar: 'assets/images/avatar3.jpg',
    ),
  ];

  @override
  void initState() {
    super.initState();
    isGridView = false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.only(top: 120, bottom: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          UserHeading(theme: theme, page: 'Cards'),
          const SizedBox(
            height: 20,
          ),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.end,
          //   children: [
          //     Text(
          //       "ListView",
          //       style: theme.textTheme.titleMedium
          //           ?.copyWith(color: theme.disabledColor),
          //     ),
          //     Transform.scale(
          //       scale: .7,
          //       child: Switch(
          //           value: isGridView,
          //           activeTrackColor: AppPallete.successMain,
          //           activeColor: AppPallete.white,
          //           onChanged: (value) {
          //             setState(() {
          //               isGridView = value;
          //             });
          //           }),
          //     ),
          //   ],
          // ),
          Flexible(
              child: GridView.builder(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isGridView ? 2 : 1,
              childAspectRatio: 1,
              mainAxisSpacing: 24,
              crossAxisSpacing: 10,
            ),
            itemCount: userCards.length,
            itemBuilder: (context, index) {
              return UserCardsGridCard(
                card: userCards[index],
                theme: theme,
              );
            },
          )),
        ],
      ),
    );
  }
}
