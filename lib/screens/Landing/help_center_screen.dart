import 'package:flutter/material.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Help Center',
          style: TextStyle(color: Color(0xFF2D464C), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2D464C)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSearchHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
              child: _buildCategories(context),
            ),
            _buildPopularArticles(),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      color: const Color(0xFF2D464C),
      child: Column(
        children: [
          const Text(
            'How can we help you?',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            constraints: const BoxConstraints(maxWidth: 600),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Search for articles, guides...',
                prefixIcon: Icon(Icons.search, color: Color(0xFF2D464C)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(BuildContext context) {
    final categories = [
      {'icon': Icons.rocket_launch, 'title': 'Getting Started', 'count': '12 articles'},
      {'icon': Icons.person, 'title': 'Account Setup', 'count': '8 articles'},
      {'icon': Icons.payments, 'title': 'Billing & Plans', 'count': '5 articles'},
      {'icon': Icons.security, 'title': 'Security', 'count': '10 articles'},
      {'icon': Icons.integration_instructions, 'title': 'Integrations', 'count': '7 articles'},
      {'icon': Icons.devices, 'title': 'Desktop App', 'count': '4 articles'},
    ];

    return Wrap(
      spacing: 24,
      runSpacing: 24,
      alignment: WrapAlignment.center,
      children: categories.map((cat) => _buildCategoryCard(cat)).toList(),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> cat) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2D464C).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(cat['icon'] as IconData, color: const Color(0xFF2D464C), size: 32),
          ),
          const SizedBox(height: 20),
          Text(
            cat['title'] as String,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D464C)),
          ),
          const SizedBox(height: 8),
          Text(
            cat['count'] as String,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularArticles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            'Popular Articles',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2D464C)),
          ),
        ),
        const SizedBox(height: 32),
        _buildArticleTile('How to create your first project'),
        _buildArticleTile('Setting up team permissions'),
        _buildArticleTile('Managing your subscription'),
        _buildArticleTile('Keyboard shortcuts guide'),
      ],
    );
  }

  Widget _buildArticleTile(String title) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {},
      ),
    );
  }
}
