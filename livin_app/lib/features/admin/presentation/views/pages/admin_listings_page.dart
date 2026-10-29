import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:livin_app/core/di/injection.dart';
import 'package:livin_app/core/router/app_routes.dart';
import 'package:livin_app/core/utils/constants.dart';
import 'package:livin_app/core/utils/formatters.dart';
import 'package:livin_app/features/admin/domain/entities/admin_listing.dart';
import 'package:livin_app/features/admin/presentation/blocs/admin_listings_bloc/admin_listings_bloc.dart';
import 'package:livin_app/features/admin/presentation/blocs/admin_listings_bloc/admin_listings_event.dart';
import 'package:livin_app/features/admin/presentation/blocs/admin_listings_bloc/admin_listings_state.dart';

class AdminListingsPage extends StatelessWidget {
  const AdminListingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<AdminListingsBloc>()..add(const AdminListingsStarted()),
      child: const _AdminListingsView(),
    );
  }
}

enum _Filter { all, visible, hidden }

class _AdminListingsView extends StatefulWidget {
  const _AdminListingsView();

  @override
  State<_AdminListingsView> createState() => _AdminListingsViewState();
}

class _AdminListingsViewState extends State<_AdminListingsView> {
  final _searchController = TextEditingController();
  String _query = '';
  _Filter _filter = _Filter.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matches(AdminListing item) {
    final listing = item.listing;
    if (_filter == _Filter.visible && listing.hiddenByAdmin) return false;
    if (_filter == _Filter.hidden && !listing.hiddenByAdmin) return false;
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return true;
    final text =
        '${listing.title} ${listing.city} ${item.ownerName} ${item.ownerEmail}'
            .toLowerCase();
    return text.contains(query);
  }

  Future<void> _hide(BuildContext context, AdminListing item) async {
    final bloc = context.read<AdminListingsBloc>();
    final note = await showDialog<String>(
      context: context,
      builder: (_) => const _HideDialog(),
    );
    if (note != null) {
      bloc.add(AdminListingHidden(listingId: item.listing.id, note: note));
    }
  }

  Future<void> _delete(BuildContext context, AdminListing item) async {
    final bloc = context.read<AdminListingsBloc>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Supprimer définitivement ?'),
        content: Text(
          '« ${item.listing.title} » sera supprimée pour tous les utilisateurs. '
          'Cette action est irréversible.',
        ),
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
      bloc.add(AdminListingDeleted(listingId: item.listing.id));
    }
  }

  Widget _filterChip(String label, _Filter value) {
    return ChoiceChip(
      label: Text(label),
      selected: _filter == value,
      onSelected: (_) => setState(() => _filter = value),
    );
  }

  Widget _statusChip(BuildContext context, AdminListing item) {
    final scheme = Theme.of(context).colorScheme;
    final listing = item.listing;
    if (listing.hiddenByAdmin) {
      return Chip(
        label: const Text('Masquée par l\'admin'),
        backgroundColor: scheme.errorContainer,
        side: BorderSide.none,
        visualDensity: VisualDensity.compact,
      );
    }
    if (!listing.isAvailable) {
      final done =
          listing.transactionType == AppConstants.rent ? 'Louée' : 'Vendue';
      return Chip(
        label: Text(done),
        visualDensity: VisualDensity.compact,
      );
    }
    return const SizedBox.shrink();
  }

  Widget _card(BuildContext context, AdminListing item) {
    final scheme = Theme.of(context).colorScheme;
    final listing = item.listing;
    final isRent = listing.transactionType == AppConstants.rent;
    final price = '${formatPrice(listing.price)} DA${isRent ? ' / mois' : ''}';

    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 72,
                    height: 72,
                    child: listing.photos.isEmpty
                        ? const ColoredBox(
                            color: Color(0xFFEEF2F2),
                            child: Icon(Icons.home_work_outlined),
                          )
                        : Image.network(
                            listing.photos.first,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                const Icon(Icons.broken_image_outlined),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listing.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Par ${item.ownerName} · ${listing.city}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      if (item.ownerEmail.isNotEmpty)
                        Text(
                          item.ownerEmail,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        price,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: scheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: _statusChip(context, item),
            ),
            if (listing.hiddenByAdmin && listing.adminNote.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Motif : ${listing.adminNote}',
                  style: TextStyle(
                    fontSize: 13,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            const Divider(height: 16),
            Wrap(
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: const Text('Voir'),
                  onPressed: () =>
                      context.push(AppRoutes.listing, extra: listing),
                ),
                if (listing.hiddenByAdmin)
                  TextButton.icon(
                    icon: const Icon(Icons.replay, size: 18),
                    label: const Text('Réactiver'),
                    onPressed: () => context.read<AdminListingsBloc>().add(
                          AdminListingRestored(listingId: listing.id),
                        ),
                  )
                else
                  TextButton.icon(
                    icon: const Icon(Icons.visibility_off_outlined, size: 18),
                    label: const Text('Masquer'),
                    onPressed: () => _hide(context, item),
                  ),
                IconButton(
                  tooltip: 'Supprimer',
                  icon: Icon(Icons.delete_outline, color: scheme.error),
                  onPressed: () => _delete(context, item),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Modération des annonces')),
      body: BlocBuilder<AdminListingsBloc, AdminListingsState>(
        builder: (context, state) {
          if (state is AdminListingsFailure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.message, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => context
                          .read<AdminListingsBloc>()
                          .add(const AdminListingsStarted()),
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (state is! AdminListingsSuccess) {
            return const Center(child: CircularProgressIndicator());
          }

          final all = state.items;
          final hiddenCount =
              all.where((item) => item.listing.hiddenByAdmin).length;
          final shown = all.where(_matches).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _query = value),
                  decoration: InputDecoration(
                    hintText: 'Rechercher (titre, ville, propriétaire)…',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: scheme.outlineVariant),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: scheme.outlineVariant),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 8,
                    children: [
                      _filterChip('Toutes (${all.length})', _Filter.all),
                      _filterChip(
                        'En ligne (${all.length - hiddenCount})',
                        _Filter.visible,
                      ),
                      _filterChip('Masquées ($hiddenCount)', _Filter.hidden),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: shown.isEmpty
                    ? const Center(child: Text('Aucune annonce'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: shown.length,
                        itemBuilder: (context, index) =>
                            _card(context, shown[index]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HideDialog extends StatefulWidget {
  const _HideDialog();

  @override
  State<_HideDialog> createState() => _HideDialogState();
}

class _HideDialogState extends State<_HideDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Masquer cette annonce ?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Elle disparaîtra de l\'application. Le propriétaire verra le motif '
            'et ne pourra pas la réactiver.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            maxLength: 140,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Motif (facultatif)',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          child: const Text('Masquer'),
        ),
      ],
    );
  }
}