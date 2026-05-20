import 'package:flutter/material.dart';
import 'package:job_matrix_forntend/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:job_matrix_forntend/screens/widgets/auth_background.dart';
import 'package:job_matrix_forntend/services/auth_provider.dart';
import 'package:job_matrix_forntend/screens/Dashboard/user_dashboard_screen.dart';
import 'package:job_matrix_forntend/screens/Dashboard/admin_dashboard_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _handleRegister() async {
    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.register(
      name: _nameController.text.trim(),
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
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
          content: Text('Registration failed. Please check your details.'),
        ),
      );
    }
  }

  Future<void> _handleGoogleLogin() async {
    print('DEBUG: Google Sign-In Button Pressed');

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
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isLoading = authProvider.isLoading;

    return AuthBackground(
      maxWidth: 400,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Job Matrix',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D464C),
              ),
            ),
            const Text(
              'Welcome to Job Matrix',
              style: TextStyle(fontSize: 14, color: Color(0xFF2D464C)),
            ),
            const SizedBox(height: 20),
            _buildTextField(
              label: 'Name',
              hint: 'Enter your name',
              controller: _nameController,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              label: 'Username',
              hint: 'Enter your username',
              controller: _usernameController,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              label: 'Email',
              hint: 'Enter your email',
              controller: _emailController,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              label: 'Password',
              hint: 'Enter your password',
              isPassword: true,
              controller: _passwordController,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _handleRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF78909C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
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
                        'Create Account',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'OR',
              style: TextStyle(color: Color(0xFF2D464C), fontSize: 10),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : _handleGoogleLogin,
                icon: Image.asset('assets/images/google.png', height: 20),
                label: const Text('Continue with google'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
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
              borderSide: const BorderSide(color: Color(0xFF2D464C)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2D464C)),
            ),
          ),
        ),
      ],
    );
  }
}
