import 'package:employeeos/core/common/components/custom_bread_crumbs.dart';
import 'package:employeeos/view/user_management/presentation/widgets/user_cards_grid_card.dart';
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
      padding:
          EdgeInsets.only(top: MediaQuery.of(context).padding.top, bottom: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomBreadCrumbs(
            theme: theme,
            routes: const ['Dashboard', 'User', 'Card'],
            heading: 'User Cards',
          ),
          const SizedBox(
            height: 20,
          ),
          Flexible(
              child: GridView.builder(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isGridView ? 2 : 1,
              childAspectRatio: 1.2,
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
