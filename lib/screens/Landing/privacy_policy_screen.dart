import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Privacy Policy',
          style: TextStyle(color: Color(0xFF2D464C), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2D464C)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacy Policy',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D464C),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: March 20, 2026',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 32),
            _buildSection(
              '1. Information We Collect',
              'We collect information that you provide directly to us, such as your name, email address, and project data when you create an account or use our service.',
            ),
            _buildSection(
              '2. How We Use Information',
              'We use the information we collect to provide, maintain, and improve our services, communicate with you, and protect our users.',
            ),
            _buildSection(
              '3. Information Sharing',
              'We do not share your personal information with third parties except as described in this policy, such as with your consent or for legal reasons.',
            ),
            _buildSection(
              '4. Data Security',
              'We take reasonable measures to help protect information about you from loss, theft, misuse, and unauthorized access, disclosure, or alteration.',
            ),
            _buildSection(
              '5. Your Choices',
              'You may update or correct your account information at any time by logging into your account or contacting us.',
            ),
            const SizedBox(height: 48),
            const Divider(),
            const SizedBox(height: 24),
            const Text(
              'If you have any questions about this Privacy Policy, please contact us.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D464C),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
