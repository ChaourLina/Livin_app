import 'package:flutter/material.dart';

class LivinLogo extends StatelessWidget {
  final double size;
  final Color? color;

  const LivinLogo({super.key, this.size = 24, this.color});

  @override
  Widget build(BuildContext context) {
    final logoColor = color ?? Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.home_rounded, color: logoColor, size: size * 1.15),
        const SizedBox(width: 6),
        Text(
          'Livin',
          style: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            color: logoColor,
          ),
        ),
      ],
    );
  }
}