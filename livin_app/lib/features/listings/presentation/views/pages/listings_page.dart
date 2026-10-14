import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livin_app/core/shared/livin_logo.dart';
import 'package:livin_app/core/utils/constants.dart';
import 'package:livin_app/core/utils/formatters.dart';
import 'package:livin_app/features/favorites/presentation/blocs/favorites_bloc/favorites_bloc.dart';
import 'package:livin_app/features/favorites/presentation/blocs/favorites_bloc/favorites_event.dart';
import 'package:livin_app/features/favorites/presentation/blocs/favorites_bloc/favorites_state.dart';
import 'package:livin_app/features/listings/domain/entities/listing_filter.dart';
import 'package:livin_app/features/listings/presentation/blocs/listings_bloc/listings_bloc.dart';
import 'package:livin_app/features/listings/presentation/blocs/listings_bloc/listings_event.dart';
import 'package:livin_app/features/listings/presentation/blocs/listings_bloc/listings_state.dart';
import 'package:livin_app/features/listings/presentation/views/pages/listing_details_page.dart';
import 'package:livin_app/features/listings/presentation/views/widgets/listing_card.dart';

class ListingsPage extends StatefulWidget {
  const ListingsPage({super.key});

  @override
  State<ListingsPage> createState() => _ListingsPageState();
}

class _ListingsPageState extends State<ListingsPage> {
  final _searchController = TextEditingController();
  String _query = '';
  String? _transaction;
  String? _type;
  String? _city;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    context.read<ListingsBloc>().add(
          ListingsFilterChanged(
            filter: ListingFilter(
              query: _query.isEmpty ? null : _query,
              transactionType: _transaction,
              city: _city,
              type: _type,
            ),
          ),
        );
  }

  void _toggleTransaction(String value) {
    setState(() => _transaction = _transaction == value ? null : value);
    _applyFilters();
  }

  void _toggleType(String value) {
    setState(() => _type = _type == value ? null : value);
    _applyFilters();
  }

  Future<void> _pickCity() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: const Text('Toutes les villes'),
              onTap: () => Navigator.pop(sheetContext, ''),
            ),
            ...AppConstants.cities.map(
              (city) => ListTile(
                title: Text(city),
                trailing: city == _city ? const Icon(Icons.check) : null,
                onTap: () => Navigator.pop(sheetContext, city),
              ),
            ),
          ],
        ),
      ),
    );
    if (selected == null) return;
    setState(() => _city = selected.isEmpty ? null : selected);
    _applyFilters();
  }

  Widget _chip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final textColor = selected ? Colors.white : scheme.primary;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        avatar: icon == null ? null : Icon(icon, size: 18, color: textColor),
        selected: selected,
        showCheckmark: false,
        onSelected: (_) => onTap(),
        selectedColor: scheme.primary,
        backgroundColor: Colors.white,
        side: BorderSide(
          color: selected ? scheme.primary : scheme.outlineVariant,
        ),
        shape: const StadiumBorder(),
        labelStyle: TextStyle(color: textColor, fontWeight: FontWeight.w600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    OutlineInputBorder searchBorder(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const LivinLogo(),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onChanged: (_) => setState(() {}),
              onSubmitted: (value) {
                setState(() => _query = value.trim());
                _applyFilters();
              },
              decoration: InputDecoration(
                hintText: 'Rechercher une ville, un type, un mot-clé…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                          _applyFilters();
                        },
                      ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: searchBorder(scheme.outlineVariant),
                enabledBorder: searchBorder(scheme.outlineVariant),
                focusedBorder: searchBorder(scheme.primary, 1.6),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
            child: Row(
              children: [
                _chip(
                  label: 'Tous',
                  selected: _transaction == null && _type == null,
                  onTap: () {
                    setState(() {
                      _transaction = null;
                      _type = null;
                    });
                    _applyFilters();
                  },
                ),
                _chip(
                  label: 'Location',
                  selected: _transaction == AppConstants.rent,
                  onTap: () => _toggleTransaction(AppConstants.rent),
                ),
                _chip(
                  label: 'Vente',
                  selected: _transaction == AppConstants.sale,
                  onTap: () => _toggleTransaction(AppConstants.sale),
                ),
                for (final type in AppConstants.propertyTypes)
                  _chip(
                    label: capitalize(type),
                    selected: _type == type,
                    onTap: () => _toggleType(type),
                  ),
                _chip(
                  label: _city ?? 'Ville',
                  icon: Icons.location_on_outlined,
                  selected: _city != null,
                  onTap: _pickCity,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
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
                          onPressed: () => context
                              .read<ListingsBloc>()
                              .add(const ListingsRefreshed()),
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
                  final count = state.listings.length;
                  final label =
                      count > 1 ? '$count annonces' : '$count annonce';
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: count + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            label,
                            style: TextStyle(color: scheme.onSurfaceVariant),
                          ),
                        );
                      }
                      final listing = state.listings[index - 1];
                      return BlocBuilder<FavoritesBloc, FavoritesState>(
                        builder: (context, favState) {
                          final isFavorite = favState is FavoritesSuccess &&
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