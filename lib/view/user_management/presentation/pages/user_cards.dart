import 'package:employeeos/core/common/components/custom_bread_crumbs.dart';
import 'package:employeeos/core/user/user_info_entity.dart';
import 'package:employeeos/core/user/user_info_service.dart';
import 'package:employeeos/view/user_management/presentation/widgets/user_cards_grid_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserCards extends StatefulWidget {
  const UserCards({super.key});

  @override
  State<UserCards> createState() => _UserCardsState();
}

class _UserCardsState extends State<UserCards> {
  final ScrollController _scrollController = ScrollController();

  List<UserInfoEntity> _users = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUsers());
  }

  Future<void> _loadUsers() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final users = await context.read<UserInfoService>().fetchAllUsers();
      if (!mounted) return;
      setState(() {
        _users = users;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topPad = MediaQuery.paddingOf(context).top;

    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(0, topPad, 0, 0),
            sliver: SliverToBoxAdapter(
              child: CustomBreadCrumbs(
                theme: theme,
                routes: const ['Dashboard', 'User', 'Card'],
                heading: 'User Cards',
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          if (_loading)
            SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.35,
                child: Center(
                  child: CircularProgressIndicator(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            )
          else if (_error != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Text(
                      'Could not load users.',
                      style: theme.textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.disabledColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _loadUsers,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else if (_users.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'No users found in user_info.',
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 28),
              sliver: SliverLayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.crossAxisExtent;
                  final columns = _crossAxisCount(w);
                  return SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisSpacing: 18,
                      crossAxisSpacing: 14,
                      childAspectRatio: _childAspectRatio(w, columns),
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return UserCardsGridCard(
                          user: _users[index],
                          theme: theme,
                        );
                      },
                      childCount: _users.length,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  int _crossAxisCount(double width) {
    if (width >= 1200) return 4;
    if (width >= 840) return 3;
    if (width >= 520) return 2;
    return 1;
  }

  /// `childAspectRatio` = cell width / cell height (cross / main).
  double _childAspectRatio(double viewportWidth, int columns) {
    if (columns == 1 && viewportWidth < 400) return 0.9;
    if (columns <= 2) return 1.3;
    return 1;
  }
}
