import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:livin_app/core/shared/app_theme.dart';

class OfflineBanner extends StatefulWidget {
  final VoidCallback? onReconnected;

  const OfflineBanner({super.key, this.onReconnected});

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _offline = false;

  bool _isOffline(List<ConnectivityResult> results) {
    return results.isEmpty ||
        results.every((result) => result == ConnectivityResult.none);
  }

  @override
  void initState() {
    super.initState();
    Connectivity().checkConnectivity().then((results) {
      if (mounted) setState(() => _offline = _isOffline(results));
    });
    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      final offline = _isOffline(results);
      if (offline == _offline) return;
      final reconnected = _offline && !offline;
      setState(() => _offline = offline);
      if (reconnected) widget.onReconnected?.call();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      child: _offline
          ? Container(
              width: double.infinity,
              color: AppTheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: const Row(
                children: [
                  Icon(Icons.wifi_off, size: 18, color: Colors.white),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Pas de connexion internet. Les annonces et les photos peuvent ne pas s\'afficher.',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox(width: double.infinity),
    );
  }
}