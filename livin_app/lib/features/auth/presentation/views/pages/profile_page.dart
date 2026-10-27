import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:livin_app/core/router/app_routes.dart';
import 'package:livin_app/features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:livin_app/features/auth/presentation/blocs/auth_bloc/auth_event.dart';
import 'package:livin_app/features/auth/presentation/blocs/auth_bloc/auth_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final bloc = context.read<AuthBloc>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Se déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      bloc.add(const AuthLoggedOut());
    }
  }

  Widget _infoTile(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(icon, color: scheme.primary),
      title: Text(
        label,
        style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
      ),
      subtitle: Text(value, style: Theme.of(context).textTheme.bodyLarge),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Mon profil')),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! AuthSuccess) {
            return const Center(child: CircularProgressIndicator());
          }
          final user = state.user;
          final hasPhoto = user.photoUrl.isNotEmpty;
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 52,
                  backgroundImage:
                      hasPhoto ? NetworkImage(user.photoUrl) : null,
                  child: hasPhoto
                      ? null
                      : Text(
                          user.name.isEmpty ? '?' : user.name[0].toUpperCase(),
                          style: const TextStyle(fontSize: 32),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  user.name,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: scheme.outlineVariant),
                ),
                child: Column(
                  children: [
                    _infoTile(context, Icons.mail_outline, 'Email', user.email),
                    const Divider(height: 1),
                    _infoTile(
                      context,
                      Icons.phone_outlined,
                      'Téléphone',
                      user.phone.isEmpty ? 'Non renseigné' : user.phone,
                    ),
                    const Divider(height: 1),
                    _infoTile(
                      context,
                      Icons.location_on_outlined,
                      'Adresse',
                      user.address.isEmpty ? 'Non renseignée' : user.address,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Modifier le profil'),
                onPressed: () => context.push(AppRoutes.editProfile),
              ),
              const SizedBox(height: 12),
              if (user.isAdmin) ...[
                OutlinedButton.icon(
                  icon: const Icon(Icons.admin_panel_settings_outlined),
                  label: const Text('Espace administrateur'),
                  onPressed: () => context.push(AppRoutes.admin),
                ),
                const SizedBox(height: 12),
              ],
              OutlinedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Se déconnecter'),
                onPressed: () => _confirmLogout(context),
              ),
            ],
          );
        },
      ),
    );
  }
}