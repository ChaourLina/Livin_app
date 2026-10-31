import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:livin_app/core/di/injection.dart';
import 'package:livin_app/core/router/app_routes.dart';
import 'package:livin_app/features/admin/domain/entities/admin_stats.dart';
import 'package:livin_app/features/admin/presentation/blocs/admin_dashboard_bloc/admin_dashboard_bloc.dart';
import 'package:livin_app/features/admin/presentation/blocs/admin_dashboard_bloc/admin_dashboard_event.dart';
import 'package:livin_app/features/admin/presentation/blocs/admin_dashboard_bloc/admin_dashboard_state.dart';
import 'package:livin_app/features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:livin_app/features/auth/presentation/blocs/auth_bloc/auth_state.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<AdminDashboardBloc>()..add(const AdminDashboardStarted()),
      child: const _AdminHomeView(),
    );
  }
}

class _AdminHomeView extends StatefulWidget {
  const _AdminHomeView();

  @override
  State<_AdminHomeView> createState() => _AdminHomeViewState();
}

class _AdminHomeViewState extends State<_AdminHomeView> {
  // On garde les derniers chiffres : pendant une actualisation, ils restent
  // affichés au lieu de laisser la place à un grand indicateur de chargement.
  AdminStats? _stats;

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final name = authState is AuthSuccess ? authState.user.name : '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Espace administrateur'),
        actions: [
          IconButton(
            tooltip: 'Actualiser',
            icon: const Icon(Icons.refresh),
            onPressed: () => context
                .read<AdminDashboardBloc>()
                .add(const AdminDashboardRefreshed()),
          ),
        ],
      ),
      body: BlocConsumer<AdminDashboardBloc, AdminDashboardState>(
        listener: (context, state) {
          if (state is AdminDashboardSuccess) {
            setState(() => _stats = state.stats);
          } else if (state is AdminDashboardFailure && _stats != null) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          final stats = _stats;

          if (stats == null && state is AdminDashboardFailure) {
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
                          .read<AdminDashboardBloc>()
                          .add(const AdminDashboardRefreshed()),
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (stats == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              if (state is AdminDashboardLoading)
                const LinearProgressIndicator(minHeight: 3),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  children: [
                    _Greeting(name: name),
                    const SizedBox(height: 16),
                    _ListingsCard(stats: stats),
                    const SizedBox(height: 12),
                    _UsersCard(stats: stats),
                    const SizedBox(height: 20),
                    Text(
                      'Outils',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 12),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _ToolCard(
                              icon: Icons.home_work_outlined,
                              title: 'Annonces',
                              subtitle: 'Voir, masquer ou supprimer',
                              badge: stats.hiddenListings > 0
                                  ? '${stats.hiddenListings} masquée'
                                      '${stats.hiddenListings > 1 ? 's' : ''}'
                                  : null,
                              onTap: () => context.push(AppRoutes.adminListings),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ToolCard(
                              icon: Icons.people_outline,
                              title: 'Utilisateurs',
                              subtitle: 'Voir, bloquer ou débloquer',
                              badge: stats.blockedUsers > 0
                                  ? '${stats.blockedUsers} bloqué'
                                      '${stats.blockedUsers > 1 ? 's' : ''}'
                                  : null,
                              onTap: () => context.push(AppRoutes.adminUsers),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  final String name;

  const _Greeting({required this.name});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0x26FFFFFF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.admin_panel_settings_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? 'Bonjour' : 'Bonjour, $name',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Voici l\'état de Livin',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: scheme.secondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ListingsCard extends StatelessWidget {
  final AdminStats stats;

  const _ListingsCard({required this.stats});

  int _percent(int value) {
    if (stats.totalListings == 0) return 0;
    return (value * 100 / stats.totalListings).round();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final online = scheme.primary;
    final closed = scheme.secondary;
    final hidden = scheme.error;

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Annonces',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              if (stats.newListingsLastWeek > 0)
                _Pill(
                  text: '+${stats.newListingsLastWeek} cette semaine',
                  background: scheme.secondaryContainer,
                  foreground: scheme.primary,
                ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              '${stats.totalListings}',
              style: TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.w800,
                color: scheme.primary,
                height: 1,
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (stats.totalListings == 0)
            Text(
              'Aucune annonce pour le moment.',
              style: TextStyle(color: scheme.onSurfaceVariant),
            )
          else
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 12,
                child: Row(
                  children: [
                    if (stats.onlineListings > 0)
                      Expanded(
                        flex: stats.onlineListings,
                        child: ColoredBox(color: online),
                      ),
                    if (stats.closedListings > 0)
                      Expanded(
                        flex: stats.closedListings,
                        child: ColoredBox(color: closed),
                      ),
                    if (stats.hiddenListings > 0)
                      Expanded(
                        flex: stats.hiddenListings,
                        child: ColoredBox(color: hidden),
                      ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          _LegendRow(
            color: online,
            label: 'En ligne',
            value: stats.onlineListings,
            percent: _percent(stats.onlineListings),
          ),
          _LegendRow(
            color: closed,
            label: 'Louées ou vendues',
            value: stats.closedListings,
            percent: _percent(stats.closedListings),
          ),
          _LegendRow(
            color: hidden,
            label: 'Masquées',
            value: stats.hiddenListings,
            percent: _percent(stats.hiddenListings),
          ),
          const Divider(height: 28),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  icon: Icons.key_outlined,
                  value: stats.onlineRent,
                  label: 'Locations en ligne',
                ),
              ),
              Expanded(
                child: _MiniStat(
                  icon: Icons.sell_outlined,
                  value: stats.onlineSale,
                  label: 'Ventes en ligne',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UsersCard extends StatelessWidget {
  final AdminStats stats;

  const _UsersCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final active = stats.totalUsers - stats.blockedUsers;
    final ratio = stats.totalUsers == 0 ? 0.0 : active / stats.totalUsers;

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Utilisateurs',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              '${stats.totalUsers}',
              style: TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.w800,
                color: scheme.primary,
                height: 1,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 10,
              backgroundColor: scheme.errorContainer,
              color: scheme.primary,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Pill(
                text: '$active actif${active > 1 ? 's' : ''}',
                background: scheme.secondaryContainer,
                foreground: scheme.primary,
              ),
              _Pill(
                text: '${stats.adminUsers} administrateur'
                    '${stats.adminUsers > 1 ? 's' : ''}',
                background: scheme.secondaryContainer,
                foreground: scheme.primary,
              ),
              if (stats.blockedUsers > 0)
                _Pill(
                  text: '${stats.blockedUsers} bloqué'
                      '${stats.blockedUsers > 1 ? 's' : ''}',
                  background: scheme.errorContainer,
                  foreground: scheme.onErrorContainer,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  final Widget child;

  const _Panel({required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: child,
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color background;
  final Color foreground;

  const _Pill({
    required this.text,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final int value;
  final int percent;

  const _LegendRow({
    required this.color,
    required this.label,
    required this.value,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '$value',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          SizedBox(
            width: 48,
            child: Text(
              '$percent %',
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;

  const _MiniStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, color: scheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$value',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ToolCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? badge;
  final VoidCallback onTap;

  const _ToolCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: scheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: scheme.primary),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
              ),
              if (badge != null) ...[
                const SizedBox(height: 10),
                _Pill(
                  text: badge!,
                  background: scheme.errorContainer,
                  foreground: scheme.onErrorContainer,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}