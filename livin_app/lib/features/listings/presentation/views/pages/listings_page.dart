import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livin_app/core/di/injection.dart';
import 'package:livin_app/core/utils/constants.dart';
import 'package:livin_app/core/utils/formatters.dart';
import 'package:livin_app/features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:livin_app/features/auth/presentation/blocs/auth_bloc/auth_event.dart';
import 'package:livin_app/features/favorites/presentation/blocs/favorites_bloc/favorites_bloc.dart';
import 'package:livin_app/features/favorites/presentation/blocs/favorites_bloc/favorites_event.dart';
import 'package:livin_app/features/favorites/presentation/blocs/favorites_bloc/favorites_state.dart';
import 'package:livin_app/features/favorites/presentation/views/pages/favorites_page.dart';
import 'package:livin_app/features/listings/domain/entities/listing_filter.dart';
import 'package:livin_app/features/listings/presentation/blocs/listings_bloc/listings_bloc.dart';
import 'package:livin_app/features/listings/presentation/blocs/listings_bloc/listings_event.dart';
import 'package:livin_app/features/listings/presentation/blocs/listings_bloc/listings_state.dart';
import 'package:livin_app/features/listings/presentation/views/pages/listing_details_page.dart';
import 'package:livin_app/features/listings/presentation/views/widgets/listing_card.dart';
import 'package:livin_app/features/auth/presentation/blocs/auth_bloc/auth_state.dart';
import 'package:livin_app/features/listings/presentation/views/pages/my_listings_page.dart';

class ListingsPage extends StatelessWidget {
  const ListingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ListingsBloc>()..add(const ListingsStarted()),
      child: const _ListingsView(),
    );
  }
}

class _ListingsView extends StatefulWidget {
  const _ListingsView();

  @override
  State<_ListingsView> createState() => _ListingsViewState();
}

class _ListingsViewState extends State<_ListingsView> {
  String? _transaction;
  String? _city;
  String? _type;

  void _applyFilters() {
    context.read<ListingsBloc>().add(
      ListingsFilterChanged(
        filter: ListingFilter(
          transactionType: _transaction,
          city: _city,
          type: _type,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Livin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            tooltip: 'Favoris',
            onPressed: () {
              final favoritesBloc = context.read<FavoritesBloc>();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: favoritesBloc,
                    child: const FavoritesPage(),
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: 'Mes annonces',
            onPressed: () {
              final authState = context.read<AuthBloc>().state;
              if (authState is! AuthSuccess) return;
              final listingsBloc = context.read<ListingsBloc>();
              Navigator.of(context)
                  .push(
                    MaterialPageRoute(
                      builder: (_) =>
                          MyListingsPage(ownerId: authState.user.uid),
                    ),
                  )
                  .then((_) => listingsBloc.add(const ListingsRefreshed()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () =>
                context.read<AuthBloc>().add(const AuthLoggedOut()),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment<String>(value: 'all', label: Text('Tous')),
                  ButtonSegment<String>(
                    value: AppConstants.sale,
                    label: Text('Vente'),
                  ),
                  ButtonSegment<String>(
                    value: AppConstants.rent,
                    label: Text('Location'),
                  ),
                ],
                selected: {_transaction ?? 'all'},
                onSelectionChanged: (selection) {
                  final value = selection.first;
                  setState(() => _transaction = value == 'all' ? null : value);
                  _applyFilters();
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<String?>(
                    isExpanded: true,
                    value: _city,
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Toutes les villes'),
                      ),
                      ...AppConstants.cities.map(
                        (city) => DropdownMenuItem<String?>(
                          value: city,
                          child: Text(city),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => _city = value);
                      _applyFilters();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButton<String?>(
                    isExpanded: true,
                    value: _type,
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Tous les types'),
                      ),
                      ...AppConstants.propertyTypes.map(
                        (type) => DropdownMenuItem<String?>(
                          value: type,
                          child: Text(capitalize(type)),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => _type = value);
                      _applyFilters();
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<ListingsBloc, ListingsState>(
              builder: (context, state) {
                if (state is ListingsFailure) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(state.message),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => context.read<ListingsBloc>().add(
                            const ListingsRefreshed(),
                          ),
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  );
                }
                if (state is ListingsSuccess) {
                  if (state.listings.isEmpty) {
                    return const Center(child: Text('Aucune annonce trouvée'));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.listings.length,
                    itemBuilder: (context, index) {
                      final listing = state.listings[index];
                      return BlocBuilder<FavoritesBloc, FavoritesState>(
                        builder: (context, favState) {
                          final isFavorite =
                              favState is FavoritesSuccess &&
                              favState.favoriteIds.contains(listing.id);
                          return ListingCard(
                            listing: listing,
                            isFavorite: isFavorite,
                            onFavoriteTap: () => context
                                .read<FavoritesBloc>()
                                .add(FavoriteToggled(listingId: listing.id)),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    ListingDetailsPage(listing: listing),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }
}
