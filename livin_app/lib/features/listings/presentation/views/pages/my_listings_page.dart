import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:livin_app/core/router/app_routes.dart';
import 'package:livin_app/core/utils/constants.dart';
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

  String _doneLabel(Listing listing) {
    return listing.transactionType == AppConstants.rent ? 'louée' : 'vendue';
  }

  void _openForm(BuildContext context, {Listing? listing}) {
    final ownerId = _currentUserId(context);
    if (ownerId == null) return;
    context.push(
      AppRoutes.listingForm,
      extra: (ownerId: ownerId, listing: listing),
    );
  }

  Future<void> _confirmMarkDone(BuildContext context, Listing listing) async {
    final bloc = context.read<MyListingsBloc>();
    final label = _doneLabel(listing);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Marquer comme $label ?'),
        content: const Text(
          'Cette annonce ne sera plus visible dans la liste des annonces. '
          'Vous pourrez la réactiver à tout moment.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      bloc.add(MyListingUpdated(listing: listing.copyWith(isAvailable: false)));
    }
  }

  void _reactivate(BuildContext context, Listing listing) {
    context.read<MyListingsBloc>().add(
      MyListingUpdated(listing: listing.copyWith(isAvailable: true)),
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

  Widget _thumbnail(BuildContext context, Listing listing) {
    final scheme = Theme.of(context).colorScheme;
    final hidden = !listing.isAvailable || listing.hiddenByAdmin;
    return SizedBox(
      width: 112,
      height: 112,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Opacity(
            opacity: hidden ? 0.45 : 1,
            child: listing.photos.isEmpty
                ? const ColoredBox(
                    color: Color(0xFFEEF2F2),
                    child: Center(
                      child: Icon(Icons.home_work_outlined, size: 32),
                    ),
                  )
                : Image.network(
                    listing.photos.first,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        const Center(child: Icon(Icons.broken_image_outlined)),
                  ),
          ),
          if (hidden)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  listing.hiddenByAdmin
                      ? 'Masquée'
                      : capitalize(_doneLabel(listing)),
                  style: TextStyle(
                    color: scheme.onPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _listingCard(BuildContext context, Listing listing) {
    final scheme = Theme.of(context).colorScheme;
    final isRent = listing.transactionType == AppConstants.rent;
    final doneLabel = _doneLabel(listing);
    final price = '${formatPrice(listing.price)} DA${isRent ? ' / mois' : ''}';

    return Card(
      elevation: 0,
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _thumbnail(context, listing),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listing.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 15,
                            color: scheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              '${listing.city} · ${capitalize(listing.type)} · ${listing.rooms} ch.',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        price,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: scheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 1),
          if (listing.hiddenByAdmin)
            Container(
              width: double.infinity,
              color: scheme.errorContainer,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                listing.adminNote.isEmpty
                    ? 'Annonce masquée par l\'administrateur.'
                    : 'Annonce masquée par l\'administrateur : ${listing.adminNote}',
                style: TextStyle(color: scheme.onErrorContainer, fontSize: 13),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Wrap(
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Modifier'),
                  onPressed: () => _openForm(context, listing: listing),
                ),
                if (!listing.hiddenByAdmin)
                  TextButton(
                  onPressed: () => listing.isAvailable
                      ? _confirmMarkDone(context, listing)
                      : _reactivate(context, listing),
                  child: Text(
                    listing.isAvailable
                        ? 'Marquer comme $doneLabel'
                        : 'Réactiver',
                  ),
                ),
                IconButton(
                  tooltip: 'Supprimer',
                  icon: Icon(Icons.delete_outline, color: scheme.error),
                  onPressed: () => _confirmDelete(context, listing),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
                      context.read<MyListingsBloc>().add(
                        MyListingsStarted(ownerId: ownerId),
                      );
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }
          if (state is MyListingsSuccess) {
            if (state.listings.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.home_work_outlined, size: 48),
                    const SizedBox(height: 12),
                    const Text('Vous n\'avez pas encore publié d\'annonce'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _openForm(context),
                      child: const Text('Publier ma première annonce'),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
              itemCount: state.listings.length,
              itemBuilder: (context, index) =>
                  _listingCard(context, state.listings[index]),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}