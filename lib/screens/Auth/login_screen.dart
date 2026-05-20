import 'package:flutter/material.dart';
import 'package:job_matrix_forntend/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:job_matrix_forntend/screens/widgets/auth_background.dart';
import 'package:job_matrix_forntend/services/auth_provider.dart';
import 'package:job_matrix_forntend/screens/Auth/register_screen.dart';
import 'package:job_matrix_forntend/screens/Dashboard/user_dashboard_screen.dart';
import 'package:job_matrix_forntend/screens/Dashboard/admin_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _handleLogin() async {
    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.login(
      _loginController.text.trim(),
      _passwordController.text.trim(),
    );

    if (success && mounted) {
      final user = authProvider.user;
      final role = user?.role.toLowerCase().trim() ?? 'user';
      print('User role from server: $role');

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
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login failed. Please check your credentials.'),
        ),
      );
    }
  }

  Future<void> _handleGoogleLogin() async {
    print('DEBUG: Google Login Button Pressed');

    // Call Google Sign-In IMMEDIATELY to satisfy browser user gesture requirements
    final authResponse = await ApiService.loginWithGoogle();

    if (authResponse == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Google Sign-In was cancelled or failed.'),
          ),
        );
      }
      return;
    }

    final authProvider = context.read<AuthProvider>();
    // Manually set the user and token in the provider
    authProvider.setAuth(authResponse.user, authResponse.accessToken);

    if (mounted) {
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
    } else if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Google Sign-In failed.')));
    }
  }

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isLoading = authProvider.isLoading;

    return AuthBackground(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
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
            _buildTextField(
              label: 'Email / Username',
              hint: 'Enter your email or username',
              controller: _loginController,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              label: 'Password',
              hint: 'Enter your password',
              isPassword: true,
              controller: _passwordController,
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Forget password?',
                style: TextStyle(color: Colors.grey[700], fontSize: 12),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF78909C),
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Login',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            // Google Sign In Button
            const SizedBox(height: 16),
            // Google Sign In Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: isLoading ? null : _handleGoogleLogin,
                icon: SizedBox(
                  width: 18,
                  height: 18,
                  child: Image.asset(
                    'assets/images/google.png',
                    fit: BoxFit.contain,
                  ),
                ),
                label: const Text(
                  'Sign in with Google',
                  style: TextStyle(
                    color: Color(0xFF2D464C),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFF78909C)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Don't have an account? ",
                  style: TextStyle(color: Color(0xFF2D464C)),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Register',
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
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2D464C),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
