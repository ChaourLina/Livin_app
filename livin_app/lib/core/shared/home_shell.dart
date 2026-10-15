import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:livin_app/core/shared/offline_banner.dart';
import 'package:livin_app/features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:livin_app/features/auth/presentation/blocs/auth_bloc/auth_state.dart';
import 'package:livin_app/features/favorites/presentation/blocs/favorites_bloc/favorites_bloc.dart';
import 'package:livin_app/features/favorites/presentation/blocs/favorites_bloc/favorites_event.dart';
import 'package:livin_app/features/listings/presentation/blocs/listings_bloc/listings_bloc.dart';
import 'package:livin_app/features/listings/presentation/blocs/listings_bloc/listings_event.dart';
import 'package:livin_app/features/listings/presentation/blocs/my_listings_bloc/my_listings_bloc.dart';
import 'package:livin_app/features/listings/presentation/blocs/my_listings_bloc/my_listings_state.dart';

class HomeShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const HomeShell({super.key, required this.navigationShell});

  void _onReconnected(BuildContext context) {
    context.read<ListingsBloc>().add(const ListingsRefreshed());
    final auth = context.read<AuthBloc>().state;
    if (auth is AuthSuccess) {
      context.read<FavoritesBloc>().add(FavoritesStarted(userId: auth.user.uid));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MyListingsBloc, MyListingsState>(
      listenWhen: (previous, current) =>
          previous is MyListingsLoading && current is MyListingsSuccess,
      listener: (context, state) =>
          context.read<ListingsBloc>().add(const ListingsRefreshed()),
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            OfflineBanner(onReconnected: () => _onReconnected(context)),
            NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: (index) => navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              ),
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
          ],
        ),
      ),
    );
  }
}