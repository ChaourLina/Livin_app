import 'package:flutter/material.dart';
import 'package:livin_app/core/shared/app_theme.dart';
import 'package:livin_app/core/shared/livin_logo.dart';

class WelcomePage extends StatefulWidget {
  final VoidCallback onStart;

  const WelcomePage({super.key, required this.onStart});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  static const int _lastPage = 2;

  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_page == _lastPage) {
      widget.onStart();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/welcome.png',
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const ColoredBox(color: AppTheme.primary),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x992C4251),
                  Color(0x662C4251),
                  Color(0xE61B2B36),
                ],
                stops: [0.0, 0.45, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Visibility(
                    visible: _page < _lastPage,
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: TextButton(
                      onPressed: widget.onStart,
                      child: const Text(
                        'Passer',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _controller,
                    onPageChanged: (index) => setState(() => _page = index),
                    children: const [
                      _BrandSlide(),
                      _InfoSlide(
                        icon: Icons.search_rounded,
                        title: 'Trouvez facilement',
                        text:
                            'Recherchez par mot-clé et filtrez par ville, type, prix, surface et équipements.',
                      ),
                      _InfoSlide(
                        icon: Icons.add_home_work_outlined,
                        title: 'Publiez en quelques minutes',
                        text:
                            'Ajoutez vos photos et vos informations, puis contactez acheteurs et locataires par WhatsApp.',
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i <= _lastPage; i++)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _page == i ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _page == i
                              ? Colors.white
                              : const Color(0x66FFFFFF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.silver,
                        foregroundColor: AppTheme.primary,
                        minimumSize: const Size(64, 56),
                        shape: const StadiumBorder(),
                      ),
                      onPressed: _next,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _page == _lastPage ? 'Commencer' : 'Suivant',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandSlide extends StatelessWidget {
  const _BrandSlide();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LivinLogo(size: 52, color: Colors.white),
          SizedBox(height: 14),
          Text(
            'Trouvez le logement qui vous ressemble',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _InfoSlide extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _InfoSlide({
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0x33FFFFFF),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 56, color: Colors.white),
          ),
          const SizedBox(height: 28),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.silver, fontSize: 16),
          ),
        ],
      ),
    );
  }
}