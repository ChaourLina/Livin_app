import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livin_app/core/di/injection.dart';
import 'package:livin_app/features/auth/presentation/views/pages/profile_page.dart';
import 'package:livin_app/features/favorites/presentation/blocs/favorites_bloc/favorites_bloc.dart';
import 'package:livin_app/features/favorites/presentation/blocs/favorites_bloc/favorites_event.dart';
import 'package:livin_app/features/favorites/presentation/views/pages/favorites_page.dart';
import 'package:livin_app/features/listings/presentation/blocs/listings_bloc/listings_bloc.dart';
import 'package:livin_app/features/listings/presentation/blocs/listings_bloc/listings_event.dart';
import 'package:livin_app/features/listings/presentation/views/pages/listings_page.dart';
import 'package:livin_app/features/listings/presentation/views/pages/my_listings_page.dart';

class HomeShell extends StatefulWidget {
  final String userId;

  const HomeShell({super.key, required this.userId});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  bool _listingsDirty = false;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const ListingsPage(),
      const FavoritesPage(),
      MyListingsPage(ownerId: widget.userId),
      const ProfilePage(),
    ];
  }

  void _onSelected(BuildContext context, int index) {
    if (index == _index) return;
    if (_index == 2) _listingsDirty = true;
    if (index == 0 && _listingsDirty) {
      context.read<ListingsBloc>().add(const ListingsRefreshed());
      _listingsDirty = false;
    }
    if (index == 1) {
      context
          .read<FavoritesBloc>()
          .add(FavoritesStarted(userId: widget.userId));
    }
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ListingsBloc>()..add(const ListingsStarted()),
      child: Builder(
        builder: (context) => Scaffold(
          body: IndexedStack(index: _index, children: _pages),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => _onSelected(context, i),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Accueil',
              ),
              NavigationDestination(
                icon: Icon(Icons.favorite_border),
                selectedIcon: Icon(Icons.favorite),
                label: 'Favoris',
              ),
              NavigationDestination(
                icon: Icon(Icons.home_work_outlined),
                selectedIcon: Icon(Icons.home_work),
                label: 'Mes annonces',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}