import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:livin_app/core/router/app_routes.dart';
import 'package:livin_app/features/favorites/presentation/blocs/favorites_bloc/favorites_bloc.dart';
import 'package:livin_app/features/favorites/presentation/blocs/favorites_bloc/favorites_event.dart';
import 'package:livin_app/features/favorites/presentation/blocs/favorites_bloc/favorites_state.dart';
import 'package:livin_app/features/listings/presentation/views/widgets/listing_card.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes favoris')),
      body: BlocBuilder<FavoritesBloc, FavoritesState>(
        builder: (context, state) {
          if (state is FavoritesFailure) {
            return Center(child: Text(state.message));
          }
          if (state is FavoritesSuccess) {
            if (state.listings.isEmpty) {
              return const Center(child: Text('Aucun favori pour le moment'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.listings.length,
              itemBuilder: (context, index) {
                final listing = state.listings[index];
                return ListingCard(
                  listing: listing,
                  isFavorite: true,
                  onFavoriteTap: () => context
                      .read<FavoritesBloc>()
                      .add(FavoriteToggled(listingId: listing.id)),
                      onTap: () =>
                      context.push(AppRoutes.listing, extra: listing),
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}