import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:livin_app/core/router/app_routes.dart';
import 'package:livin_app/core/utils/formatters.dart';
import 'package:livin_app/features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:livin_app/features/auth/presentation/blocs/auth_bloc/auth_state.dart';
import 'package:livin_app/features/listings/domain/entities/listing.dart';
import 'package:livin_app/features/listings/presentation/blocs/my_listings_bloc/my_listings_bloc.dart';
import 'package:livin_app/features/listings/presentation/blocs/my_listings_bloc/my_listings_event.dart';
import 'package:livin_app/features/listings/presentation/blocs/my_listings_bloc/my_listings_state.dart';

class MyListingsPage extends StatelessWidget {
  const MyListingsPage({super.key});

  String? _currentUserId(BuildContext context) {
    final auth = context.read<AuthBloc>().state;
    return auth is AuthSuccess ? auth.user.uid : null;
  }

  void _openForm(BuildContext context, {Listing? listing}) {
    final ownerId = _currentUserId(context);
    if (ownerId == null) return;
    context.push(
      AppRoutes.listingForm,
      extra: (ownerId: ownerId, listing: listing),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Listing listing) async {
    final bloc = context.read<MyListingsBloc>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Supprimer l\'annonce ?'),
        content: Text(listing.title),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      bloc.add(MyListingDeleted(listingId: listing.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes annonces')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Publier une annonce'),
      ),
      body: BlocBuilder<MyListingsBloc, MyListingsState>(
        builder: (context, state) {
          if (state is MyListingsFailure) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      final ownerId = _currentUserId(context);
                      if (ownerId == null) return;
                      context
                          .read<MyListingsBloc>()
                          .add(MyListingsStarted(ownerId: ownerId));
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }
          if (state is MyListingsSuccess) {
            if (state.listings.isEmpty) {
              return const Center(
                child: Text('Vous n\'avez pas encore publié d\'annonce'),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
              itemCount: state.listings.length,
              itemBuilder: (context, index) {
                final listing = state.listings[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(listing.title),
                    subtitle: Text(
                      '${capitalize(listing.type)} · ${listing.city} · ${formatPrice(listing.price)} DA',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => _openForm(context, listing: listing),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _confirmDelete(context, listing),
                        ),
                      ],
                    ),
                  ),
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