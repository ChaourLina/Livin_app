import 'package:flutter/material.dart';
import 'package:livin_app/core/shared/app_theme.dart';
import 'package:livin_app/core/shared/livin_logo.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppTheme.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LivinLogo(size: 44, color: Colors.white),
            SizedBox(height: 24),
            CircularProgressIndicator(color: AppTheme.silver),
          ],
        ),
      ),
    );
  }
}