import 'package:flutter/material.dart';
import '../Dashboard/widgets/sidebar.dart';
import '../Dashboard/widgets/header.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFC0C7C4,
      ).withAlpha(100), // Matching the grayish background from screenshot
      body: Row(
        children: [
          const Sidebar(currentRoute: 'help'),
          Expanded(
            child: Column(
              children: [
                const Header(title: 'Help Center', showCreateButton: false),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        _buildHeroSection(),
                        const SizedBox(height: 60),
                        _buildCategorySection(),
                        const SizedBox(height: 60),
                        _buildPopularResources(),
                        const SizedBox(height: 60),
                        _buildLiveChatCard(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Column(
      children: [
        const Text(
          'How can we help?',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Color(0xFF23393E),
          ),
        ),
        const SizedBox(height: 32),
        Container(
          constraints: const BoxConstraints(maxWidth: 800),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(5),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const TextField(
            decoration: InputDecoration(
              hintText: 'Search for articles, guides, or keywords...',
              hintStyle: TextStyle(color: Colors.grey),
              prefixIcon: Icon(Icons.search, color: Colors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySection() {
    return Column(
      children: [
        const Text(
          'BROWSE BY CATEGORY',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCategoryCard(
              icon: Icons.rocket_launch,
              title: 'Getting\nStarted',
              subtitle:
                  'New to Nexus? Learn the basics and set up your first workspace in minutes.',
              actionLabel: 'EXPLORE GUIDE',
            ),
            const SizedBox(width: 24),
            _buildCategoryCard(
              icon: Icons.account_tree_outlined,
              title: 'Project\nManagement',
              subtitle:
                  'Master task tracking, milestones, and advanced team collaboration tools.',
              actionLabel: 'VIEW ARTICLES',
            ),
            const SizedBox(width: 24),
            _buildCategoryCard(
              icon: Icons.build_outlined,
              title: 'Troubleshooting',
              subtitle:
                  'Encountering an issue? Find solutions for common technical questions and bugs.',
              actionLabel: 'GET SUPPORT',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionLabel,
  }) {
    return Container(
      width: 240,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF23393E),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF23393E),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFF23393E).withAlpha(150),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                actionLabel,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF23393E),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.arrow_forward,
                size: 12,
                color: Color(0xFF23393E),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPopularResources() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 800),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF23393E).withAlpha(10),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Popular Resources',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF23393E),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'View all documentation',
                  style: TextStyle(
                    color: Color(0xFF23393E),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildResourceTile(
                      Icons.description_outlined,
                      'Setting up automated\nworkflows',
                    ),
                    const SizedBox(height: 16),
                    _buildResourceTile(
                      Icons.storage_outlined,
                      'Exporting project reports\n(PDF/CSV)',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    _buildResourceTile(
                      Icons.group_add_outlined,
                      'Inviting external\ncollaborators',
                    ),
                    const SizedBox(height: 16),
                    _buildResourceTile(
                      Icons.lock_outline,
                      'Managing team\npermissions',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResourceTile(IconData icon, String title) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF23393E),
              ),
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
        ],
      ),
    );
  }

  Widget _buildLiveChatCard() {
    return Container(
      width: 450,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: const Color(0xFF23393E),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.headset_mic_outlined,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Still need help?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Our support team is available 24/7 to assist you.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.white.withAlpha(150)),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF23393E),
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Start a Live Chat',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
