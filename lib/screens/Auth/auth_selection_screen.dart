import 'package:flutter/material.dart';
import '../widgets/auth_background.dart';
import 'register_screen.dart';
import 'login_screen.dart';
import 'package:job_matrix_forntend/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:job_matrix_forntend/services/auth_provider.dart';
import 'package:job_matrix_forntend/screens/Dashboard/user_dashboard_screen.dart';
import 'package:job_matrix_forntend/screens/Dashboard/admin_dashboard_screen.dart';

class AuthSelectionScreen extends StatelessWidget {
  const AuthSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Job Matrix',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D464C),
            ),
          ),
          const Text(
            'Welcome to Job Matrix',
            style: TextStyle(fontSize: 16, color: Color(0xFF2D464C)),
          ),
          const SizedBox(height: 40),
          _buildButton(
            onPressed: () async {
              print('DEBUG: Google AuthSelection Button Pressed');
              final authResponse = await ApiService.loginWithGoogle();

              if (authResponse == null) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Google Sign-In was cancelled or failed.'),
                    ),
                  );
                }
                return;
              }

              final authProvider = context.read<AuthProvider>();
              authProvider.setAuth(authResponse.user, authResponse.accessToken);

              if (context.mounted) {
                final user = authProvider.user;
                final role = user?.role.toLowerCase().trim() ?? 'user';

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
              }
            },
            icon: Image.asset('assets/images/google.png', height: 24),
            backgroundColor: const Color(0xFFCFD8DC),
            text: 'Continue with google',
          ),
          const SizedBox(height: 16),
          _buildButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RegisterScreen()),
              );
            },
            backgroundColor: const Color(0xFFCFD8DC),
            text: 'Continue with email',
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Have an account? ',
                style: TextStyle(color: Color(0xFF2D464C)),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Login',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D464C),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required VoidCallback onPressed,
    required String text,
    Color? backgroundColor,
    Widget? icon,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: const Color(0xFF2D464C),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[icon, const SizedBox(width: 8)],
            Text(
              text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
