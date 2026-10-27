import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:livin_app/features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:livin_app/features/auth/presentation/blocs/auth_bloc/auth_state.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final state = context.watch<AuthBloc>().state;
    final name = state is AuthSuccess ? state.user.name : '';

    return Scaffold(
      appBar: AppBar(title: const Text('Espace administrateur')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: scheme.outlineVariant),
            ),
            child: ListTile(
              leading: Icon(
                Icons.admin_panel_settings_outlined,
                color: scheme.primary,
              ),
              title: Text('Connecté en tant que $name'),
              subtitle: const Text('Rôle : administrateur'),
            ),
          ),
          const SizedBox(height: 16),
          const ListTile(
            enabled: false,
            leading: Icon(Icons.home_work_outlined),
            title: Text('Annonces'),
            subtitle: Text('Modération : étape suivante'),
          ),
          const ListTile(
            enabled: false,
            leading: Icon(Icons.people_outline),
            title: Text('Utilisateurs'),
            subtitle: Text('Gestion et blocage : étape suivante'),
          ),
        ],
      ),
    );
  }
}