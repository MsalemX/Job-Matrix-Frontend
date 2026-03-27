import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:job_matrix_forntend/services/auth_provider.dart';
import 'package:job_matrix_forntend/screens/Landing/landing_screen.dart';
import 'package:job_matrix_forntend/screens/Dashboard/user_dashboard_screen.dart';
import 'package:job_matrix_forntend/screens/Dashboard/admin_dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  _navigateToNext() async {
    // Wait for the splash animation or a minimum delay
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    
    // If the provider is still loading, wait a bit more
    while (authProvider.isLoading && mounted) {
      await Future.delayed(const Duration(milliseconds: 500));
    }

    if (!mounted) return;

    if (authProvider.isAuthenticated) {
      final role = authProvider.user?.role.toLowerCase().trim() ?? 'user';
      Widget nextScreen;
      if (role == 'admin' || role == 'system_admin' || role == 'system admin') {
        nextScreen = const AdminDashboardScreen();
      } else {
        nextScreen = const UserDashboardScreen();
      }
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => nextScreen),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LandingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Lottie.asset(
          'assets/json/work managemnt.json',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
