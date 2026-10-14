import 'package:flutter/material.dart';
import 'package:livin_app/core/shared/app_theme.dart';
import 'package:livin_app/core/shared/livin_logo.dart';

class WelcomePage extends StatelessWidget {
  final VoidCallback onStart;

  const WelcomePage({super.key, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF3B5668), AppTheme.primary, Color(0xFF1B2B36)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const Spacer(flex: 2),
                const LivinLogo(size: 52, color: Colors.white),
                const SizedBox(height: 14),
                const Text(
                  'Trouvez le logement qui vous ressemble',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.silver, fontSize: 16),
                ),
                const Spacer(flex: 2),
                const Icon(
                  Icons.apartment_rounded,
                  size: 160,
                  color: Color(0x1FFFFFFF),
                ),
                const Spacer(flex: 2),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _Feature(
                      icon: Icons.key_outlined,
                      title: 'Acheter',
                      subtitle: 'Le bien idéal',
                    ),
                    _Feature(
                      icon: Icons.home_outlined,
                      title: 'Louer',
                      subtitle: 'En toute flexibilité',
                    ),
                    _Feature(
                      icon: Icons.add_home_work_outlined,
                      title: 'Publier',
                      subtitle: 'Vos annonces',
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.silver,
                      foregroundColor: AppTheme.primary,
                      minimumSize: const Size(64, 56),
                      shape: const StadiumBorder(),
                    ),
                    onPressed: onStart,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Commencer',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 20),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _Feature({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      child: Column(
        children: [
          Icon(icon, color: AppTheme.silver, size: 30),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.silver, fontSize: 12),
          ),
        ],
      ),
    );
  }
}