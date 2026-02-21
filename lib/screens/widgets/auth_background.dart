import 'package:flutter/material.dart';

class AuthBackground extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  const AuthBackground({super.key, required this.child, this.maxWidth});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/wallpaper.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          // Darker overlay for better readability if needed
          Positioned.fill(child: Container(color: Colors.black.withAlpha(20))),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                constraints: BoxConstraints(maxWidth: maxWidth ?? 420),
                padding: const EdgeInsets.all(32.0),
                decoration: BoxDecoration(
                  color: const Color(
                    0xFF93A0A0,
                  ).withAlpha(235), // Professional off-white
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(30),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
