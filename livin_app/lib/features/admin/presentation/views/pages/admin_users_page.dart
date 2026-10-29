import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livin_app/core/di/injection.dart';
import 'package:livin_app/features/admin/domain/entities/admin_user.dart';
import 'package:livin_app/features/admin/presentation/blocs/admin_users_bloc/admin_users_bloc.dart';
import 'package:livin_app/features/admin/presentation/blocs/admin_users_bloc/admin_users_event.dart';
import 'package:livin_app/features/admin/presentation/blocs/admin_users_bloc/admin_users_state.dart';
import 'package:livin_app/features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:livin_app/features/auth/presentation/blocs/auth_bloc/auth_state.dart';

class AdminUsersPage extends StatelessWidget {
  const AdminUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AdminUsersBloc>()..add(const AdminUsersStarted()),
      child: const _AdminUsersView(),
    );
  }
}

enum _Filter { all, active, blocked }

class _AdminUsersView extends StatefulWidget {
  const _AdminUsersView();

  @override
  State<_AdminUsersView> createState() => _AdminUsersViewState();
}

class _AdminUsersViewState extends State<_AdminUsersView> {
  final _searchController = TextEditingController();
  String _query = '';
  _Filter _filter = _Filter.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String? get _currentUid {
    final state = context.read<AuthBloc>().state;
    return state is AuthSuccess ? state.user.uid : null;
  }

  bool _matches(AdminUser item) {
    final user = item.user;
    if (_filter == _Filter.active && user.isBlocked) return false;
    if (_filter == _Filter.blocked && !user.isBlocked) return false;
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return true;
    final text = '${user.name} ${user.email} ${user.phone}'.toLowerCase();
    return text.contains(query);
  }

  Future<void> _block(BuildContext context, AdminUser item) async {
    final bloc = context.read<AdminUsersBloc>();
    final hideListings = await showDialog<bool>(
      context: context,
      builder: (_) => _BlockDialog(name: item.user.name),
    );
    if (hideListings != null) {
      bloc.add(
        AdminUserBlocked(uid: item.user.uid, hideListings: hideListings),
      );
    }
  }

  Future<void> _unblock(BuildContext context, AdminUser item) async {
    final bloc = context.read<AdminUsersBloc>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Débloquer ${item.user.name} ?'),
        content: const Text(
          'Il pourra de nouveau se connecter. Ses annonces masquées par le '
          'blocage seront remises en ligne.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Débloquer'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      bloc.add(AdminUserUnblocked(uid: item.user.uid));
    }
  }

  Widget _filterChip(String label, _Filter value) {
    return ChoiceChip(
      label: Text(label),
      selected: _filter == value,
      onSelected: (_) => setState(() => _filter = value),
    );
  }

  Widget _card(BuildContext context, AdminUser item) {
    final scheme = Theme.of(context).colorScheme;
    final user = item.user;
    final isSelf = user.uid == _currentUid;
    final canManage = !user.isAdmin && !isSelf;
    final hasPhoto = user.photoUrl.isNotEmpty;
    final count = item.listingsCount;

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
                CircleAvatar(
                  radius: 24,
                  backgroundImage: hasPhoto ? NetworkImage(user.photoUrl) : null,
                  child: hasPhoto
                      ? null
                      : Text(
                          user.name.isEmpty ? '?' : user.name[0].toUpperCase(),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        user.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      if (user.phone.isNotEmpty)
                        Text(
                          user.phone,
                          style: TextStyle(
                            fontSize: 13,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        count == 0
                            ? 'Aucune annonce'
                            : count == 1
                                ? '1 annonce'
                                : '$count annonces',
                        style: TextStyle(
                          fontSize: 13,
                          color: scheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              children: [
                if (user.isAdmin)
                  const Chip(
                    label: Text('Administrateur'),
                    visualDensity: VisualDensity.compact,
                  ),
                if (isSelf)
                  const Chip(
                    label: Text('Vous'),
                    visualDensity: VisualDensity.compact,
                  ),
                if (user.isBlocked)
                  Chip(
                    label: const Text('Bloqué'),
                    backgroundColor: scheme.errorContainer,
                    side: BorderSide.none,
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            if (canManage) ...[
              const Divider(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: user.isBlocked
                    ? OutlinedButton.icon(
                        icon: const Icon(Icons.lock_open_outlined, size: 18),
                        label: const Text('Débloquer'),
                        onPressed: () => _unblock(context, item),
                      )
                    : TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: scheme.error,
                        ),
                        icon: const Icon(Icons.block, size: 18),
                        label: const Text('Bloquer'),
                        onPressed: () => _block(context, item),
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Utilisateurs')),
      body: BlocBuilder<AdminUsersBloc, AdminUsersState>(
        builder: (context, state) {
          if (state is AdminUsersFailure) {
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
                          .read<AdminUsersBloc>()
                          .add(const AdminUsersStarted()),
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (state is! AdminUsersSuccess) {
            return const Center(child: CircularProgressIndicator());
          }

          final all = state.users;
          final blockedCount = all.where((item) => item.user.isBlocked).length;
          final shown = all.where(_matches).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _query = value),
                  decoration: InputDecoration(
                    hintText: 'Rechercher (nom, email, téléphone)…',
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
                      _filterChip('Tous (${all.length})', _Filter.all),
                      _filterChip(
                        'Actifs (${all.length - blockedCount})',
                        _Filter.active,
                      ),
                      _filterChip('Bloqués ($blockedCount)', _Filter.blocked),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: shown.isEmpty
                    ? const Center(child: Text('Aucun utilisateur'))
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

class _BlockDialog extends StatefulWidget {
  final String name;

  const _BlockDialog({required this.name});

  @override
  State<_BlockDialog> createState() => _BlockDialogState();
}

class _BlockDialogState extends State<_BlockDialog> {
  bool _hideListings = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Bloquer ${widget.name} ?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Il ne pourra plus se connecter ni utiliser l\'application.',
          ),
          const SizedBox(height: 8),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: _hideListings,
            onChanged: (value) =>
                setState(() => _hideListings = value ?? true),
            title: const Text('Masquer aussi ses annonces'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_hideListings),
          child: const Text('Bloquer'),
        ),
      ],
    );
  }
}